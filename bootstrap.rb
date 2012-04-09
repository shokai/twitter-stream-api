require 'rubygems'
require 'yaml'
require 'rainbow'

[:helper].each do |cat|
  Dir.glob(File.dirname(__FILE__)+"/#{cat}/*").each do |f|
    puts "loading #{f}"
    require f
  end
end

@@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')

if __FILE__ == $0
  puts 'ok'
  puts color_code 'hoge'
end
