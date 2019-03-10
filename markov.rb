
# MarkovChain class loosely based on code from
# https://gist.github.com/alexpatriquin/11226396
class MarkovChain
  def initialize(logger)
    @words = Hash.new
    @logger = logger
  end

  def dump
    @words&.dup
  end

  def load(data)
    if data.nil?
      @words.clear
    else
      @words = data
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
    k = to_key(k)
    @words[k] ||= Hash.new(0)
    @words[k][next_word] += 1
  end

  def get(words, max_words)
    words = to_key(words)

    followers = @words[words]

    return [] if followers.nil?

    next_words = MarkovChain.normalize(followers)

    @logger.info('markov.get(%s): %s' % 
      [words.inspect, next_words.map { |x| '%s (%.2f)' % x }[0..30]])

    MarkovChain.normalize(next_words[0..max_words])
  end

  def self.normalize(items)
    total = items.reduce(0) { |sum, kv| sum + kv[1] }
    total = total.to_f
    items.map do |w, count|
      [w, count / total]
    end.sort_by { |x| x[1] }.reverse
  end

protected

  def to_key(x)
    x.is_a?(Array) ? x : [x]
  end

end
