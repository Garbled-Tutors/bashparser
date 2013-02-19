module DebugCode
  DEBUG_LINE_NUMBERS = nil
  #DEBUG_LINE_NUMBERS = (19..24).to_a
  
  def save_all_input_to_file(file_name)
    #used for debugging purposes
    File.open(file_name, 'w') do |f|
      @all_input.dup.each_byte do |byte|
        f.putc(byte)
      end
    end
  end

  def self.save_input_to_file(input, file_name)
    #used for debugging purposes
    File.open(file_name, 'w') do |f|
      input.dup.each_byte do |byte|
        f.putc(byte)
      end
    end
  end

  def debug_line(line_number_array, byte)
    p "Writing byte (#{byte}) '#{byte.chr}' #{@screen.get_cursor_position} ~#{@escape_code}"
    buffer = @screen.get_buffer_contents
    buffer.each_index { |index| p "#{index}: #{buffer[index]}" if line_number_array.include?(index) }
    p ''
  end
end
