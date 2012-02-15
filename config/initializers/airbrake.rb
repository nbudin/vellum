if (airbrake_key = ENV['AIRBRAKE_API_KEY'] || ENV['HOPTOAD_API_KEY'])
  Airbrake.configure do |config|
    config.api_key = airbrake_key
    config.host    = ENV['AIRBRAKE_HOST'] || 'airbrake.io'
  end
end
