# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = 'sqlite:/'

require 'db'
DB = Db.connect
Db.migrate

require 'minitest/autorun'
