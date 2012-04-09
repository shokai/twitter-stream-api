Twitter Stream API test
=======================


Install Dependencies
--------------------

    % gem install bundler
    % bundle install


Config
------

    % cp sample.config.yaml config.yaml


Auth
----

    % ruby bin/auth.rb


UserStream
----------

    % ruby bin/userstream.rb


Filter
------

    % ruby -Ku bin/filter.rb "ruby"