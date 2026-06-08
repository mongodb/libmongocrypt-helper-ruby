require 'bundler'
require 'rubygems/package'

desc 'Compiles the libmongocrypt library'
task :compile do
  chdir 'ext/libmongocrypt' do
    ruby 'extconf.rb'
  end
end

task :build do
  gemspec = ENV['GEMSPEC']
  gem_file_name = ENV['GEM_FILE_NAME']

  unless gemspec && gem_file_name
    abort <<~WARNING
      `rake build` is intended to be called from CI only, with GEMSPEC and
      GEM_FILE_NAME environment variables set. To build the gem manually,
      run `gem build libmongocrypt-helper.gemspec` directly.
    WARNING
  end

  system('gem', 'build', gemspec) or abort('gem build failed')

  built = Dir['*.gem'].first
  File.rename(built, gem_file_name) if built && built != gem_file_name
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
