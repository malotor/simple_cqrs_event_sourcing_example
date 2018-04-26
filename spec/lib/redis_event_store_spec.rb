RSpec.describe "An event store" do

  before(:each) do
    @redis_client = RedisMock.new
    @event_store = RedisEventStore.new(@redis_client)
  end

  it 'persist an event an aggregate from its id' do

    event = DummyEvent.new(aggregate_id: "an_id", a_new_value: 44, other_value: 55)

    @event_store.commit event

    expect(@redis_client.entries.count).to eq 1
  end


  it 'recover and event history from id' do

    @event_store.commit DummyEvent.new(aggregate_id: "an_id", a_new_value: 44, other_value: 55)
    @event_store.commit DummyEvent.new(aggregate_id: "an_id", a_new_value: 22, other_value: 33)

    event_history = @event_store.get_history "an_id"

    expect(event_history.count).to eq 2
    expect(event_history[0].class).to eq DummyEvent
    expect(event_history[0].a_new_value).to eq 44
    expect(event_history[0].other_value).to eq 55

    expect(event_history[1].class).to eq DummyEvent
    expect(event_history[1].a_new_value).to eq 22
    expect(event_history[1].other_value).to eq 33
  end
end
