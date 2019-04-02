require 'sdbm'
require 'json'


class MarkovSDBMStore
	
	def initialize(path)
    @db_wordlist_path = File.join(path, 'wordlist.db')
    @db_wordlist_keys_path = File.join(path, 'wordlist_keys.db')
    @db_words_path = File.join(path, 'words.db')
    open_db
	end

	def add(k, next_word)
    add_to_wordlist(k)
    k = to_key(k)
    items = if @db_words.has_key?(k)
      JSON.parse(Zlib::Inflate.inflate(@db_words[k]))
    else
      Hash.new
    end
    next_w = put_and_get_index(next_word)
    items[next_w] ||= 0
    items[next_w] += 1

    data = Zlib::Deflate.deflate(items.to_json)
    begin
      @db_words[k] = data
    rescue SDBMError => e
      $stderr.puts "Error saving: k=#{k}, data=#{items.inspect} size=#{data.size}"
      raise e
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
    else
      # @words, @wordlist, @wordlist_keys = data
      # @words = data
    end
	end

	def dump
    # [@words, @wordlist, @wordlist_keys]
    # @words
 	end

  def sync
    @db_wordlist.close
    @db_wordlist_keys.close
    @db_words_path.close
    open_db
  end

protected

  def open_db
    @db_wordlist = SDBM.open(@db_wordlist_path)
    @db_wordlist_keys = SDBM.open(@db_wordlist_keys_path)
    @db_words = SDBM.open(@db_words_path)
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
      index = @db_wordlist.size.to_s
      @db_wordlist[w] = index
      @db_wordlist_keys[index] = w
    end
    @db_wordlist[w]
  end

end
