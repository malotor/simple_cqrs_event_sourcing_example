# Simple Event Sourcing example

This is a example of how to use the Simple Event Sourcing gem [https://rubygems.org/gems/simple_event_sourcing].

# Usage

    $ docker-compose build
    $ docker-compose up -d
    $ alias run='docker-compose exec web'
    $ run rake db:migrate
    $ run rake db:migrate RACK_ENV=test
    $ run rspec --tag integration
    $ run rake -T
    $ run tux
    $ run rake app:create_fixtures

# Problem with elasticsearch

    $ sudo sysctl -w vm.max_map_count=262144

# Redis UI

  http://localhost:50000

# kibana

  http://localhost:5601/
