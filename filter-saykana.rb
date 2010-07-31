#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'net/http'
require 'uri'
require 'json'
require 'yaml'
require 'MeCab'
$KCODE = 'u'

conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')
mecab = MeCab::Tagger.new('-Ochasen')

uri = URI.parse('http://stream.twitter.com/1/statuses/filter.json')
Net::HTTP.start(uri.host, uri.port) do |http|
  req = Net::HTTP::Post.new(uri.request_uri)
  req.basic_auth(conf['user'], conf['pass'])
  req.set_form_data('track' => ARGV.join(' '))
  http.request(req){|res|
    next if !res.chunked?
    res.read_body{|chunk|
      status = JSON.parse(chunk) rescue next
      next if !status['text']
      puts "#{status['user']['screen_name']}: #{status['text']}"
      begin
        puts kana = mecab.parse(status['text']).map{|i|
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

