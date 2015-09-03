require 'rollbar'
require 'rollbar/request_data_extractor'

# Get better info than Rollbar's RequestDataExtractor
class RequestDataExtractor
  include Rollbar::RequestDataExtractor
  def from_rack(env)
    extract_request_data_from_rack(env).merge({
      :route => env["PATH_INFO"]
    })
  end
end

module SinatraRollbarIntegration
  def self.included( base )
    base.class_eval do
      configure do
        if ENV["ROLLBAR_ACCESS_TOKEN"]
          Rollbar.configure do |config|
            config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
            config.environment = Sinatra::Base.environment
            config.root = Dir.pwd
          end
        end
      end

      # Report errors to Rollbar.
      error do
        request_data = RequestDataExtractor.new.from_rack( env )
        Rollbar.report_exception( env['sinatra.error'], request_data )
        "An error occurred and has been reported."
      end
    end
  end
end

