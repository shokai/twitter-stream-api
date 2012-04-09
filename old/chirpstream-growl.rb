#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'notify'
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
      status = JSON.parse(chunk) rescue next
      #next if !status['text']
      begin
        db['tweets'].insert(status)
      rescue
        STDERR.puts e
      end
      begin
        puts "#{status['user']['screen_name']}: #{status['text']}"
        Notify.notify(status['user']['screen_name'], status['text'])
      rescue => e
        STDERR.puts e
      end
    }
  }
end

