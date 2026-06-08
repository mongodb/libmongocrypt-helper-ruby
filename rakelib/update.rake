# rakelib/update.rake

require 'fileutils'
require 'tmpdir'

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

  desc 'Download and unpack libmongocrypt source into ext/libmongocrypt/libmongocrypt/'
  task :libmongocrypt do
    version = resolve_version
    tarball_url = "https://github.com/mongodb/libmongocrypt/archive/refs/tags/#{version}.tar.gz"
    dest = 'ext/libmongocrypt/libmongocrypt'

    Dir.mktmpdir do |tmpdir|
      tarball = File.join(tmpdir, "libmongocrypt-#{version}.tar.gz")

      puts "Downloading libmongocrypt #{version}..."
      sh "curl -L -f -o #{tarball} #{tarball_url}"

      puts "Extracting..."
      sh "tar xzf #{tarball} -C #{tmpdir}"

      extracted = File.join(tmpdir, "libmongocrypt-#{version}")
      abort "Expected #{extracted} after extraction — check that #{version} is a valid release tag" unless Dir.exist?(extracted)

      puts "Installing to #{dest}..."
      FileUtils.rm_rf(dest)
      FileUtils.mv(extracted, dest)
    end

    puts "libmongocrypt #{version} source installed to #{dest}"
  end

  desc 'Update sbom.json via etc/update-sbom.sh (requires Docker and MongoDB Artifactory access)'
  task :sbom do
    sh 'etc/update-sbom.sh'
  end

  desc 'Build and install the gem locally to verify it'
  task :test do
    content = File.read('lib/libmongocrypt_helper/version.rb')
    version = content.match(/(?<![A-Z_])VERSION = '([^']+)'/)[1]
    sh "gem build libmongocrypt-helper.gemspec"
    sh "gem install libmongocrypt-helper-#{version}.gem"
    puts "Successfully built and installed libmongocrypt-helper-#{version}"
  end
end
