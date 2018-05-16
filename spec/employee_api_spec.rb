describe 'Employee API' do
  it 'should return all employee' do
    get '/employee'
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
    expect(response_data[0]['name']).to eq('Fred Flintstone')
    expect(response_data[0]['title']).to eq('Crane Operator')
    expect(response_data[0]['salary']).to eq(30_000)
  end
  it 'create an employee' do
    post '/employee',   :name => "Any Name",  :title => "Any Title",  :salary => 45000
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
    expect(response_data[0]['name']).to eq('Any Name')
    expect(response_data[0]['title']).to eq('Any Title')
    expect(response_data[0]['salary']).to eq(45000)
  end

  it 'return an employee details' do

    barney = Employee.create('Barney Rubble', 'Crane Operator', 10_000.0)
    app.employee_repository.save barney

    get "/employee/#{barney.id}"
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
    expect(response_data[0]['name']).to eq('Barney Rubble')
    expect(response_data[0]['title']).to eq('Crane Operator')
    expect(response_data[0]['salary']).to eq(10000)
  end
end
