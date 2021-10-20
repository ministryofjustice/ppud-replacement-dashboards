# frozen_string_literal: true

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'rake/testtask'
require 'db'

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.test_files = FileList['specs/*_spec.rb']
  t.verbose = true
end

task default: [:test]

namespace :db do
  desc 'Run database migrations'
  task :migrate do
    Db.connect
    Db.migrate
    Db.disconnect
  end
end
