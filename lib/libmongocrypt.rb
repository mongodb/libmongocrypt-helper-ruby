module Libmongocrypt
  def libmongocrypt_path
    File.join(File.dirname(__FILE__), '..', 'ext', 'libmongocrypt.so')
  end
  module_function :libmongocrypt_path
end
