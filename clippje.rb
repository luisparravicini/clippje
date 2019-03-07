#!/usr/bin/env ruby -W


require_relative 'markov'
require_relative 'screen'
require 'io/console'



RAND_OPTION = '/'
CTRL_C = "\u0003"

def read_char
    c = $stdin.getch
    exit 1 if c == CTRL_C
    c
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
    until @sentence.count(".") == 4      
      completion_word = if @word.empty?
        @sentence[-1]
      else
        @word
      end
      @words = @mc.get(completion_word)

      @screen.draw

      k = read_char
      if !@words.empty? && k == RAND_OPTION || k =~ /\d/
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
