#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'mongo'

conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')

m = Mongo::Connection.new(conf['mongo_host'], conf['mongo_port'])
db = m.db("#{conf['mongo_dbname']}_#{conf['user']}")

uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth(conf['user'], conf['pass'])
  http.request(req){|res|
    next if !res.chunked?
    res.read_body{|chunk|
      begin
        status = JSON.parse(chunk) 
        db['tweets'].insert(status)
      rescue
        next
      end
      begin
        puts "#{status['user']['screen_name']}: #{status['text']}"
      rescue
        p status
      end
    }
  }
end

