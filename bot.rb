#!/usr/bin/env ruby -W


require_relative 'markov'


mc = MarkovChain.new(File.read("2147-0.txt"))

sentence = ""
word = "The"
until sentence.count(".") == 4
  sentence << word << " "
  word = mc.get(word)
end
puts sentence << "\n\n"
