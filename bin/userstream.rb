#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/../bootstrap'
require 'user_stream'

UserStream.configure do |config|
  config.consumer_key = @@conf['consumer_key']
  config.consumer_secret = @@conf['consumer_secret']
  config.oauth_token = @@conf['access_token']
  config.oauth_token_secret = @@conf['access_secret']
end

c = UserStream::Client.new
c.user do |s|
  begin
    line = "@#{s.user.screen_name} : #{s.text}"
    puts line.colorize(/@[a-zA-Z0-9_]+/)
  rescue => e
    p s
  end
end
