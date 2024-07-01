require 'bundler'
require 'rubygems/package'

desc 'Compiles the libmongocrypt library'
task :compile do
  chdir 'ext/libmongocrypt' do
    ruby 'extconf.rb'
  end
end

desc 'NOT USED'
task :build do
  abort <<~WARNING
    `rake build` does nothing in this project. The gem must be built via
    the `Release` action on GitHub, which is triggered manually when
    a new release is ready.
  WARNING
end

# `rake version` is used by the deployment system so get the release version
# of the product beng deployed. It must do nothing more than just print the
# product version number.
#
# See the mongodb-labs/driver-github-tools/ruby/publish Github action.
desc 'Print the current value of Mongo::VERSION'
task :version do
  require_relative 'lib/libmongocrypt_helper/version'

  puts LibmongocryptHelper::VERSION
end

# overrides the default Bundler-provided `release` task, which also
# builds the gem. Our release process assumes the gem has already
# been built (and signed via GPG), so we just need `rake release` to
# push the gem to rubygems.
desc 'USED BY GITHUB ACTIONS'
task :release do
  require_relative 'lib/libmongocrypt_helper/version'

  if ENV['GITHUB_ACTION'].nil?
    abort <<~WARNING
      `rake release` must be invoked from the `Release` GitHub action,
      and must not be invoked locally. This ensures the gem is properly signed
      and distributed by the appropriate user.

      Note that it is the `rubygems/release-gem@v1` step in the `Release`
      action that invokes this task. Do not rename or remove this task, or the
      release-gem step will fail. Reimplement this task with caution.
    WARNING
  end

  system 'gem', 'push', "libmongocrypt-helper-#{LibmongocryptHelper::VERSION}.gem"
end
