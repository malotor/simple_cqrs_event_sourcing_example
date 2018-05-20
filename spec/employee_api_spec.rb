describe 'Employee API' do
  it 'create an employee' do
    post '/employee', id: '8aa14c4f-5244-43f7-a2ba-f83c1327d669', name: 'Any Name', title: 'Any Title', salary: 45_000
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
    expect(response_data['name']).to eq('Any Name')
    expect(response_data['title']).to eq('Any Title')
    expect(response_data['salary']).to eq(45_000)
  end

  it 'return an employee details' do
    employee_repository = ServiceProvider::Container[:employee_repository]

    barney = Employee.create('8aa14c4f-5244-43f7-a2ba-f83c1327d669', 'Barney Rubble', 'Crane Operator', 10_000.0)
    employee_repository.save barney

    get "/employee/#{barney.id}"
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
    expect(response_data['name']).to eq('Barney Rubble')
    expect(response_data['title']).to eq('Crane Operator')
    expect(response_data['salary']).to eq(10_000)
  end

  it 'return an all employees' do
    employee_repository = ServiceProvider::Container[:employee_repository]

    employee_repository.save Employee.create('8aa14c4f-5244-43f7-a2ba-f83c1327d669', 'Fred Flintstone', 'Crane Operator', 30_000)
    employee_repository.save Employee.create('98183f0e-5e83-45c2-9bd9-2888eae34cca', 'Barney Rubble', 'Crane Operator', 10_000)

    get '/employee'
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')

    expect(response_data[0]['name']).to eq('Fred Flintstone')
    expect(response_data[0]['title']).to eq('Crane Operator')
    expect(response_data[0]['salary']).to eq(30_000)

    expect(response_data[1]['name']).to eq('Barney Rubble')
    expect(response_data[1]['title']).to eq('Crane Operator')
    expect(response_data[1]['salary']).to eq(10_000)
  end

  it 'search and employee' do
    employee_repository = ServiceProvider::Container[:employee_repository]

    employee_repository.save Employee.create('8aa14c4f-5244-43f7-a2ba-f83c1327d669', 'Fred Flintstone', 'Crane Operator', 30_000)
    employee_repository.save Employee.create('98183f0e-5e83-45c2-9bd9-2888eae34cca', 'Barney Rubble', 'Crane Operator', 10_000)

    get '/employee?name=Fred'
    response_data = JSON.parse(last_response.body)
    expect(last_response).to be_ok
    expect(last_response.content_type).to eq('application/json')
    expect(response_data.count).to eq(1)
    expect(response_data[0]['name']).to eq('Fred Flintstone')
    expect(response_data[0]['title']).to eq('Crane Operator')
    expect(response_data[0]['salary']).to eq(30_000)
  end
end
