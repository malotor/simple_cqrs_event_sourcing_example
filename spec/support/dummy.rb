

class SerializableEvent < SimpleEventSourcing::Events::Event

  def serialize
    {"aggregate_id" => aggregate_id, "occurred_on" => occurred_on }
  end

end

class DummyEvent < SerializableEvent
  attr_reader :a_new_value, :other_value

  def initialize(args)
    @a_new_value = args[:a_new_value]
    @other_value = args[:other_value]
    super(args)
  end

  def serialize
    super.merge("a_new_value" => a_new_value, "other_value" => other_value  )
  end

  def to_json(*a)
    serialize.to_json(*a)
  end

end


class DummyClass

  include SimpleEventSourcing::AggregateRoot::Base


  attr_accessor :a_field,:other_field

  def a_field
    @a_field || :dummy_default_value
  end

  def a_method(a_value, other_value)
    apply_record_event DummyEvent, a_new_value: a_value, other_value: other_value
  end

  on DummyEvent do |event|
    puts event.inspect
    @a_field = event.a_new_value
    @other_field = event.other_value
  end

  def publish
    publish_events { |event| SimpleEventSourcing::Events::EventDispatcher.publish(event) }
  end
end
