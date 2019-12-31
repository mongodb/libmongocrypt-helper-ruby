require 'open-uri'
require 'json'
require 'byebug'
require 'tmpdir'

def fetch_release(repo_full_name)
end

Dir.mktmpdir do |root|
  contents = URI.open('https://api.github.com/repos/Kitware/CMake/releases/latest').read
  payload = JSON.parse(contents)
  file = payload['assets'].detect do |file|
    file['name'] =~ /linux.*x86_64.*tar.gz/i
  end
  url = file['browser_download_url']
  basename = File.basename(url)
  File.open(File.join(root, basename), 'w') do |f|
    io = URI.open(url)
    while chunk = io.read(256*1024)
      f.write(chunk)
    end
  end

  Dir.chdir(root) do
    unless system('tar', 'xf', basename)
      raise "CMake extraction failed"
    end
  end

  cmake_path = File.join(root, basename.sub(/\.tar\.gz$/, ''), 'bin', 'cmake')

  byebug
  STDERR.puts contents

  File.open('Makefile', 'w') do |f|
    f << "all:\ninstall:\n"
  end
end
