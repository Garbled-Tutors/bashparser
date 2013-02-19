#!/usr/bin/env ruby

require_relative 'test_helper'

describe "basic functions" do
  before(:each) do
    @text_parser = BashParser.new
  end

  it "should reads and returns strings without escape codes" do
    input = LOREM_IPSUM.sample
    @text_parser.parse_input(input).should eq([input])
    BashParser.parse_input(input).should eq([input])
  end

  it "should reset buffer should delete previous content" do
    input = LOREM_IPSUM.sample
    @text_parser.parse_input(input)
    @text_parser.parse_input('').should eq([input])

    @text_parser.reset_buffer
    @text_parser.parse_input("").should_not eq([input])
  end

  it "should ignores color escape codes" do
    5.times do
      ipsum = LOREM_IPSUM.sample
      position = rand(0,ipsum.length)
      input = ipsum.dup
      input.insert(position, COLOR_ESCAPE_CODES.sample)
      @text_parser.reset_buffer
      @text_parser.parse_input(input)
      @text_parser.parse_input('').should eq([ipsum])
      BashParser.parse_input(input).should eq([ipsum])
    end
  end
end


