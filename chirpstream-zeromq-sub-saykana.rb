#!/usr/bin/env ruby
require 'rubygems'
require 'zmq'
require 'json'
require 'MeCab'
$KCODE = 'u'

mecab = MeCab::Tagger.new('-Ochasen')

ctx = ZMQ::Context.new
sock= ctx.socket(ZMQ::SUB)
sock.connect('tcp://127.0.0.1:5000')
sock.setsockopt(ZMQ::SUBSCRIBE, 'chirp')

loop do
  str = sock.recv()
  chunk = str.scan(/chirp (.+)/).first.first
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
end
