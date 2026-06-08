# rakelib/update.rake

require 'fileutils'

def resolve_version
  @resolved_version ||= begin
    if ENV['VERSION']
      ENV['VERSION']
    else
      tag = `gh release view --repo mongodb/libmongocrypt --json tagName --jq '.tagName'`.strip
      abort "Failed to resolve latest libmongocrypt version. Is `gh` installed and authenticated?" unless $?.success?
      tag
    end
  end
end

namespace :update do
  desc 'Update VERSION and LIBMONGOCRYPT_VERSION constants for a new libmongocrypt release'
  task :version do
    new_libmongocrypt_version = resolve_version
    version_file = 'lib/libmongocrypt_helper/version.rb'
    content = File.read(version_file)

    current_libmongocrypt = content.match(/LIBMONGOCRYPT_VERSION = '([^']+)'/)[1]
    current_helper = content.match(/(?<![A-Z_])VERSION = '([^']+)'/)[1]

    new_helper_version = if current_libmongocrypt == new_libmongocrypt_version
      parts = current_helper.split('.')
      parts[-1] = (parts[-1].to_i + 1).to_s
      parts.join('.')
    else
      "#{new_libmongocrypt_version}.0.1001"
    end

    content = content.sub(/LIBMONGOCRYPT_VERSION = '[^']+'/, "LIBMONGOCRYPT_VERSION = '#{new_libmongocrypt_version}'")
    content = content.sub(/(?<![A-Z_])VERSION = '[^']+'/, "VERSION = '#{new_helper_version}'")
    File.write(version_file, content)

    puts "Updated: LIBMONGOCRYPT_VERSION=#{new_libmongocrypt_version}, VERSION=#{new_helper_version}"
  end
end
