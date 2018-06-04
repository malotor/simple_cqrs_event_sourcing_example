RSpec.describe 'An employee repository' do
  # SimpleEventSourcing::Events::EventStore::RedisClient.configure do |config|
  #   config.mock = true
  # end

  let(:spy_subscriber) { @subscribers[0] }

  before(:each) do
    @fred = Employee.create('8aa14c4f-5244-43f7-a2ba-f83c1327d669', 'Fred Flintstone', 'Crane Operator', 30_000.0)
    @fred.promote 35_000
    @employee_repository = EmployeeRepository.new(
      SimpleEventSourcing::Events::EventStore::RedisEventStore.new(
        SimpleEventSourcing::Events::EventStore::RedisClient.get_client
      )
    )
    @subscribers = []
    @subscribers << spy(:spy_subscriber)
    @subscribers.each do |s|
      SimpleEventSourcing::Events::EventDispatcher.add_subscriber(s)
      allow(s).to receive(:handle)
      allow(s).to receive(:is_subscribet_to?).and_return(true)
    end
  end

  after(:each) do
    @subscribers.each { |s| SimpleEventSourcing::Events::EventDispatcher.delete_subscriber(s) }
  end

  it 'recoveres an employee from its id' do
    @employee_repository.save @fred

    recovered_employee = @employee_repository.findById @fred.id

    expect(recovered_employee.name).to eq 'Fred Flintstone'
    expect(recovered_employee.title).to eq 'Crane Operator'
    expect(recovered_employee.salary).to eq 35_000

    recovered_employee.promote 40_000

    @employee_repository.save recovered_employee

    second_recovered_employee = @employee_repository.findById recovered_employee.id

    expect(second_recovered_employee.name).to eq 'Fred Flintstone'
    expect(second_recovered_employee.title).to eq 'Crane Operator'
    expect(second_recovered_employee.salary).to eq 40_000
  end

  it 'dispatch employee recorded events to their subscribers' do
    @employee_repository.save @fred
    expect(spy_subscriber).to have_received(:handle).with(instance_of(NewEmployeeIsHiredEvent)).ordered
    expect(spy_subscriber).to have_received(:handle).with(instance_of(SalaryHasChangedEvent)).ordered
  end
end
