require 'fileutils'


class DBError < StandardError
end

class DBDataTooBigError < DBError
end

class DB

	def initialize(path)
		@path = path + '.db'
		@index_path = path + '.index'
		load_index
		@io = File.open(@path, File::RDWR | File::CREAT | File::BINARY)
		@record_size = 4 * 1024
		@dirty = false
	end

	def clear
		@keys.clear
		@dirty = true
		@io.truncate(0)
	end

	def has_key?(x)
		@keys.has_key?(x)
	end

	def size
		@keys.size
	end

	def close
		sync

		@io.close
		@io = nil
	end

	def [](k)
		return nil unless @keys.has_key?(k)
		index = @keys[k]

		@io.seek(index * @record_size)
		data = @io.read(@record_size)
		Marshal.load(data)
	end

	def []=(k, v)
		data = Marshal.dump(v)
		if data.size > @record_size
			raise DBDataTooBigError.new("Data is bigger than max (#{data.size} > #{@record_size})")
		end

		unless @keys.has_key?(k)
			@keys[k] = @keys.size
			@dirty = true
		end
		index = @keys[k]

		@io.seek(index * @record_size)
		@io.write(data)
		unless data.size == @record_size
			@io.write("\x0" * (@record_size - data.size))
		end
		@dirty = true
	end

protected

	def sync
		if @dirty
			save_index
			flush
			@dirty = false
		end
	end

	def load_index
		@keys = if File.exist?(@index_path)
			File.open(@index_path, 'rb') { |io| Marshal.load(io) }
		else
			Hash.new
		end
	end

	def save_index
		tmp_path = @index_path + '.tmp'
		File.open(tmp_path, 'wb') { |io| Marshal.dump(@keys, io) }
		FileUtils.mv(tmp_path, @index_path)
	end

	def flush
		@io.flush
	end

end
