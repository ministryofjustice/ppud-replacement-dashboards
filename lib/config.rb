require 'circleci'

CircleCi.configure { |c| c.token = ENV['CIRCLE_CI_AUTH_TOKEN'] }

CONFIG = {
  org: 'ministryofjustice',
  projects: %w[
    manage-recalls-api
  ]
}

# manage-recalls-ui
# manage-recalls-e2e-tests
