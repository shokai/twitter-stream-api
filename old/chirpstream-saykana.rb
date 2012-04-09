#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'kconv'
require 'MeCab'
$KCODE = 'u'
$VERBOSE = nil

conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')
mecab = MeCab::Tagger.new('-Ochasen')

uri = URI.parse('http://chirpstream.twitter.com/2b/user.json')
Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth(conf['user'], conf['pass'])
  http.request(req){|res|
    next if !res.chunked?
    res.read_body{|chunk|
      status = JSON.parse(chunk) rescue next
      begin
        puts "#{status['user']['screen_name']}: #{status['text']}"
      rescue => e
        p status
        STDERR.puts e
      end
      next unless status['text']
      begin
        str = status['text']
        puts kana = mecab.parse(str).map{|i|
          i.split(/\t/)[1]
        }.delete_if{|i|
          i.to_s.size < 1
        }.join('')
        `saykana '#{kana}'`
       rescue => e
        STDERR.puts e
      end
    }
  }
end
