#!/usr/bin/env ruby

%w[rubygems xml date set].each{|r|require r}

def get_date(file)
  parser = XML::Parser.file file
  doc = parser.parse
  DateTime.parse(doc.find('/status/created_at')[0].content)
end

if __FILE__ == $0
  unless ARGV.length >= 1
    puts "Args plx"
    exit 1
  end
  done = []
  s = ''
  ARGV.each{|a|
    Dir["#{a}*.xml"].map{|f|
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
  }
end
