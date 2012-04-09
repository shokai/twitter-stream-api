## logger

class Log
  def self.filename
    @@filename ||= "#{Time.now.to_i}.log"
  end

  def self.write(str)
    open(self.filename, 'a+') do |f|
      f.write str
    end
  end

  def self.puts(str)
    self.write(str+"\n")
  end
end
