#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# Copyright 2012 Shin-ya MURAKAMI <murashin _at_ gfd-dennou.org>
#
#

exit if ARGV.empty?

def cal_check_digit(l)
  ll = l[0..-2]
  n = ll.size
  sum = 0
  n.times do |s|
    i = 10 - s
    j = ll[s].to_i
    sum += i*j
  end
  cd = ( 11 - sum%11 )
  cd = case cd
       when 10
         'X'
       when 11
         '0'
       else
         cd.to_s
       end
  return cd
end

open( ARGV[0], "r", {:external_encoding=>"utf-8",
        :internal_encoding=>"utf-8"} ) do |io|
  lines = io.readlines
  lines.each do |l|
    next if /^$/ =~ l
    next if /^\#.*/ =~ l # コメント
    l.chomp!
    l.gsub!( /^978(.*)/, '\1').chop!
    cd = cal_check_digit(l)
    print "#{l}#{cd}\n"
  end
end
