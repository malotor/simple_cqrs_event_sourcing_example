class BaseController < Sinatra::Base
  include ServiceProvider::ContainerAware
  # Run the following before every API request
  before do
    content_type :json
    #permit_authentication
  end
end
