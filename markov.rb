require 'benchmark'


# MarkovChain class loosely based on code from
# https://gist.github.com/alexpatriquin/11226396
class MarkovChain
  def initialize
    @words = Hash.new
    @wordlist = []
    @wordlist_keys = Hash.new
  end

  def dump
    [@words, @wordlist, @wordlist_keys]
  end

  def load(data)
    if data.nil?
      @words.clear
      @wordlist.clear
    else
      @words, @wordlist, @wordlist_keys = data
    end
  end

  def add_texts(texts)
    texts.each do |text|
      parse_text(text)
    end
  end
  
  def add(k, next_word)
    add_to_wordlist(k)
    k = to_key(k)
    @words[k] ||= Hash.new(0)
    @words[k][put_and_get_index(next_word)] += 1
  end

  def get(words, max_words)
    k = to_key(words)
    followers = @words[k]

    return [] if followers.nil?

    next_words = MarkovChain.normalize(followers)

    # puts('markov.get(%s): %s' % 
    #   [words.inspect, next_words.map { |x| '%s (%.2f)' % x }[0..30]])

    result = next_words[0..max_words].map do |w|
      [@wordlist[@wordlist_keys[w.first]], w.last]
    end
    MarkovChain.normalize(result)
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

      (2..max_order).each do |n|
        if last_words.size >= n && !next_word.nil?
          add(last_words[-n..-1], next_word)
        end
      end

      add(cur_word, next_word) unless next_word.nil?
    end
  end

  def put_and_get_index(w)
    unless @wordlist_keys.has_key?(w)
      @wordlist << w
      @wordlist_keys[w] = @wordlist.size - 1
    end
    @wordlist[@wordlist_keys[w]]
  end

  def add_to_wordlist(x)
    arrayize(x).each do |w|
      put_and_get_index(w)
    end
  end

  def to_key(x)
    unless x.nil?
      arrayize(x).map do |w| 
        k = @wordlist_keys[w]
        k.nil? ? nil : @wordlist[k]
      end
    end
  end

  def arrayize(x)
    x.is_a?(Array) ? x : [x]
  end
end
