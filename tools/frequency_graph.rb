#!/usr/bin/env ruby

%w[rubygems xml date set].each{|r|require r}

def get_date(file)
  parser = XML::Parser.new
  parser.file = file
  doc = parser.parse
  DateTime.parse(doc.find('/status/created_at')[0].content)
end

if __FILE__ == $0
  done = []
  s = ''
  Dir['/store/backup/live/twitter/holizz/*.xml'].map{|f|
    get_date f
  }.sort.each{|d|
    this_month = d.strftime('%Y-%m')
    unless done.include? this_month
      done << this_month
      s << "\n" unless done.length==1
      s << d.strftime('%Y-%m')+': -'
    else
      s << '-'
    end
  }
  puts s
end
