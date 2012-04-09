#!/usr/bin/env ruby
require 'rubygems'
require 'zmq'
$KCODE = 'u'

ctx = ZMQ::Context.new
sock= ctx.socket(ZMQ::SUB)
sock.connect('tcp://127.0.0.1:5000')
sock.setsockopt(ZMQ::SUBSCRIBE, 'chirp')

loop do
  puts sock.recv()
end
