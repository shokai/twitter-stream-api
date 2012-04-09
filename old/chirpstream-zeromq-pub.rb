#!/usr/bin/env ruby
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'kconv'
require 'zmq'
$KCODE = 'u'

conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')

ctx = ZMQ::Context.new
sock = ctx.socket(ZMQ::PUB)
sock.bind('tcp://127.0.0.1:5000')

uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth(conf['user'], conf['pass'])
  http.request(req){|res|
    next if !res.chunked?
    res.read_body{|chunk|
      status = JSON.parse(chunk) rescue next
      sock.send("chirp #{chunk}")
      begin
        puts "#{status['user']['screen_name']}: #{status['text']}"
      rescue => e
        p status
        STDERR.puts e
      end
    }
  }
end
