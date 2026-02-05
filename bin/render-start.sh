#!/usr/bin/env bash
# exit on error
set -o errexit

# Ruby on Rails
bundle exec rails db:migrate
bundle exec rails ops:schema:check
bundle exec rails server
