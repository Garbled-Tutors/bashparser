#!/usr/bin/env ruby

require_relative 'test_helper'

describe "constants" do
  it "should should not have former bugs" do
    parse_and_loose_compare('/examples/bugreport_input','/examples/bugreport_expected')
  end
end
