#!/usr/bin/env ruby -W


require_relative 'markov'
require_relative 'term'
require 'io/console'



RAND_OPTION = '/'

def read_char
    c = $stdin.getch

    # ctrl-c
    exit 1 if c == "\u0003"

    c
end


class Screen
  def initialize(clippje)
    @clippje = clippje
  end

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
  end

end


class Clippje
  DELETE_KEY = "\x7f"

  attr_accessor :sentence, :word, :words

  def initialize
    @sentence = []
    @word = ''
    @words = []
    @screen = Screen.new(self)
    @mc = MarkovChain.new(File.read("2147-0.txt"))
  end

  def run
    @screen.draw

    until @sentence.count(".") == 4
      completion_word = if @word.empty?
        @sentence[-1]
      else
        @word
      end
      @words = @mc.get(completion_word)
      @screen.show_options

      @screen.print_sentence

      k = read_char
      if k == RAND_OPTION || k =~ /\d/
        unless @word.empty?
          @sentence << @word
          @word = ''
        end

        w = @screen.select_option(k)
        @sentence << w
        @words = []
      elsif k == ' '
        @sentence << @word
        @word = ''
      elsif k == DELETE_KEY && !@word.empty?
        @word = @word[0..-2]
      else
        @word += k
      end

    end
  end

end



clippje = Clippje.new
clippje.run
puts clippje.sentence
