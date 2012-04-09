#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/../bootstrap'
require 'ArgsParser'
require 'eventmachine'
require 'em-websocket'
require 'user_stream'
require 'json'
require 'uri'

parser = ArgsParser.parser
parser.bind(:port, :p, 'websocket port', 8081)
parser.bind(:track, :t, 'track word(s)', 'ruby,javascript')
parser.comment(:nolog, 'no logfile')
parser.bind(:help, :h, 'show help')

first, params = parser.parse ARGV

if parser.has_option(:help)
  puts parser.help
  puts "e.g.  ruby #{$0} --track 'ruby,javascript' --port 8081"
  exit 1
end

UserStream.configure do |config|
  config.consumer_key = @@conf['consumer_key']
  config.consumer_secret = @@conf['consumer_secret']
  config.oauth_token = @@conf['access_token']
  config.oauth_token_secret = @@conf['access_secret']
end

puts "track \"#{params[:track]}\""

@@channel = EM::Channel.new

EM::run do
  EM::WebSocket.start(:host => '0.0.0.0', :port => params[:port].to_i) do |ws|
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
  puts "start WebSocket server - port #{params[:port]}"

  EM::defer do
    c = UserStream::Client.new
    c.endpoint = 'https://stream.twitter.com/'
    c.post('/1/statuses/filter.json', {:track => params[:track]}) do |s|
      begin
        puts line = "@#{s.user.screen_name} : #{s.text}"
        Log.puts "#{line} - http://twitter.com/#{s.user.screen_name}/status/#{s.id}" unless params[:nolog]
        @@channel.push s.to_json
      rescue => e
        Log.puts "error : #{e}" unless params[:nolog]
      end
    end
  end
end
