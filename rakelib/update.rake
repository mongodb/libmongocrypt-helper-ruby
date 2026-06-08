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
end
