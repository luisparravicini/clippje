#!/usr/bin/env ruby -W


require_relative 'markov'
require_relative 'screen'
require_relative 'cache'
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
    @max_options = 10
    setup_markov
  end

  def run
    @screen.draw

    needs_redraw = false
    until @sentence.count(".") == 4
      if needs_redraw
        @words = find_completions    
        @screen.draw
        needs_redraw = false
      end

      k = read_char
      if k == ' ' || k == RAND_OPTION
        @word += RAND_OPTION if k == RAND_OPTION
        if @word == RAND_OPTION || @word =~ /^\d+$/
          @word = select_option(@word)
        end

        @sentence << @word
        @word = ''
        needs_redraw = true
      elsif k == DELETE_KEY && !@word.empty?
        @word = @word[0..-2]
        print "\x08 \x08"
      else
        @word += k
        print k
      end

    end
  end

protected

  def select_option(index)
    if index == RAND_OPTION
      options = if @words.size == 2
        rand < 2/3.to_f ? @words.last : @words.first
      else
        @words.first
      end

      options[rand(options.size)][0]
    else
      all_options = @words.flatten(1)
      value = index.to_i
      all_options[value][0]
    end
  end

  def find_completions
    return [] if @sentence.empty?

    items = [@mc.get(@sentence[-1], @max_options)]

    completion_words = @sentence[-2..-1]&.compact
    if completion_words&.size == 2
      other_items = @mc.get(completion_words, @max_options)
      items.insert(0, other_items)
    end

    items
  end

  def setup_markov
    @mc = MarkovChain.new

    text_dir = File.join(File.dirname(__FILE__), 'texts',
      # 'Science_Fiction')
      # 'Detective_Fiction')
      'Western')
      # 'Test')
    puts "using '#{File.basename(text_dir)}' corpus"
    cache = Cache.new(@mc, text_dir)
    cache.load_texts
  end

end



clippje = Clippje.new
clippje.run
puts clippje.sentence
