require_relative 'db'

class MarkovDBtore
	
	def initialize(path)
    @db_wordlist_path = File.join(path, 'wordlist')
    @db_wordlist_keys_path = File.join(path, 'wordlist_keys')
    @db_words_path = File.join(path, 'words')
    open_db
	end

	def add(k, next_word)
    add_to_wordlist(k)
    k = to_key(k)
    items = if @db_words.has_key?(k)
      @db_words[k]
    else
      Hash.new
    end
    next_w = put_and_get_index(next_word)
    items[next_w] ||= 0
    items[next_w] += 1

    begin
      @db_words[k] = items
    rescue DBDataTooBigError => e
      $stderr.puts e
    end
	end

	def get(words, max_words)
    k = to_key(words)
    next_words = @db_words[k] || []

		next_words = MarkovChain.normalize(next_words)
		next_words[0..max_words].map do |w|
			[@db_wordlist_keys[w.first], w.last]
		end
	end

	def load(data)
    if data.nil?
      @db_words.clear
      @db_wordlist.clear
      @db_wordlist_keys.clear
      @db_words.clear
    end
	end

	def dump
 	end

  def sync
    @db_wordlist.close
    @db_wordlist_keys.close
    @db_words.close
    open_db
  end

protected

  def open_db
    @db_wordlist = DB.new(@db_wordlist_path)
    @db_wordlist_keys = DB.new(@db_wordlist_keys_path)
    @db_words = DB.new(@db_words_path)
  end

  def to_key(x)
    unless x.nil?
      arrayize(x).map do |w| 
        @db_wordlist.has_key?(w) ? @db_wordlist[w] : nil
      end.join(':')
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
    unless @db_wordlist.has_key?(w)
      index = @db_wordlist.size
      @db_wordlist[w] = index
      @db_wordlist_keys[index] = w
    end
    @db_wordlist[w]
  end

end
