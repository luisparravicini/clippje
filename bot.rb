#!/usr/bin/env ruby -W


# based on code from https://gist.github.com/alexpatriquin/11226396

class MarkovChain
  def initialize(text)
    @words = Hash.new
    wordlist = text.split
    wordlist.each_with_index do |word, index|
      add(word, wordlist[index + 1]) if index <= wordlist.size - 2
    end
  end

  def add(word, next_word)
    @words[word] = Hash.new(0) if !@words[word]
    @words[word][next_word] += 1
  end

  def get(word)
    return "" if !@words[word]
    followers = @words[word]
    total = followers.inject(0) {|sum,kv| sum += kv[1]}
    random = rand(total)+1
    partial_sum = 0
    next_word = followers.find do |_, count|
      partial_sum += count
      partial_sum >= random
    end.first
    next_word
  end
end

mc = MarkovChain.new(File.read("2147-0.txt"))

sentence = ""
word = "The"
until sentence.count(".") == 4
  sentence << word << " "
  word = mc.get(word)
end
puts sentence << "\n\n"
