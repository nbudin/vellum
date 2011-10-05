require 'castronaut'

class AlwaysSucceedAdapter
  def self.authenticate(username, password)
    Castronaut::AuthenticationResult.new(username, nil)
  end
end

Castronaut::Adapters.register("always_succeed", AlwaysSucceedAdapter)

Castronaut.config = Castronaut::Configuration.load(File.expand_path("../castronaut.yml", __FILE__))
require 'castronaut/application'

Castronaut::Application.set(:path, "/cas")
Castronaut::Application.set(:logging, false)

capp = Capybara.app
Capybara.app = Rack::Builder.new do
  map "/cas" do
    run Castronaut::Application
  end
  
  map "/" do
    run capp
  end
end
Capybara.server_port = 28537
Capybara.run_server = true

require 'sham_rack'

Devise.cas_base_url = "http://localhost:#{Capybara.server_port}/cas"
ShamRack.at("localhost", Capybara.server_port) do |env|
  request = Rack::Request.new(env)
  request.path_info = request.path_info.sub(/^\/cas/, '')
  
  Castronaut::Application.call(request.env)
end