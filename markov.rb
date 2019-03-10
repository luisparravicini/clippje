
# MarkovChain class loosely based on code from
# https://gist.github.com/alexpatriquin/11226396
class MarkovChain
  def initialize
    @words = Hash.new
    @wordlist = []
    @wordlist_keys = Hash.new
  end

  def dump
    [@words.dup, @wordlist.dup, @wordlist_keys.dup]
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
      wordlist = text.split
      order_2_words = []
      wordlist.each_with_index do |word, index|
        order_2_words << word
        if order_2_words.size == 2 && index <= wordlist.size - 3
          add(order_2_words, wordlist[index + 1])
          order_2_words = [order_2_words[1]]
        end
          
        add(word, wordlist[index + 1]) if index <= wordlist.size - 2
      end
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
