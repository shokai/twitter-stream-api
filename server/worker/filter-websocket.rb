#!/usr/bin/env ruby
require File.dirname(__FILE__)+'/../../bootstrap'
require 'eventmachine'
require 'em-websocket'
require 'user_stream'
require 'ArgsParser'

parser = ArgsParser.parser
parser.bind(:help, :h, 'show help')
parser.bind(:port, :p, 'websocket port', 8081)
parser.bind(:track, :t, 'track word(s)', 'http')
first, params = parser.parse ARGV

if parser.has_option(:help)
  puts parser.help
  puts "e.g.  ruby #{$0} --port 8081"
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
  puts "start WebSocket server - port #{params[:port].to_i}"

  EM::defer do
    c = UserStream::Client.new
    c.endpoint = 'https://stream.twitter.com/'
    c.post('/1/statuses/filter.json', {:track => params[:track]}) do |s|
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

