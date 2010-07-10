#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'tokyotyrant'
include TokyoTyrant

begin
  conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')
rescue
  STDERR.puts 'config.yaml load error'
  exit 1
end


db = RDB::new
if !db.open('127.0.0.1', conf['ttdb'][0]['port'].to_i)
  STDERR.puts 'error - tokyotyrant : '+db.errmsg(db.ecode)
  exit 1
end

uri = URI.parse('http://stream.twitter.com/1/statuses/filter.json')
Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Post.new(uri.request_uri)
  req.basic_auth(conf['user'], conf['pass'])
  req.set_form_data('track' => ARGV.join(' '))
  http.request(req){|res|
    next if !res.chunked?
    res.read_body{|chunk|
      puts chunk
      now = Time.now
      db["#{now.to_i}_#{now.usec}"] = chunk
    }
  }
end

