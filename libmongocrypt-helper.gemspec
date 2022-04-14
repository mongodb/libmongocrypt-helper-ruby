lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libmongocrypt_helper/version'

Gem::Specification.new do |s|
  s.name              = 'libmongocrypt-helper'
  s.version           = LibmongocryptHelper::VERSION
  s.authors           = ['Oleg Pudeyev']
  s.email             = ['mongodb-dev@googlegroups.com']
  s.homepage          = 'https://docs.mongodb.com/ruby-driver/current/'
  s.summary           = 'libmongocrypt convenience package'
  s.description       = nil
  s.license           = 'Apache-2.0'

  s.metadata = {
    'bug_tracker_uri' => 'https://jira.mongodb.org/projects/RUBY',
    'changelog_uri' => 'https://github.com/p-mongodb/libmongocrypt-helper/releases',
    'documentation_uri' => 'https://www.mongodb.com/docs/ruby-driver/master/reference/client-side-encryption/',
    'homepage_uri' => 'https://docs.mongodb.com/ruby-driver/current/',
    'mailing_list_uri' => 'https://groups.google.com/group/mongodb-user',
    'source_code_uri' => 'https://github.com/p-mongodb/libmongocrypt-helper'
  }

  if File.exists?('gem-private_key.pem')
    s.signing_key = 'gem-private_key.pem'
    s.cert_chain  = ['gem-public_cert.pem']
  else
    warn "[#{s.name}] Warning: No private key present, creating unsigned gem."
  end

  #s.files      = %w(CONTRIBUTING.md CHANGELOG.md LICENSE NOTICE README.md Rakefile)
  s.files      += Dir.glob('lib/**/*') + Dir.glob('so/**/*.so')

  s.require_path              = 'lib'
end
