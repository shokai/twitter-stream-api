require 'rubygems'
require 'rainbow'

def color_code(str)
    colors = Sickill::Rainbow::TERM_COLORS.keys - [:default, :black, :white]
    n = str.each_byte.map{|c| c.to_i}.inject{|a,b|a+b}
    return colors[n%colors.size]
end

class String
  def colorize(pattern)
    self.split(/(#{pattern})/).map{|term|
      if term =~ /#{pattern}/
        term = term.color(color_code term).bright.underline
      end
      term
    }.join('')
  end
end
