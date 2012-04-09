#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'user_stream'

conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')

UserStream.configure do |config|
  config.consumer_key = conf['consumer_key']
  config.consumer_secret = conf['consumer_secret']
  config.oauth_token = conf['access_token']
  config.oauth_token_secret = conf['access_secret']
end

c = UserStream::Client.new
c.user do |s|
  p s
end
