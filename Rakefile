# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs.push 'lib'
  t.test_files = FileList['specs/*_spec.rb']
  t.verbose = true
end

task default: [:test]
