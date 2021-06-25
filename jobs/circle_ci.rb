require 'circleci'
require 'awesome_print'

module Constants
  STATUSES = %w[failed passed running started broken timedout no_tests fixed success canceled]
  FAILED, PASSED, RUNNING, STARTED, BROKEN, TIMEDOUT, NOTESTS, FIXED, SUCCESS, CANCELED = STATUSES
  FAILED_C   = 0.05
  BROKEN_C   = 0.05
  TIMEDOUT_C = 0.3
  NO_TESTS_C = 0.5
  CANCELED_C = 0.5
  RUNNING_C  = 1.0
  STARTED_C  = 1.0
  FIXED_C    = 1.0
  PASSED_C   = 1.0
  SUCCESS_C  = 1.0
end

def get_climate(builds = [])
  return '|' if builds.empty?

  statuses = builds[0..10].map { |build| build['status'] }.compact
  weight = nil

  statuses.each do |status|
    factor = begin
      Constants.const_get("#{status.upcase}_C")
    rescue StandardError
      nil
    end
    next unless factor

    weight = weight.nil? ? factor : weight * factor
  end

  case weight
  when 0.0..0.25  then '9'
  when 0.26..0.5  then '7'
  when 0.51..0.75 then '1'
  when 0.76..1.0  then 'v'
  else
    '|'
  end
end

def get_build_info(builds = [])
  return {} if builds.empty?

  build = builds.first

  {
    build_num: "##{build['build_num']}",
    build_url: build['build_url'],
    commit_str: build['subject'][0..40].gsub(/\s\w+\s*$/, ' ...'),
    committer: build['committer_name'],
    status: build['status'],
    climate: get_climate(builds)
  }
end

SCHEDULER.every('1m', { first_in: '2s', allow_overlapping: false }) do
  CONFIG[:projects].each do |project_name|
    project = CircleCi::Project.new(CONFIG[:org], project_name)
    res     = project.recent_builds_branch('main')
    body    = res.body.is_a?(Array) ? res.body : []
    data_id = "circle-ci-#{CONFIG[:org]}-#{project_name}"
    data    = get_build_info(body)

    send_event(data_id, data) unless data.empty?
  end
end
