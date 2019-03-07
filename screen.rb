require_relative 'term'


class Screen
  def initialize(clippje)
    @clippje = clippje
    @text_line = 2
    @options_line = 10
  end

  def select_option(index)
    value = if index == RAND_OPTION
      rand(@clippje.words.size)
    else
      value.to_i
    end
    if value < 0 || value >= @clippje.words.size
      value = rand(@clippje.words.size)
    end

    @clippje.words[value]
  end

  def draw
    print Term.clear_screen
    print_clippje
    show_options
    print_sentence
  end

protected

  def print_clippje
    print Term.goto(0, @options_line)
    puts <<-EOF
   ---
  /   \\
  |   |
  @   @
  |   |
  ||  |/
  ||  ||
  |\\_/ |
  \\___/
  EOF
  end

  def print_sentence
    (@text_line..@options_line - 1).each do |y|
      print Term.goto(1, y)
      print Term.clear_eol
    end
    print Term.goto(1, @text_line)
    print '> '
    print @clippje.sentence.join(' ') + @clippje.word
  end

  def show_options
    x = 14
    dy = 2
    print Term.goto(x, @options_line + dy)
    print Term.clear_eol

    unless @clippje.words.empty?
      @clippje.words.each_with_index do |w, i|
        print Term.goto(x, @options_line + dy + i)
        print "#{i}. #{w}"
      end
      print Term.goto(x, @options_line + dy + @clippje.words.size)
      print "#{RAND_OPTION}. random"
    end
  end

end
