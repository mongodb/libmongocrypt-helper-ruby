lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libmongocrypt_helper/version'

Gem::Specification.new do |s|
  s.name              = 'libmongocrypt-helper'
  s.version           = LibmongocryptHelper::VERSION
  s.authors           = ['The MongoDB Ruby Team']
  s.email             = ['dbx-ruby@mongodb.com']
  s.homepage          = 'https://www.mongodb.com/docs/ruby-driver/current/'
  s.summary           = 'libmongocrypt convenience package'
  s.description       = nil
  s.license           = 'Apache-2.0'

  s.metadata = {
    'bug_tracker_uri' => 'https://jira.mongodb.org/projects/RUBY',
    'changelog_uri' => 'https://github.com/mongodb/libmongocrypt-helper-ruby/releases',
    'documentation_uri' => 'https://www.mongodb.com/docs/ruby-driver/master/reference/client-side-encryption/',
    'homepage_uri' => 'https://www.mongodb.com/docs/ruby-driver/current/',
    'mailing_list_uri' => 'https://www.mongodb.com/community/forums/',
    'source_code_uri' => 'https://github.com/mongodb/libmongocrypt-helper-ruby'
  }

  # s.files = %w(CONTRIBUTING.md CHANGELOG.md LICENSE NOTICE README.md Rakefile)
  s.extensions = ['ext/libmongocrypt/extconf.rb']
  s.files = Dir.glob('lib/**/*') + Dir.glob('ext/**/*') - [File.join('ext/libmongocrypt/libmongocrypt/build')]

  s.require_path = ['lib']
end
