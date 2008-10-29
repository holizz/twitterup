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

$user = 'holizz'

a = "http://twitter.com/#{$user}?page=%d"
$b = 'http://twitter.com/statuses/show/%d.xml'

def proxies
  p = []
  h = Hpricot(open('http://hidemyass.com/free_proxy_lists.php'))
  for tr in ((h/'table')[1]/'tr')[1..-1]
    if (tr/'td').length == 5
      p << [(tr/'td')[0].inner_html.strip,(tr/'td')[1].inner_html.strip]
    end
  end
  p
end

def proxify
  p = proxies[0]
  Net::HTTP.Proxy(p[0],p[1]) do
    yield
  end
end

def saveid(i)
  proxify do
    open("#{$user}/#{i}.xml", 'w+') do |f|
      f.write(open(b%i).read)
    end
  end
end

if __FILE__ == $0
  ids = []
  n = 1
  stop = false

  until stop do
    stop = true
    (Hpricot(open(a%n))/'a.entry-date').each do |c|
      i = c['href'].match(/\/(\d+)$/)[1].to_i
      unless ids.include? i
        saveid i
        stop = false
      end
    end
    n+=1
  end
end
