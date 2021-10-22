# frozen_string_literal: true

ENV['AUTH_TOKEN'] = 'token'

require_relative 'spec_helper'
require 'minitest/hooks'
require 'rack/test'
require_relative '../lib/data_reciever'

def app
  DataReciever
end

describe 'POST /manage-recalls-e2e-result' do
  include Rack::Test::Methods
  include Minitest::Hooks

  around do |&block|
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super(&block)
    end
  end

  let(:uri) { '/manage-recalls-e2e-result' }
  let(:headers) { { CONTENT_TYPE: 'application/json' } }
  let(:table) { DB[:manage_recalls_e2e_results] }
  let(:good_req) do
    {
      auth_token: ENV['AUTH_TOKEN'],
      e2e_build_url: 'https://foo.com',
      environment: 'dev',
      successful: true,
      ui_version: '12345',
      ui_build_url: 'https://foo.com',
      api_version: '54321',
      api_build_url: 'https://foo.com'
    }
  end

  it 'Returns a 403 is the auth_token is incorrect' do
    post(uri, { auth_token: 'foobar' }.to_json, headers)
    _(last_response.body).must_equal('Forbidden')
  end

  it 'saves a e2e test result to the DB' do
    _(table.count).must_equal(0)
    post(uri, good_req.to_json, headers)
    _(last_response.status).must_equal(200)
    _(table.count).must_equal(1)
  end

  it 'does not fail if the same result is sent twice' do
    _(table.count).must_equal(0)
    post(uri, good_req.to_json, headers)
    _(last_response.status).must_equal(200)
    post(uri, good_req.to_json, headers)
    _(last_response.status).must_equal(200)
    _(table.count).must_equal(1)
  end

  it 'updates an result record if the same versions are sent again' do
    first_res = good_req
    second_res = good_req.merge({ e2e_build_url: 'https://bar.com' })

    # first result
    _(table.count).must_equal(0)
    post(uri, first_res.to_json, headers)
    _(last_response.status).must_equal(200)
    _(table.count).must_equal(1)
    _(table.first[:e2e_build_url]).must_equal(first_res[:e2e_build_url])

    # second_result
    post(uri, second_res.to_json, headers)
    _(last_response.status).must_equal(200)
    _(table.count).must_equal(1)
    _(table.first[:e2e_build_url]).must_equal(second_res[:e2e_build_url])
  end

  it 'raises an error if an incomplete object is passed' do
    _(table.count).must_equal(0)
    caught_exception = nil

    begin
      json = {
        auth_token: ENV['AUTH_TOKEN'],
        e2e_build_url: 'https://foo.com'
      }
      post(uri, json.to_json, headers)
    rescue Sequel::NotNullConstraintViolation => e
      caught_exception = e
    end

    _(caught_exception).wont_be_nil
    _(table.count).must_equal(0)
  end
end
