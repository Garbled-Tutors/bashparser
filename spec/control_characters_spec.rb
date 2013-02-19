#!/usr/bin/env ruby

require_relative 'test_helper'

CARRIAGE_RETURN_CHAR = 13.chr
NEW_LINE_CHAR = 10.chr

describe "control characters" do
  before(:each) do
    @text_parser = BashParser.new
  end

  def generate_ipsum_string(min_length, max_length)
    length = Random.rand(min_length..max_length)
    ipsum = LOREM_IPSUM.sample
    ipsum += LOREM_IPSUM.sample while ipsum.length < length
    ipsum[0..length]
  end

  it "should handle carriage return character" do
    pieces = [generate_ipsum_string(20,30)]
    pieces << generate_ipsum_string(5,15).upcase
    expected_end = pieces[0][ (pieces[1].length)..-1]

    #Calculate expected results and actual input
    expected = [ pieces[1] + expected_end ]
    input = pieces[0] + CARRIAGE_RETURN_CHAR + pieces[1]
    results = @text_parser.parse_input(input)

    make_assertion(results, expected, pieces)
  end

  it "should handle new line characters correctly" do
    ipsum = LOREM_IPSUM.sample(2).join
    insert_position = Random.rand(2..(ipsum.length - 2))

    expected = [ ipsum[0..(insert_position-1)] ]
    expected << ipsum[insert_position..-1]
    input = ipsum.dup.insert(insert_position,NEW_LINE_CHAR)
    results = @text_parser.parse_input(input)

    make_assertion(results,expected,[ipsum,insert_position])
  end
end

