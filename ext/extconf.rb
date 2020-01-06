require 'open-uri'
require 'json'
require 'byebug'
require 'tmpdir'

def check_system(*cmd)
  unless system(*cmd)
    raise "Failed to execute: #{cmd.join(' ')}"
  end
end

def fetch_release(repo_full_name, release_name_pattern, file_name_pattern, dir)
  if release_name_pattern
    # Get all releases and find an appropriate one for repos like
    # libmongocrypt that contain multiple projects
    base_url = "https://api.github.com/repos/#{repo_full_name}/releases"
    page = 1
    while true
      contents = URI.open("#{base_url}?page=#{page}").read
      payload = JSON.parse(contents)
      if payload.empty?
        raise "Did not find a suitable release"
      end
      release = payload.detect do |release|
        !release['prerelease'] && release['name'] =~ release_name_pattern
      end
      break if release
      page += 1
    end
  else
    # Use latest release
    contents = URI.open("https://api.github.com/repos/#{repo_full_name}/releases/latest").read
    release = JSON.parse(contents)
  end
  if file_name_pattern
    file = release['assets'].detect do |file|
      file['name'] =~ file_name_pattern
    end
    url = file['browser_download_url']
  else
    url = "https://github.com/#{repo_full_name}/archive/#{release['tag_name']}.tar.gz"
  end
  basename = File.basename(url)
  dest = File.join(dir, basename)
  File.open(dest, 'w') do |f|
    io = URI.open(url)
    while chunk = io.read(256*1024)
      f.write(chunk)
    end
  end
  dest
end

def fetch_and_extract_release(repo_full_name, release_name_pattern, file_name_pattern, dir)
  archive_path = fetch_release(repo_full_name, release_name_pattern, file_name_pattern, dir)

  Dir.chdir(dir) do
    check_system('tar', 'xf', archive_path)
  end

  if file_name_pattern
    archive_path.sub(/\.tar\.gz\z/, '')
  else
    archive_path
  end
end

Dir.mktmpdir do |root|
  cmake_root = fetch_and_extract_release('Kitware/CMake', nil, /linux.*x86_64.*tar.gz/i, root)
  cmake_path = File.join(cmake_root, 'bin', 'cmake')

  mongoc_root = fetch_and_extract_release('mongodb/mongo-c-driver', nil, /\.tar\.gz\z/, root)
  libbson_prefix = File.join(root, 'libbson')
  Dir.chdir(mongoc_root) do
    check_system(cmake_path, '-DENABLE_MONGOC=OFF',
      "-DCMAKE_INSTALL_PREFIX=#{libbson_prefix}", '-DCMAKE_C_FLAGS="-fPIC"', '.')
    check_system('make', 'install')
  end

  lmc_archive_path = fetch_and_extract_release('mongodb/libmongocrypt', /\A[0-9]/, nil, root)
  lmc_root = File.join(root, "libmongocrypt-#{File.basename(lmc_archive_path).sub(/\.tar\.gz\z/, '')}")
  unless File.directory?(lmc_root)
    raise "libmongocrypt directory detection failed"
  end
  lmc_prefix = File.join(root, 'libmongocrypt')
  Dir.chdir(lmc_root) do
    #check_system('echo hello >VERSION_CURRENT')
    check_system(cmake_path, "-DCMAKE_PREFIX_PATH=#{libbson_prefix}",
      '-DDISABLE_NATIVE_CRYPTO=1', '-DBUILD_VERSION=1.0.0',
      "-DCMAKE_INSTALL_PREFIX=#{lmc_prefix}", '-DCMAKE_C_FLAGS="-fPIC"', '.')
    check_system('make', 'install')
  end

  lmc_path = File.join(lmc_prefix, 'lib', 'libmongocrypt.so')
  FileUtils.copy(lmc_path, File.dirname(__FILE__))

  File.open(File.join(File.dirname(__FILE__), 'Makefile'), 'w') do |f|
    f << "all:\ninstall:\n"
  end
end
