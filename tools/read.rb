#!/usr/bin/env ruby

%w[rubygems xml date set].each{|r|require r}

def get_tweet(file)
  parser = XML::Parser.file file
  doc = parser.parse
  [doc.find('/status/id')[0].content,
    DateTime.parse(doc.find('/status/created_at')[0].content),
   doc.find('/status/text')[0].content]
end

if __FILE__ == $0
  unless ARGV.length >= 1
    puts "Args plx"
    exit 1
  end
  ARGV.each{|a|
    Dir["#{a}/*.xml"].sort.map{|f|
      get_tweet(f)
    }.sort.each{|tid,time,text|
      puts "#{tid} #{time.strftime}"
      puts text
      puts
    }
  }
end
