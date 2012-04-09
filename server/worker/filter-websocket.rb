#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/../../bootstrap'
require 'eventmachine'
require 'em-websocket'
require 'user_stream'
require 'json'
require 'uri'

YAML::load(open(File.dirname(__FILE__)+'/../config.yaml')).each do |k,v|
  @@conf[k] = v
end

UserStream.configure do |config|
  config.consumer_key = @@conf['consumer_key']
  config.consumer_secret = @@conf['consumer_secret']
  config.oauth_token = @@conf['access_token']
  config.oauth_token_secret = @@conf['access_secret']
end

puts "track \"#{@@conf['track'].join(',')}\""

port = URI.parse(@@conf['websocket']).port

@@channel = EM::Channel.new
EM::run do
  EM::WebSocket.start(:host => '0.0.0.0', :port => port) do |ws|
    ws.onopen do
      sid = @@channel.subscribe do |mes|
        ws.send mes
      end
      puts "* new websocket client <#{sid}> connected"
      ws.onmessage do |mes|
        puts "* websocket client <#{sid}> says : #{mes}"
      end
      
      ws.onclose do
        @@channel.unsubscribe sid
        puts "* websocket client <#{sid}> closed"
      end
    end
  end
  puts "start WebSocket server - port #{port}"

  EM::defer do
    c = UserStream::Client.new
    c.endpoint = 'https://stream.twitter.com/'
    c.post('/1/statuses/filter.json', {:track => @@conf['track'].join(',')}) do |s|
      begin
        line = "@#{s.user.screen_name} : #{s.text}"
        Log.puts "#{line} - http://twitter.com/#{s.user.screen_name}/status/#{s.id}"
        @@channel.push s.to_json
        puts line.split(/(@[a-zA-Z0-9_]+)/).map{|term|
          if term =~ /@[a-zA-Z0-9_]+/
            term = term.color(color_code term).bright.underline
          end
          term
        }.join('')
      rescue => e
        Log.puts "error : #{e}"
      end
    end
  end
end

