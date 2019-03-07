#!/usr/bin/env ruby -W


require_relative 'markov'
require_relative 'term'
require 'io/console'


mc = MarkovChain.new(File.read("2147-0.txt"))
$input_io = $stdin

def read_char
    c = $input_io.getch

    # ctrl-c
    exit 1 if c == "\u0003"

    c
end

def print_sentence(sentence, word)
  print Term.goto(1, 2)
  print '> '
  print sentence.join(' ') + word
end

RAND_OPTION = '/'

def show_options(options)
  print Term.goto(1, 10)
  print Term.clear_eol

  unless options.empty?
    options.each_with_index { |w, i| print "[#{i}. #{w}] " }
    print "[#{RAND_OPTION} random]"
  end
end

def select_option(index, words)
  value = if index == RAND_OPTION
    rand(words.size)
  else
    value.to_i
  end
  if value < 0 || value >= words.size
    value = rand(words.size) 
  end

  words[value]
end


print Term.clear_screen

word = ''
sentence = []
words = []
until sentence.count(".") == 4
  completion_word = if word.empty?
    sentence[-1]
  else
    word
  end
  words = mc.get(completion_word)
  show_options(words)

  print_sentence(sentence, word)

  k = read_char
  if k == RAND_OPTION || k =~ /\d/
    unless word.empty?
      sentence << word
      word = ''
    end

    w = select_option(k, words)
    sentence << w
    words = []
  elsif k == ' '
    sentence << word
    word = ''
  elsif k == "\x08" && !word.empty?
    word = word[0..-2]
  else
    word += k
  end

end

puts sentence << "\n\n"
