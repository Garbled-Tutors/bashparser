#!/usr/bin/env ruby

require_relative 'test_helper'

describe "split by escape codes" do
  before(:each) do
    @text_parser = BashParser.new
  end

  it "should split strings into an array using escape codes as deliminator" do
    ipsum = LOREM_IPSUM.sample(3)
    @text_parser.parse_input(ipsum.join).should eq([ipsum.join])
    @text_parser.parse_input(ipsum.join).should_not eq(ipsum)

    input = ipsum.map { |line| line + COLOR_ESCAPE_CODES.sample }
    returned_data = BashParser.split_by_escape_codes(input.join)
    stripped_data = returned_data.map { |element| element[0] }
    ipsum.each do |item|
      stripped_data.include?(item).should eq(true)
    end
  end

  it "should not include empty strings" do
    ipsum = LOREM_IPSUM.sample(2)
    input = ipsum.dup.join( COLOR_ESCAPE_CODES.sample(2).join )

    @text_parser.parse_input(input).should eq([ipsum.join])

    returned_data = BashParser.split_by_escape_codes(input)
    stripped_data = returned_data.map { |element| element[0] }
    stripped_data.length.should eq(2)
    stripped_data.include?('').should eq(false)
  end

  it "should not end with empty strings" do
    ipsum = LOREM_IPSUM.sample
    input = ipsum + COLOR_ESCAPE_CODES.sample
    returned_data = BashParser.split_by_escape_codes(input)
    stripped_data = returned_data.map { |element| element[0] }
    stripped_data.should eq([ipsum])
  end

  it "should not begin with empty strings" do
    ipsum = LOREM_IPSUM.sample
    input = COLOR_ESCAPE_CODES.sample + ipsum
    returned_data = BashParser.split_by_escape_codes(input)
    stripped_data = returned_data.map { |element| element[0] }
    stripped_data.should eq([ipsum])
  end

  it "should return the escape code preceding the string" do
    ipsum_list = LOREM_IPSUM.sample(3)
    code_list = COLOR_ESCAPE_CODES.sample(3)
    input = (0..2).map { |i| code_list[i] + ipsum_list[i] }.join

    returned_data = BashParser.split_by_escape_codes(input)
    stripped_data = returned_data.map { |element| element[0..1] }
    expected_data = (0..2).map { |i| [ipsum_list[i], [code_list[i]] ] }
    stripped_data.should eq(expected_data)
  end

  it "should return multiple escape code preceding the string" do
    ipsum_list = LOREM_IPSUM.sample(3)
    code_list = (0..2).map { COLOR_ESCAPE_CODES.sample(rand(2,4)) }
    input = (0..2).map { |i| code_list[i].join + ipsum_list[i] }.join

    returned_data = BashParser.split_by_escape_codes(input)
    stripped_data = returned_data.map { |element| element[0..1] }
    expected_data = (0..2).map { |i| [ipsum_list[i], code_list[i] ] }
    stripped_data.should eq(expected_data)
  end

  it "should include position text appears on the screen" do
    ipsum = LOREM_IPSUM.sample
    x = rand(5,50)
    y = rand(5,50)
    escape_code = "[#{y+1};#{x+1}H"
    input = escape_code + ipsum
    results = BashParser.split_by_escape_codes(input)
    results.should eq([[ipsum, [escape_code], [x,y]]])
  end
end
