#!/bin/bash
if [ "$RACK_ENV" == "production" ];
then
  bundle install --without development test
  rackup config.ru -p 8080
else
  #bundle install
  if [ "$RACK_ENV" == "test" ];
  then
    rspec
  else
    #gem install shotgun
    shotgun -p 40000 -o '0.0.0.0' config.ru
  fi
fi
