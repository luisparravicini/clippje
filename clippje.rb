#!/usr/bin/env ruby -W


require_relative 'markov'
require_relative 'screen'
require_relative 'term'
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
  attr_reader :max_options

  def initialize
    @sentence = []
    @word = ''
    @words = []
    @screen = Screen.new(self)
    @max_options = 5
    setup_markov
  end

  def run
    until @sentence.count(".") == 4      
      completion_word = if @word.empty?
        @sentence[-1]
      else
        @word
      end
      @words = @mc.get(completion_word, @max_options)

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

protected

  def setup_markov
    text_dir = File.join(File.dirname(__FILE__), 'texts')
    files = Dir.glob(File.join(text_dir, '*'))
    progress_seq = ['|', '/', '-', '\\']
    progress_index = 0
    text = files.map do |path|
      print Term::clear_eol
      print "\rreading #{files.size} files... #{progress_seq[progress_index]}"
      progress_index = (progress_index + 1) % progress_seq.size

      IO.read(path, encoding: 'utf-8').scrub
    end.join("\n")
    print "\r#{Term::clear_eol}analyzing texts..."

    @mc = MarkovChain.new(text)
  end

end



clippje = Clippje.new
clippje.run
puts clippje.sentence
