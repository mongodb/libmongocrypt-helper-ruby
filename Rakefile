require 'bundler'
require 'bundler/gem_tasks'
require 'rake/extensiontask'

task :compile do
  chdir "ext/libmongocrypt" do
    ruby "extconf.rb"
  end
end
