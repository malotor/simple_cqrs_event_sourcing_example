RSpec.describe "An event store" do

  before(:each) do
    @redis_client = RedisClientMock.new
    @event_store = EventStore::RedisEventStore.new(@redis_client)
  end

  it 'persist an event an aggregate from its id' do

    event = NewEmployeeIsHiredEvent.new(
      aggregate_id: '4bb20d71-3002-42ea-9387-38d6838a2cb7',
      name: 'Fred Flintstone',
      title:'Crane Operator',
      salary: 30000
    )

    @event_store.commit event

    expect(@redis_client.entries.count).to eq 1
  end


  it 'recover and event history from id' do


    @time_now = Time.at(1402358400)

    Timecop.freeze(@time_now) do
      @event_store.commit event = NewEmployeeIsHiredEvent.new(
        aggregate_id: '4bb20d71-3002-42ea-9387-38d6838a2cb7',
        name: 'Fred Flintstone',
        title:'Crane Operator',
        salary: 30000
      )
      @event_store.commit SalaryHasChangedEvent.new(
        aggregate_id:  '4bb20d71-3002-42ea-9387-38d6838a2cb7',
        new_salary: 40000
      )

      event_history = @event_store.get_history '4bb20d71-3002-42ea-9387-38d6838a2cb7'

      expect(event_history.count).to eq 2
      expect(event_history[0].class).to eq NewEmployeeIsHiredEvent
      expect(event_history[0].name).to eq 'Fred Flintstone'
      expect(event_history[0].title).to eq 'Crane Operator'
      expect(event_history[0].salary).to eq 30000

      expect(event_history[1].class).to eq SalaryHasChangedEvent
      expect(event_history[1].new_salary).to eq 40000
    end


  end
end
