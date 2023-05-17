require 'bundler'
require 'bundler/gem_tasks'
require 'rubygems/package'
require 'rubygems/security/policies'

def signed_gem?(path_to_gem)
  Gem::Package.new(path_to_gem, Gem::Security::HighSecurity).verify
  true
rescue Gem::Security::Exception => e
  false
end

desc 'Compiles the libmongocrypt library'
task :compile do
  chdir 'ext/libmongocrypt' do
    ruby 'extconf.rb'
  end
end

desc 'Verifies that all built gems in pkg/ are valid'
task :verify do
  gems = Dir['pkg/*.gem']
  if gems.empty?
    puts 'There are no gems in pkg/ to verify'
  else
    gems.each do |gem|
      if signed_gem?(gem)
        puts "#{gem} is signed"
      else
        abort "#{gem} is not signed"
      end
    end
  end
end
