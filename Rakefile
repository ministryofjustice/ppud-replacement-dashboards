# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'rake/testtask'
require 'db'
require 'date'
require 'securerandom'

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.test_files = FileList['specs/*_spec.rb']
  t.verbose = true
  t.warning = false
end

task default: [:test]

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    Db.connect
    Db.migrate
    Db.disconnect
  end

  desc 'Rollback database migrations'
  task :rollback do
    Db.connect
    Db.rollback
    Db.disconnect
  end

  desc 'Seed some development data into the database'
  task seed: [:migrate] do
    db = Db.connect

    %w[dev preprod].each do |env|
      (1..15).each do |num|
        date = Date.today - num
        url = "https://test#{num}-#{env}.com"
        version = "#{date.strftime('%Y-%m-%d')}.#{4000 - num}.#{SecureRandom.hex(4)}"

        db[:manage_recalls_e2e_results] << {
          e2e_build_url: url,
          environment: env,
          successful: num.even?,
          ui_version: version,
          ui_build_url: url,
          api_version: version,
          api_build_url: url,
          created_at: date,
          updated_at: date
        }
      end
    end
  end
end
