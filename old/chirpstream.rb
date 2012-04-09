#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'

conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')

uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth(conf['user'], conf['pass'])
  http.request(req){|res|
    next if !res.chunked?
    res.read_body{|chunk|
      status = JSON.parse(chunk) rescue next
      #next if !status['text']
      user = status['user']
      begin
        puts "#{status['user']['screen_name']}: #{status['text']}"
      rescue
        p status
      end
    }
  }
end

