require 'open-uri'
require 'json'
require 'byebug'
require 'tmpdir'

def fetch_release(repo_full_name, release_name_pattern, dir)
  contents = URI.open("https://api.github.com/repos/#{repo_full_name}/releases/latest").read
  payload = JSON.parse(contents)
  file = payload['assets'].detect do |file|
    file['name'] =~ release_name_pattern
  end
  url = file['browser_download_url']
  basename = File.basename(url)
  dest = File.join(dir, basename)
  File.open(dest, 'w') do |f|
    io = URI.open(url)
    while chunk = io.read(256*1024)
      f.write(chunk)
    end
  end
  dest
end

def fetch_and_extract_release(repo_full_name, release_name_pattern, dir)
  archive_path = fetch_release(repo_full_name, release_name_pattern, dir)

  Dir.chdir(root) do
    unless system('tar', 'xf', archive_path)
      raise "Failed to extract #{File.basename(archive_path}")
    end
  end

  archive_path.sub(/\.tar\.gz\z/, '')
end

Dir.mktmpdir do |root|
  cmake_root = fetch_and_extract_release('Kitware/CMake', /linux.*x86_64.*tar.gz/i, root)
  cmake_path = File.join(cmake_root, 'bin', 'cmake')

  byebug
  STDERR.puts contents

  File.open('Makefile', 'w') do |f|
    f << "all:\ninstall:\n"
  end
end
