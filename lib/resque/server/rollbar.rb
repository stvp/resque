require 'rollbar'

# Get better info than Rollbar's RequestDataExtractor
class RequestDataExtractor
  include Rollbar::RequestDataExtractor
  def from_rack(env)
    extract_request_data_from_rack(env).merge({
      :route => env["PATH_INFO"]
    })
  end

  def rollbar_request_params(env)
    env['action_dispatch.request.parameters'] || {}
  end
end

def setup_rollbar
  if ENV["ROLLBAR_ACCESS_TOKEN"]
    Rollbar.configure do |config|
      config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
      config.environment = Sinatra::Base.environment
      config.root = Dir.pwd
    end
  end
end

