# Simple Event Sourcing example

This is a example of how to use the Simple Event Sourcing gem [https://rubygems.org/gems/simple_event_sourcing].

# Usage

    $ docker-compose build
    $ docker-compose up -d
    $ alias run='docker-compose exec web'
    $ run rake db:migrate
    $ run rake db:migrate RACK_ENV=test
    $ run rspec
    $ run rake -T
    $ run tux
