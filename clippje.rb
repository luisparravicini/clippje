#!/usr/bin/env ruby -W


require_relative 'markov'
require_relative 'screen'
require_relative 'term'
require 'io/console'
require 'nokogiri'



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
    @mc = MarkovChain.new

    text_dir = File.join(File.dirname(__FILE__), 'texts',
      'Science_Fiction')
    files = Dir.glob(File.join(text_dir, '*'))
    files.each_with_index do |path, i|
      print Term::clear_eol
      print "\rreading #{i}/#{files.size} files..."

      txt = IO.read(path, encoding: 'utf-8').scrub
      doc = Nokogiri::HTML(txt)
      @mc.add_texts(doc.search('p').map(&:text))
    end
  end

end



clippje = Clippje.new
clippje.run
puts clippje.sentence
