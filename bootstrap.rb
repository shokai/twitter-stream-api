require 'rubygems'
require 'yaml'
require 'rainbow'

@@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml')

def color_code(str)
    colors = Sickill::Rainbow::TERM_COLORS.keys - [:default, :black, :white]
    n = str.each_byte.map{|c| c.to_i}.inject{|a,b|a+b}
    return colors[n%colors.size]
end