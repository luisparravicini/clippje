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

  def initialize(corpus)
    @sentence = []
    @word = ''
    @words = []
    @screen = Screen.new(self)
    @max_options = 10
    setup_markov(corpus)
    @max_order = 4
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
      if !@sentence.empty? && @word.empty? &&
      [',', ';', '!', '.'].include?(k)
        @sentence[-1] += k
        needs_redraw = true
      elsif k == ' ' || k == RAND_OPTION
        unless @words.empty?
          @word += RAND_OPTION if k == RAND_OPTION
          if @word == RAND_OPTION || @word =~ /^\d+$/
            @word = select_option(@word)
          end
        end

        @sentence << @word
        @word = ''
        needs_redraw = true
      elsif k == DELETE_KEY
        if @word.empty?
          unless @sentence.empty?
            @sentence = @sentence[0..-2]
            needs_redraw = true
          end
        else
          @word = @word[0..-2]
          print "\x08 \x08"
        end
      else
        @word += k
        print k
      end

    end
  end

  def self.corpus_dir
    File.join(File.dirname(__FILE__), 'texts')
  end

protected

  def select_option(index)
    if index == RAND_OPTION
      options = if @words > 1
        items = @words.find do |x|
          x if rand >= 0.5
        end
        items || @words.last
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

    items = []

    @max_order.downto(2).each do |n|
      completion_words = @sentence[-n..-1]&.compact
  p completion_words
      if completion_words&.size == n
        other_items = @mc.get(completion_words, @max_options)
        items << other_items
      end
    end

    items << @mc.get(@sentence[-1], @max_options)

    items.delete_if { |x| x.empty? }

    items
  end

  def setup_markov(corpus)
    @mc = MarkovChain.new

    text_dir = File.join(Clippje.corpus_dir, corpus)
    unless File.directory?(text_dir)
      puts "'#{text_dir}' doesn't exist!"
      exit 1
    end
    puts "using '#{File.basename(text_dir)}' corpus"
    cache = Cache.new(@mc, text_dir)
    cache.load_texts
  end

end



corpus = ARGV.shift
if corpus.nil?
  puts "usage: #{$0} <corpus_dir>"
  puts "available corpuses:"
  Dir.glob(File.join(Clippje.corpus_dir, '*')).each do |path|
    next unless File.directory?(path)

    name = File.basename(path)
    puts "\t#{name}"
  end
  exit 1
end

clippje = Clippje.new(corpus)
clippje.run
puts clippje.sentence
