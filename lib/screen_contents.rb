class ScreenContents
  X = 1
  Y = 0
  def initialize
    reset_buffer
  end

  def reset_buffer
    @cursor = [0,0]
    @scrolling = nil
    @buffer = []
  end

  def enable_scrolling(rows)
    #@scrolling = nil
    #@scrolling = rows
    @scrolling = [] unless @scrolling
    @scrolling.delete(rows)
    @scrolling << rows
  end

  def disable_scrolling
    @scrolling = nil
  end

  def get_stripped_string
    @buffer.dup.map { |line| line.join }.join("\n").strip
  end

  def get_buffer_contents
    @buffer.dup.map do |line|
      (line || []).map { |char| char || ' ' }.join
    end
  end

  def read_new_position(x_string, y_string)
    @cursor[X] = read_position_string(@cursor[X], x_string)
    @cursor[Y] = read_position_string(@cursor[Y], y_string)
    handle_scrolling if @scrolling
    prevent_negative_coordinates
  end

  def delete_last_character
    @cursor[X] -= 1
    set_current_char(' ')
    prevent_negative_coordinates
  end

  def add_character(character)
    set_current_char(character)
    @cursor[X] += 1
  end

  def add_byte(byte)
    add_character(byte.chr)
  end

  def delete_current_line
    @buffer[@cursor[Y]] = []
  end

  def delete_from_cursor_to_end
    @buffer = @buffer[0..@cursor[Y]]
    @buffer[@cursor[Y]] = @buffer[@cursor[Y]][0..@cursor[X]] if @buffer[@cursor[Y]]
    @buffer[@cursor[Y]][@cursor[X]] = ' ' if @buffer[@cursor[Y]]
  end

  def get_cursor_position
    @cursor.dup.reverse
  end

  private

  def handle_scrolling
    #scroll_screen(@scrolling) if @cursor[Y] == @scrolling[1]
    @scrolling.each do |scroll_window|
      scroll_screen(scroll_window) if @cursor[Y] == scroll_window[1]
    end
  end

  def scroll_screen(scroll_window)
    scroll_window[0].upto(scroll_window[1] - 1) do |row|
      @buffer[row] = @buffer[row + 1]
      @buffer[row + 1] = [''] if @buffer[row + 1]
    end
  end

  def set_current_char(value)
    @buffer[@cursor[Y]] = [] unless @buffer[@cursor[Y]]
    @buffer[@cursor[Y]][@cursor[X]] = value
  end

  def prevent_negative_coordinates
    @cursor[X] = 0 if @cursor[X] < 0
    @cursor[Y] = 0 if @cursor[Y] < 0
  end

  def read_position_string(previous_position, string)
    return previous_position if string == nil or string == '*'
    if string[0] == '='
      string[1..-1].to_i
    elsif string[0] == '+'
      previous_position + string[1..-1].to_i
    elsif string[0] == '-'
      previous_position - string[1..-1].to_i
    else
      previous_position
    end
  end
end

