#http://www.termsys.demon.co.uk/vtansi.htm
require_relative 'screen_contents'
class BashParser
  #require_relative 'debug_code'
  #include DebugCode

  ESCAPE_BYTE = 27
  CARRIAGE_RETURN_BYTE = 13
  BACKSPACE_BYTE = 8
  NEW_LINE_BYTE = 10
  SPACE_BYTE = 32
  INACTIVE = nil
  CURSOR_MOVEMENT_ESCAPE_CHARS = ['H', 'J']
  DEBUG_LINE_NUMBERS = nil
  #DEBUG_LINE_NUMBERS = (19..24).to_a

  def initialize
    @screen = ScreenContents.new
    @all_input = ''
    reset_buffer
  end

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

  def reset_buffer
    @escape_code = INACTIVE
    @screen.reset_buffer
  end

  def self.display_screen(all_input)
    BashParser.new.display_screen(all_input)
  end

  def self.parse_input(input)
    BashParser.new.parse_input(input)
  end

  def display_screen(all_input = nil)
    data = []
    if all_input != nil
      reset_buffer
      data = parse_input(all_input)
    else
      data = @screen.get_buffer_contents
    end
    data.each { |line| puts line }
  end

  def get_buffer_contents
    @screen.get_buffer_contents
  end

  def parse_input(input)
    @all_input += input
    save_strings = ''
    input.each_byte do |byte|
      #ACTUAL CODE
      write_byte_to_buffer(byte) if @escape_code == INACTIVE
      read_for_escape_codes(byte)
      debug_line(DEBUG_LINE_NUMBERS,byte) if DEBUG_LINE_NUMBERS != nil
    end
    @screen.get_buffer_contents
  end

  def self.split_by_escape_codes(input)
    return_data = []
    escape_code_list = []
    @position_tracker = BashParser.new
    input = input + ESCAPE_BYTE.chr #Insures last string is inserted into return_data

    escape_code = INACTIVE
    string = ''
    input.each_byte do |byte|
      char = byte.chr

      if byte == ESCAPE_BYTE
        escape_code = ''
        if string != ''
          @position_tracker.parse_input(escape_code_list.join)
          cursor_position = @position_tracker.get_cursor_position
          @position_tracker.parse_input(string)
          return_data << [string, escape_code_list, cursor_position ]
          string = ''
          escape_code_list = []
        end
      elsif escape_code != INACTIVE
        escape_code += char
        if is_complete_escape_code(escape_code)
          escape_code_list << "#{ESCAPE_BYTE.chr}#{escape_code}"
          escape_code = INACTIVE
        end
      else
        string += char
      end
    end
    return_data
  end

  def self.is_complete_escape_code(escape_code)#assumes escape character is removed
    return false if escape_code == '' or escape_code == nil
    escape_code[-1] != escape_code[-1].dup.swapcase
  end

  def get_cursor_position
    @screen.get_cursor_position
  end

  private

  def read_for_escape_codes(byte)
    char = byte.chr
    @escape_code += char if @escape_code != INACTIVE
    @escape_code = '' if byte == ESCAPE_BYTE

    if @escape_code != INACTIVE and BashParser.is_complete_escape_code(@escape_code)
      handle_escape_code
      @escape_code = INACTIVE
    end
  end

  def write_byte_to_buffer(byte)
    if byte == CARRIAGE_RETURN_BYTE
      @screen.read_new_position('=0',nil) #hack... seems like this should be just =0, but +2 makes it work.
    elsif byte == BACKSPACE_BYTE
      @screen.delete_last_character
    elsif byte == NEW_LINE_BYTE
      @screen.read_new_position('=0','+1')
    elsif byte >= SPACE_BYTE
      @screen.add_byte(byte)
    end
  end

  def handle_escape_code
    if @escape_code == '[2J'
      reset_buffer
    elsif @escape_code == '[2S'
      @screen.delete_current_line
    elsif @escape_code == '[J'
      @screen.delete_from_cursor_to_end
    elsif @escape_code[-1] == 'r'
      rows = @escape_code[1..-2].split(';')
      rows.map! { |row| row.to_i - 1 }
      @screen.enable_scrolling(rows)
      return
    end
    x_string, y_string = get_cursor_movement(@escape_code)
    @screen.read_new_position(x_string, y_string)
  end

  def get_cursor_movement(escape_code)
    return ['*', '*'] unless escape_code
    if escape_code == '[H' or escape_code == '[2J'
      ['=0', '=0']
    elsif escape_code[-1] == 'H'
      position = escape_code[1..-2].split(';')
      position.map { |coordinate| "=#{coordinate.to_i - 1}" }.reverse
    elsif escape_code[-1] == 'd'
      distance = escape_code[1..-2].to_i
      ['*', "=#{distance - 1}"]
    elsif escape_code == '[C'
      ["+1","*"]
    elsif escape_code[-1] == 'C'
      distance = escape_code[1..-2].to_i
      ["+#{distance}","*"]
    elsif escape_code[-1] == 'G'
      distance = escape_code[1..-2].to_i
      ["=#{distance - 1}", "*" ]
    else
      ["*","*"]
    end
  end
end
