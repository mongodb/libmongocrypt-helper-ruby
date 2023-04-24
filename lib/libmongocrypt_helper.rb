require 'libmongocrypt_helper/version'

module LibmongocryptHelper
  def libmongocrypt_path
    @libmongocrypt_path ||= begin
      lib_file_extension = case RbConfig::CONFIG['target_os']
      when /linux/ then "so"
      when /darwin/ then "dylib"
      else raise "ERROR: this gem supports only linux and macos, #{RbConfig::CONFIG['target_os']} is not supported"
      end

      File.join(
        File.dirname(__FILE__),
        'libmongocrypt',
        "libmongocrypt.#{lib_file_extension}"
      )
    end
  end
  module_function :libmongocrypt_path
end
