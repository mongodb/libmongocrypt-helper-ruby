require 'mkmf'
require 'rbconfig'
require_relative '../../lib/libmongocrypt_helper/version.rb'

CMAKE = find_executable('cmake')
abort "ERROR: CMake is required to build libmongocrypt" unless CMAKE

MAKE = find_executable('gmake') || find_executable('make')
abort "ERROR: make is required to build libmongocrypt" unless MAKE

# Specify the name of the C++ source file for the extension
extension_name = 'libmongocrypt'

# Specify the directory where the CMake project is located
cmake_dir = File.join(File.expand_path(File.dirname(__FILE__)), extension_name)

# Exclude C# bindings
cmake_lists_file = File.join(cmake_dir, 'CMakeLists.txt')
text = File.read(cmake_lists_file)
File.open(cmake_lists_file, "w") do |file|
  file << text.gsub(/^add_subdirectory \(bindings\/cs\)$/, "# add_subdirectory (bindings/cs)")
end

# Specify the build directory for CMake
build_dir = File.join(cmake_dir, 'build')

# Run CMake to generate the build files
Dir.mkdir(build_dir) unless File.exist?(build_dir)
cmake_opts = %w(
  -DDISABLE_NATIVE_CRYPTO=1
  -DMONGOCRYPT_CRYPTO=none
  -DMONGOCRYPT_ENABLE_CRYPTO=0
  -DBUILD_TESTING=0
)
cmake_opts << "-DBUILD_VERSION=#{LibmongocryptHelper::LIBMONGOCRYPT_VERSION}"
system("#{CMAKE} #{cmake_opts.join(' ')}  #{cmake_dir} -B#{build_dir}")

# Check if the build directory was successfully generated
unless File.exist?(File.join(build_dir, 'Makefile'))
  abort "ERROR: CMake failed to generate Makefile in #{build_dir}"
end

# Change to the build directory and run make to build the extension
Dir.chdir(build_dir) do
  system(MAKE)
end

lib_file_extension = case RbConfig::CONFIG['target_os']
                     when /linux/ then "so"
                     when /darwin/ then "dylib"
                     else abort "ERROR: this gem supports only linux and macos, #{RbConfig::CONFIG['target_os']} is not supported"
                     end

lib_file = File.join(build_dir, "#{extension_name}.#{lib_file_extension}")

# Check if the extension was successfully built
unless File.exist?(lib_file)
  abort "ERROR: Failed to build the extension in #{build_dir}"
end

# Copy the compiled extension library to the tmp directory
dst_folder = File.join('..', '..', 'lib', 'libmongocrypt')
FileUtils.mkdir_p(dst_folder) unless File.exist?(dst_folder)
FileUtils.cp(
  lib_file,
  dst_folder
)

# Create the Makefile for the extension
create_makefile(extension_name)
