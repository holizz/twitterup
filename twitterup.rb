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

# Twitterup: Authenticationless backup of your tweets from Twitter.

%w[rubygems hpricot open-uri net/http].each {|r| require r}

class Twiterup
  PAGE = "http://twitter.com/%s?page=%d"
  STATUS = 'http://twitter.com/statuses/show/%d.xml'
  PAGE_LC = "http://%s/api/statuses/user_timeline/%s.xml?page=%d"
  STATUS_LC = 'http://%s/api/statuses/show/%d.xml'

  def initialize(user,dir=nil,laconica=nil)
    @user = user
    @dir = dir ? dir : user
    @lc = laconica
  end

  def page(n)
    @lc ? (PAGE_LC % [@lc, @user, n]) : (PAGE % [@user,n])
  end

  def file(i)
    "#{@dir}/#{i}.xml"
  end

  def saveid(i)
    saveid!(i) unless File.exist?(file(i))
  end

  def saveid!(i)
    uri = @lc ? (STATUS_LC % [@lc, i]) : (STATUS%i)
    tweet = open(uri).read
    open(file(i), 'w+') do |f|
      f.write(tweet)
    end
  end

  def iterids
    ids = []
    n = 1
    stop = false

    until stop do
      stop = true
      (Hpricot(open(page(n)))/(@lc ? 'status/id' : 'a.entry-date')).each do |a| # each perma-link
        if @lc
          i = a.inner_html
        else
          i = a['href'].match(/\/(\d+)$/)[1].to_i # .../status/#{i}
        end
        unless ids.include? i # latest tweet appears at top of each page
          yield i
          stop = false
        end
      end
      n+=1
      # if stop is still true here, we have found zero new tweets
    end
  end

  def backup(safe=true)
    unless File.exist?(@dir) and File.directory?(@dir)
      raise Exception, "please create #{@dir} manually"
    end
    iterids do |i|
      if safe
        saveid(i)
      else
        saveid!(i)
      end
    end
  end

  def backup!
    backup(safe=false)
  end
end

if __FILE__ == $0
  if ARGV.length == 0
    puts 'Usage: ruby twiterup.rb username directory [-l laconica-server]'
    exit
  end

  # This is overly simplistic - -l domain must be the last arguments
  laconica = nil
  if ARGV.length > 2
    if ARGV[2] == '-l'
      laconica = ARGV[3]
    end
  end

  t = Twiterup.new(ARGV[0], ARGV[1], laconica=laconica)

  begin
    t.backup
  rescue OpenURI::HTTPError => exception
    if exception.to_s == '400 Bad Request'
      puts "You've reached Twitter's hourly limit!"
      puts "I suggest running this as a cron job."
      exit
    else
      raise exception
    end
  end
end
