
# MarkovChain class based on code from
# https://gist.github.com/alexpatriquin/11226396
class MarkovChain
  def initialize(text)
    @words = Hash.new
    wordlist = text.split
    wordlist.each_with_index do |word, index|
      add(word, wordlist[index + 1]) if index <= wordlist.size - 2
    end
  end

  def add(word, next_word)
    @words[word] ||= Hash.new(0)
    @words[word][next_word] += 1
  end

  def get(word)
    followers = @words[word]

    return '' if followers.nil?

    total = followers.reduce(0) { |sum, kv| sum + kv[1] }
    random = rand(total) + 1
    # p [total, random]
    # p followers
    partial_sum = 0
    next_words = followers.map do |w, count|
      partial_sum += count
      [w, count] if partial_sum >= random
    end.compact
    # p next_words
    # puts
    next_words[0..5].map(&:first)
  end
end