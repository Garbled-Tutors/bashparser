require_relative '../lib/bashparser'

ESCAPE_CHAR = 27.chr
COLOR_ESCAPE_CODES = ['', '39;49', '0;1'].map { |c| ESCAPE_CHAR + "[#{c}m" }
LOREM_IPSUM = ['Nam augue augue, ultrices at ullamcorper non',
  'condimentum eget enim', 'Maecenas eget quam id elit vestibulum',
  'egestas id vitae quam', 'Proin tristique, libero fringilla adipiscing iaculis',
  'ante elit iaculis turpis']

def rand(min, max)
  Random.new.rand(min..max)
end

def make_assertion(results, expected, error_notes, show_notes = false)
  p "Checking #{results}, NOTES: #{error_notes}" if show_notes
  p "ERROR NOTES: #{error_notes}" if results != expected
  results.should eq(expected)
end

def save_debug_file(file_name, file_contents, display_notes)
  BashParser.save_input_to_file(file_contents,file_name)
  p display_notes
end

def parse_and_loose_compare(input_file, expected_results_file)
  text_parser = BashParser.new
  input = ''
  file = File.open( File.dirname(__FILE__) + input_file, 'r')
  file.each_byte do |byte|
    input += byte.chr
  end
  result = text_parser.parse_input(input)

  expected = []
  file = File.open( File.dirname(__FILE__) + expected_results_file, 'r')
  file.each do |line|
    expected << line.chomp
  end

  loose_compare_screens(result, expected)
end

def loose_compare_screens(result, expected)
  temp_result = result.map { |line| line.rstrip }
  temp_expected = expected.map { |line| line.rstrip }

  if temp_result != temp_expected
    notes = get_array_comparison_notes(temp_result, temp_expected)
    screens = notes.dup

    length_array = notes.map do |item|
      [(item[1] || '').length, (item[2] || '').length].max
    end
    max_length = length_array.max
    screens.map! { |item| item unless item[1] == '' and item[2] == '' }
    screens.delete(nil)
    screens.map! { |item| [item[0], combine_strings(item[2], item[1], max_length) ] }
    screens.each { |item| p item.join(': ') }

    notes.each { |item| compare_array_lines(item[0],item[1],item[2]) }
  end
end

def combine_strings(string1, string2, maxlength)
  extra_whitspace = maxlength - (string1 || '').length
  ((string1 || '') + ' ' * extra_whitspace) + ' | ' + string2
end

def compare_screens(result, expected)
  if result != expected
    skip_head = true
    first_error = nil
    notes = get_array_comparison_notes(expected, result)
    notes.each do |item| 
      skip_head = false if item[1].dup.strip != ''
      unless skip_head
        p "E #{item[0]}: #{item[1]}"
        if item[1] != item[2]
          p "R #{item[0]}: #{item[2]}"
          first_error = item[1..2] unless first_error
        end
      end
    end
    first_error[0].should eq first_error[1]
  end
end

def compare_array_lines(line_number, line_a, line_b)
  result = "#{line_number}: #{line_a}"
  expected = "#{line_number}: #{line_b}"
  result.should eq expected
end

def get_array_comparison_notes(array_a, array_b)
  notes = []
  array_a.each_index { |index| notes << [index, array_a[index], array_b[index]] }
  notes
end
