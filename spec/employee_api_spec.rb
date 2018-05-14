describe 'Employee API' do

	it 'should return all employee' do
		get '/employee'
		response_data = JSON.parse(last_response.body)
		expect(last_response).to be_ok
		expect(last_response.content_type).to eq('application/json')
		expect(response_data[0]['name']).to eq('Fred Flinstone')
		expect(response_data[0]['title']).to eq('Crane Operator')
		expect(response_data[0]['salary']).to eq(30000)
	end

end
