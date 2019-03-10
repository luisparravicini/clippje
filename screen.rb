require_relative 'markov'


class Screen
  def initialize(clippje)
    @clippje = clippje
    @text_line = 2
    @messages_x = 14
    @options_line = 10
    @first_draw = false
  end

  def select_option(index)
    all_options = MarkovChain.normalize(@clippje.words.flatten(1))
    value = if index == RAND_OPTION
      rand(all_options.size)
    else
      value.to_i
    end
    if value < 0 || value >= all_options.size
      value = rand(all_options.size)
    end

    all_options[value][0]
  end

  def draw
    if @first_draw
      print_welcome
      @first_draw = false
    end
    show_options
    print_sentence
  end

protected

  def print_welcome
    puts <<-EOF
   ---
  /   \\
  |   |     Hi!
  @   @     Start to write and I'll assist you.
  |   |
  ||  |/
  ||  ||
  |\\_/ |
  \\___/
  EOF
  end

  def print_sentence
    print '> '
    print @clippje.sentence.join(' ') + @clippje.word
    # print (@clippje.sentence + ['/'] + [@clippje.word]).inspect
  end

  def show_options
    unless @clippje.words.empty?
      i = 0
      @clippje.words.each do |wordlist|
        wordlist.each_with_index do |w, wi|
          puts '%d. %s (%.2f)' % [i, w[0], w[1]]
          i += 1
        end
        puts "----"
      end
      puts "#{RAND_OPTION}. random"
    end
  end

end
