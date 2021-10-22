# frozen_string_literal: true

require 'sinatra/base'
require_relative 'manage_recalls_e2e_result'

class DataReciever < Sinatra::Base
  post '/manage-recalls-e2e-result' do
    data = JSON.parse(request.body.read, symbolize_names: true)

    halt 403, 'Forbidden' if data[:auth_token] != ENV.fetch('AUTH_TOKEN', 'AUTH_TOKEN')

    result = data.reject { |key, _val| key == :auth_token }
    ManageRecallsE2eResult.update_or_create(result)

    status 200
    'OK'
  end
end
