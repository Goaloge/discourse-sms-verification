# Discourse SMS Verification

Enforce phone number verification during registration.

## Installation
1. Clone into `/plugins/discourse-sms-verification`
2. Run:
   ```bash
   ./bin/bundle exec rake assets:precompile
   ./bin/rails db:migrate
