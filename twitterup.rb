#!/usr/bin/env ruby
#
# Copyright (c) 2008 Tom Adams
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

%w[rubygems hpricot open-uri net/http].each {|r| require r}

class Twiterup
  PAGE = "http://twitter.com/%s?page=%d"
  STATUS = 'http://twitter.com/statuses/show/%d.xml'

  def initialize(user,dir=nil)
    @user = user
    @dir = dir ? dir : user
  end

  def page(n)
    PAGE % [@user,n]
  end

  def file(i)
    "#{@dir}/#{i}.xml"
  end

  def saveid(i)
    saveid!(i) unless File.exist?(file(i))
  end

  def saveid!(i)
    tweet = open(STATUS%i).read
    if tweet.length==0
      raise Exception, 'oops WTF?'
    else
      open(file(i), 'w+') do |f|
        f.write(tweet)
      end
    end
  end

  def iterids
    ids = []
    n = 1
    stop = false

    until stop do
      stop = true
      (Hpricot(open(page(n)))/'a.entry-date').each do |a| # each perma-link
        i = a['href'].match(/\/(\d+)$/)[1].to_i # .../status/#{i}
        unless ids.include? i # latest tweet appears at top of each page
          yield i
          stop = false
        end
      end
      n+=1
      # if stop is still true here, we have found zero new tweets
    end
  end

  def backup
    iterids do |i|
      saveid(i)
    end
  end

  def backup!
    iterids do |i|
      saveid!(i)
    end
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    puts 'Usage: twiterup username directory'
    exit
  end
  t = Twiterup.new(ARGV[0], ARGV[1])
  t.backup
end