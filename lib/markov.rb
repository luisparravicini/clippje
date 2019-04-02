require 'set'
require_relative 'mem_store.rb'
# require_relative 'sdbm_store.rb'
# require_relative 'db_store.rb'


# MarkovChain class loosely based on code from
# https://gist.github.com/alexpatriquin/11226396
class MarkovChain

  def initialize(corpus_dir)
    @min_order = 2
    @store = MarkovMemoryStore.new
    # @store = MarkovSDBMStore.new(corpus_dir)
    # @store = MarkovDBtore.new(corpus_dir)
  end

  def dump
    @store.dump
  end

  def load(data)
    @store.load(data)
  end

  def sync
    @store.sync
  end

  def add_texts(texts)
    texts.each do |text|
      parse_text(text)
    end
  end
  
  def add(k, next_word)
    @store.add(k, next_word)
  end

  def get(words, max_words)
    next_words = @store.get(words, max_words)
    return next_words if next_words.empty?

    # puts('markov.get(%s): %s' % 
    #   [words.inspect, next_words.map { |x| '%s (%.2f)' % x }[0..30]])

    MarkovChain.normalize(next_words)
  end

  def random_start
    @store.random_start(@min_order)
  end

  def self.normalize(items)
    total = items.reduce(0) { |sum, kv| sum + kv[1] }
    total = total.to_f
    items.map do |w, count|
      [w, count / total]
    end.sort_by { |x| x[1] }.reverse
  end

protected

  def parse_text(text)
    eof = false
    last_words = []
    max_order = 4
    scanner = StringScanner.new(text)
    while !eof do
      cur_word = scanner.scan_until(/\S+/)&.strip
      eof = cur_word.nil?
      break if eof
      next_word = scanner.check_until(/\S+/)&.strip

      last_words << cur_word
      last_words.delete_at(0) if last_words.size > max_order

      (@min_order..max_order).each do |n|
        if last_words.size >= n && !next_word.nil?
          add(last_words[-n..-1], next_word)
        end
      end

      # dont store order 1 seqs
      # add(cur_word, next_word) unless next_word.nil?
    end
  end

end
