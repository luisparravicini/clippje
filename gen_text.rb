#!/usr/bin/env ruby -W


require_relative 'clippje'



def list_corpuses
  puts "Available corpuses:"
  Dir.glob(File.join(Clippje.corpus_dir, '*')).each do |path|
    next unless File.directory?(path)

    name = File.basename(path)
    puts "\t#{name}"
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [-i] <-c corpus>"

  opts.on("-i", "--interactive", "Interactive") do
    options[:interactive] = true
  end

  opts.on("-c", "--corpus NAME", "Corpus") do |name|
    options[:corpus] = name
  end

  opts.on("-r", "--recreate-cache", "Recreate cache") do |name|
    options[:recreate_cache] = name
  end

  opts.on("-l", "--list", "List available corpuses") do
    options[:list] = true
  end
end.parse!

corpus = options[:corpus]

if options[:list]
  list_corpuses
  exit 1
end

if corpus.nil?
  puts "No corpus selected"
  list_corpuses
  exit 1
end


clippje = Clippje.new(corpus, options[:recreate_cache])
if options[:interactive]
  clippje.interactive_run
else
  5.times.each do
    clippje.gen_sentences(2)
    puts
  end
end
