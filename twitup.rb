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

%w[rubygems hpricot open-uri].each {|r| require r}

user = 'holizz'

a = "http://twitter.com/#{user}?page=%d"
b = 'http://twitter.com/statuses/show/%d.xml'

ids = []
n = 1
stop = false

until stop do
  stop = true
  (Hpricot(open(a%n))/'a.entry-date').each do |c|
    i = c['href'].match(/\/(\d+)$/)[1].to_i
    unless ids.include? i
      ids << i
      stop = false
    end
  end
  n+=1
end

Dir::mkdir user rescue nil
ret = 0
for i in ids do
  open("#{user}/#{i}.xml", 'w+') do |f|
    until ret==nil do
      ret = f.write(open(b%i).read) rescue nil
    end
  end
end
