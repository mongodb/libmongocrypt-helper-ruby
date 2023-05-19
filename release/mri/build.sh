#!/bin/bash

set -e

rm -f *.lock
rm -f *.gem pkg/*.gem
# Uses bundler gem tasks, outputs the built gem file to pkg subdir.
bundle install
bundle exec rake build verify
