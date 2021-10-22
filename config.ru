# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
require 'db'

AUTH_TOKEN = ENV.fetch('AUTH_TOKEN', 'AUTH_TOKEN')
DB = Db.connect

require 'dashing'
require 'data_reciever'

configure do
  set :auth_token, AUTH_TOKEN
  set :default_dashboard, 'ci'

  # See http://www.sinatrarb.com/intro.html > Available Template Languages on
  # how to add additional template languages.
  set :template_languages, %i[html erb]
  set :show_exceptions, false

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Rack::URLMap.new(
  '/' => Sinatra::Application,
  '/data' => DataReciever
)
