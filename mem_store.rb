
class MarkovMemoryStore
	
	def initialize
    @words = Hash.new
  	@wordlist = []
  	@wordlist_keys = Hash.new
	end

	def add(k, next_word)
    add_to_wordlist(k)
    k = to_key(k)
    @words[k] ||= Hash.new(0)
    @words[k][put_and_get_index(next_word)] += 1
	end

	def get(words, max_words)
    k = to_key(words)
    next_words = @words[k] || []

		next_words = MarkovChain.normalize(next_words)
		next_words[0..max_words].map do |w|
			[@wordlist[w.first], w.last]
		end
	end

  def random_start(size)
    starts = @words.keys.select { |x|
      x.size == size && @wordlist[x.first] =~ /^[A-Z]/
    }
    starts[rand(starts.size)].map { |x| @wordlist[x] }
  end
  
	def load(data)
    if data.nil?
      @words.clear
      @wordlist.clear
    else
      @words, @wordlist, @wordlist_keys = data
    end
   # File.open('words.bin', 'wb') { |io| Marshal::dump(@words, io) }
   # File.open('wordlist.bin', 'wb') { |io| Marshal::dump(@wordlist, io) }
   # File.open('wordlist_keys.bin', 'wb') { |io| Marshal::dump(@wordlist_keys, io) }
	end

	def dump
    [@words, @wordlist, @wordlist_keys]
 	end

  def sync
  end

protected

  def to_key(x)
    unless x.nil?
      arrayize(x).map do |w|
        @wordlist_keys[w]
      end
    end
  end

  def arrayize(x)
    x.is_a?(Array) ? x : [x]
  end

	def add_to_wordlist(x)
		arrayize(x).each do |w|
			put_and_get_index(w)
		end
	end

  def put_and_get_index(w)
    unless @wordlist_keys.has_key?(w)
      @wordlist << w
      @wordlist_keys[w] = @wordlist.size - 1
    end
    @wordlist_keys[w]
  end

end
