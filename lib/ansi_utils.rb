if RUBY_VERSION < '1.8.7'
  class String
    def each_line
      split("\n")
    end
  end

  class Symbol
    def to_proc(*s)
      lambda {|i| i.__send__(self, *s) }
    end
  end
end

class String
  def words
    split(' ')
  end
end

module AnsiUtils
  extend self

  ' A up
    B down
    C forward
    D back
    E next_line
    F prev_line
    G move_to_column
  '.strip.each_line.map(&:words).each do |i|
    code, method = *i
    class_eval <<-DELIM
      def #{method}(num = nil)
        output('#{code}', *[num].compact)
      end
    DELIM
  end

  ' 6n status
    s save_position
    u restore_position
    ?25l hide_cursor
    ?25h show_cursor
  '.strip.each_line.map(&:words).each do |i|
    code, method = *i
    class_eval <<-DELIM
      def #{method}
        output('#{code}')
      end
    DELIM
  end

  # J
  def erase_screen(type = :after)
    output('J', erase_type(type))
  end

  # K
  def erase_line(type = :after)
    output('K', erase_type(type))
  end

  # H
  def move(col = nil, row = nil)
    output('H', *[col, row].compact)
  end

  # m
  def set_sgr(*args)
    output('m', *args)
  end

  private

  def erase_type(type)
    (@erase_type ||= {:after => 0, :before => 1, :all => 2})[type] or
      raise ArgumentError, "invalid type: #{type}"
  end

  def output(code, *args)
    print "\e[#{args.join(';')}#{code}"
    STDOUT.flush
  end
end
