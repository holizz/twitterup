#!/usr/bin/env ruby

%w[rubygems xml date set].each{|r|require r}

def get_tweet(file)
  parser = XML::Parser.file file
  doc = parser.parse
  [DateTime.parse(doc.find('/status/created_at')[0].content),
   doc.find('/status/text')[0].content]
end

if __FILE__ == $0
  done = []
  Dir['/store/backup/live/twitter/holizz/*.xml'].sort.map{|f|
    get_tweet(f)
  }.sort.each{|time,text|
    puts time.strftime
    puts text
    puts
  }
end
