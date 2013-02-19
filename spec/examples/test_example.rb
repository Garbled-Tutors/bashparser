#!/usr/bin/env ruby
require 'bashparser'

if ARGV.length == 1
  file_location = File.dirname(__FILE__)
  file_location = '' if file_location == '.'
  file_location += ARGV[0]
  text_parser = BashParser.new
  input = ''
  file = File.open( file_location, 'r')
  file.each_byte do |byte|
    input += byte.chr
  end
  text_parser.parse_input(input).each {|line| p line }
else
  p "incorrect arguments"
end
