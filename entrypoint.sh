#!/bin/sh

bundle exec rake db:migrate
bundle exec smashing start -p 3000 -e production
