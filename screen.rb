require_relative 'term'


class Screen
  def initialize(clippje)
    @clippje = clippje
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
    show_options
    print_sentence
  end

protected

  def print_sentence
    print Term.goto(1, 2)
    print Term.clear_eol
    print '> '
    print @clippje.sentence.join(' ') + @clippje.word
  end

  def show_options
    print Term.goto(1, 10)
    print Term.clear_eol

    unless @clippje.words.empty?
      @clippje.words.each_with_index { |w, i| print "[#{i}. #{w}] " }
      print "[#{RAND_OPTION} random]"
    end
  end

end
