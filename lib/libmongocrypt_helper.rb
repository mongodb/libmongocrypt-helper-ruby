module LibmongocryptHelper
  def libmongocrypt_path
    File.join(File.dirname(__FILE__), '..', 'so', 'libmongocrypt.so')
  end
  module_function :libmongocrypt_path
end
