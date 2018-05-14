require 'sinatra'


class MyApp < Sinatra::Base
  get "/" do
    content_type :json
    { :foo => 'bar' }.to_json
  end
end
