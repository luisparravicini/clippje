require_relative 'term'


class Screen
  def initialize(clippje)
    @clippje = clippje
    @text_line = 2
    @messages_x = 14
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

    @clippje.words[value][0]
  end

  def draw
    print Term.clear_screen
    print_clippje
    show_options
    print_welcome
    print_sentence
  end

protected

  def print_welcome
    if @clippje.sentence.empty? && @clippje.word.empty?
      print Term.goto(@messages_x, @options_line + 1)
      print Term.clear_eol
      print "Hi! Start writing and I'll assist you."
    end
  end

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
    # print (@clippje.sentence + ['/'] + [@clippje.word]).inspect
  end

  def show_options
    dy = 1

    (@clippje.max_options + 2).times.each do |i|
      print Term.goto(@messages_x, @options_line + dy + i)
      print Term.clear_eol
    end

    unless @clippje.words.empty?
      @clippje.words.each_with_index do |w, i|
        print Term.goto(@messages_x, @options_line + dy + i)
        print '%d. %s (%.2f)' % [i, w[0], w[1]]
      end
      print Term.goto(@messages_x, @options_line + dy + @clippje.words.size)
      print "#{RAND_OPTION}. random"
    end
  end

end
