#!/usr/bin/env ruby

require_relative 'test_helper'

describe "escape r (scrolling)" do
  DEBUGGING = false
  CHECKING_RESULTS = false

  before(:each) do
    @text_parser = BashParser.new
  end

  def escape_r(scroll_start,scroll_end)
    "#{ESCAPE_CHAR}[#{scroll_start};#{scroll_end}r"
  end

  def move_cursor(new_x_position, new_y_position)
    "#{ESCAPE_CHAR}[#{new_y_position};#{new_x_position}H"
  end

  def generate_text_at_position(x,y)
    ipsum = LOREM_IPSUM.sample
    input = "#{ESCAPE_CHAR}[#{y};#{x}H#{ipsum}"
    {input: input, ipsum: ipsum}
  end

  def generate_input(text_range, scroll_range, cursor_new_y)
    data = (text_range[0]..text_range[1]).to_a
    data.map! { |i| generate_text_at_position(1,i) }
    text_code = data.map { |item| item[:input] }.join
    scroll_code = escape_r(scroll_range[0],scroll_range[1])
    input = text_code + scroll_code + move_cursor(1,cursor_new_y)
    ipsum = data.map { |item| item[:ipsum] }
    [input, ipsum, data]
  end

  it "should scroll up" do
    input, ipsum, data = generate_input( [2,4], [2,4], 4)
    expected = [''] + ipsum[1..-1] + ['']
    save_debug_file('escape_r_scroll_up',input,expected) if DEBUGGING
    results = @text_parser.parse_input(input)
    make_assertion(results,expected,{ipsum: ipsum, input: input}, CHECKING_RESULTS)
  end

  it "should scroll lines within range" do
    input, ipsum, data = generate_input( [2,4], [2,3], 3)
    expected = [''] + [ipsum[1]] + [''] + [ipsum[2]]
    save_debug_file('escape_r_scroll_range',input,expected) if DEBUGGING
    results = @text_parser.parse_input(input)
    make_assertion(results,expected,{ipsum: ipsum, input: input}, CHECKING_RESULTS)
  end

  it "shouldnt scroll when out of range" do
    input, ipsum, data = generate_input( [2,4], [2,3], 4)
    expected = [''] + ipsum
    save_debug_file('escape_r_scroll_range',input,expected) if DEBUGGING
    results = @text_parser.parse_input(input)
    make_assertion(results,expected,{ipsum: ipsum, input: input}, CHECKING_RESULTS)
  end
end

