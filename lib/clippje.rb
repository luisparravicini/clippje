require_relative 'markov'
require_relative 'screen'
require_relative 'cache'
require 'io/console'
require 'nokogiri'
require 'optparse'


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

  def initialize(corpus, recreate_cache)
    @sentence = []
    @word = ''
    @words = []
    @screen = Screen.new(self)
    @max_options = 10
    setup_markov(corpus, recreate_cache)
    @max_order = 4
  end

  def interactive_run
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

  def gen_sentences(n)
    @sentence = @mc.random_start

    until @sentence.count { |x| x.end_with?('.') } >= n
      @words = find_completions
      break if @words.empty?
      @word = select_option(RAND_OPTION)

      @sentence << @word
      @word = ''

      if @sentence.size > 100
        puts "WARN: max words size reached"
        break
      end
    end

    puts '-'*70
    puts sentence.join(' ')
    puts '-'*70
    puts
  end

  def self.corpus_dir
    File.join(File.dirname(__FILE__), '..', 'texts')
  end

protected

  def select_option(index)
    if index == RAND_OPTION
      options = if @words.size > 1
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
      if completion_words&.size == n
        other_items = @mc.get(completion_words, @max_options)
        items << other_items
      end
    end

    items << @mc.get(@sentence[-1], @max_options)

    items.delete_if { |x| x.empty? }

    items
  end

  def setup_markov(corpus, recreate_cache)
    text_dir = File.join(Clippje.corpus_dir, corpus)
    unless File.directory?(text_dir)
      puts "'#{text_dir}' doesn't exist!"
      exit 1
    end
    puts "using '#{File.basename(text_dir)}' corpus"
    @mc = MarkovChain.new(text_dir)
    cache = Cache.new(@mc, text_dir, recreate_cache)
    cache.load_texts
    @mc.sync
  end

end
