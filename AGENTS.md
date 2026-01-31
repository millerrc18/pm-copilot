# AGENTS.md

## Tests
- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- bundle exec rspec
- bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/navigation_spec.rb
- bin/ui-screenshots

## UI screenshots
- Include Cost Hub and Import costs pages when running `bin/ui-screenshots`.
- Verify screenshots are saved under `tmp/screenshots/ui/cost_hub` and `tmp/screenshots/ui/cost_imports`.
