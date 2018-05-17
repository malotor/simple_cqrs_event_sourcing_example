class JsonApiApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension



  # Run the following before every API request
  before do
    content_type :json
    #permit_authentication
  end

  not_found do
    status 404
    { type: "404", message: 'Resource not found' }.to_json
  end

  error do
    raise request.env['sinatra.error'] if self.class.test?

    status 500
    e = env['sinatra.error']
    url = request.url
    ip = request.ip
    backtrace = "Application error\n#{e}\n#{e.backtrace.join("\n")}"
    actlogpassblock = {  :message => e.message,
                          :path => url,
                          :ip => ip,
                          :timestamp => Time.new,
                          :type => "500",
                          :backtrace => backtrace
                        }
    #action_log.insert(@actlogpassblock)
    {:message => actlogpassblock }.to_json
  end
end
