#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
#
# http://d.hatena.ne.jp/idesaku/20100402/1270201594
#

gem 'ruby-openid'
gem 'nokogiri'

require 'cgi'
require 'net/http'
require 'openssl'
require 'nokogiri'

ACCESS_KEY_ID='----'     # 設定すること
SECRET_ACCESS_KEY='----' # 設定すること
ASSOCIATE_TAG='----'     # 設定すること
AWS_API_HOST='webservices.amazon.co.jp'
AWS_API_PATH='/onca/xml'
AWS_API_VERSION='2011-08-01'
ISBN13 = ARGV[0]

params = [
          ["Service", "AWSECommerceService"],
          ["AWSAccessKeyId", ACCESS_KEY_ID],
          ["ItemId", ISBN13],
          ["IdType", "ISBN"],
          ["Operation", "ItemLookup"],
          ["SearchIndex", "Books"],
          ["ResponseGroup", "ItemAttributes"],
          ["AssociateTag", ASSOCIATE_TAG],
          ["Version", AWS_API_VERSION],
          ["Timestamp", Time.now.gmtime.strftime('%Y-%m-%dT%H:%M:%SZ')]
         ].map { |k,v| "#{k}=#{CGI.escape(v)}" }.sort.join("&")

string_to_sign = %W(
GET
#{AWS_API_HOST}
#{AWS_API_PATH}
#{params}
).join("\n")

signature = CGI.escape([OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new,
                                              SECRET_ACCESS_KEY,
                                              string_to_sign)].pack("m").chomp)

path = '%s?%s&Signature=%s' % [AWS_API_PATH, params, signature]

body = Nokogiri(Net::HTTP.get(AWS_API_HOST, path))

errors = body / "Error"
unless errors.empty?
  errors.map { |error|
    puts "%s: %s" % [(error % "Code").text, (error % "Message").text]
  }
else
  (body % "Item").tap {|item|
    _author = (item / "Author")
    _creator = (item / "Creator")
    author = if _author.text.empty?
               _creator.map{|c| "#{c.text}(#{c.attribute("Role").text})" }.join(",")
             else
               _author.map(&:text).join(",")
             end
    puts "#{(item % "Title").text}(#{author})"
  }
end
