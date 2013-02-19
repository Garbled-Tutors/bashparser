#!/usr/bin/env ruby

require_relative 'test_helper'

describe "cursor positioning" do
  before(:each) do
    @text_parser = BashParser.new
  end

  it "should handle ESCAPE [y;xH" do
    ipsum = LOREM_IPSUM.sample
    x = rand(5,50)
    y = rand(5,50)
    escape_code = "#{ESCAPE_CHAR}[#{y+1};#{x+1}H"
    input = escape_code + ipsum
    results = @text_parser.parse_input(input)

    results[y].strip.should eq(ipsum)
    results[y][0..x-1].should eq(' ' * x)
  end
end

