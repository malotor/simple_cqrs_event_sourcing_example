describe 'root path' do
	before do
		get '/'
	end

	it 'should be successful' do
		expect(last_response).to be_ok
	end

	it 'should be a json response' do
		expect(last_response.content_type).to eq('application/json')
	end

	it 'should return a hello world message' do
		response_data = JSON.parse(last_response.body)
		expect(response_data['foo']).to eq('bar')
	end
end
