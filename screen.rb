require_relative 'markov'


class Screen
  def initialize(clippje)
    @clippje = clippje
    @text_line = 2
    @messages_x = 14
    @options_line = 10
    @first_draw = true
  end

  def draw
    puts "\n\n"
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
    puts <<-EOT

Write a word and space to add it to the sentence.
Write an option number and space to choose that word.

    EOT
    print '> '
    print @clippje.sentence.join(' ')
    print ' '
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
      puts "#{RAND_OPTION}. auto\n"
    end
  end

end
