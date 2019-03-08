require 'fileutils'


class Cache

	def initialize(mc, dir)
		@mc = mc
		@dir = dir
		load_cache
	end

	def load_texts
    files = Dir.glob(File.join(@dir, '*.html'))
    create_from_scratch, files = check_cache(files)

    if files.empty?
    	@mc.load(@cache[:mc])
    	return
    end
    unless create_from_scratch
    	@mc.load(@cache[:mc])
    end

    files.each_with_index do |path, i|
      print Term::clear_eol
      print "\rreading #{i+1}/#{files.size} files..."

      txt = IO.read(path, encoding: 'utf-8').scrub
      doc = Nokogiri::HTML(txt)

      @mc.add_texts(doc.search('p').map(&:text))

      @cache[:files][File.basename(path)] = File.mtime(path)
    end
    puts

    save_cache
	end


	protected

	def check_cache(files)
    create_from_scratch = false
    new_files = files.dup
    @cache[:files].each do |fname, mtime|
    	cache_path = File.join(@dir, fname)

    	unless new_files.include?(cache_path)
    		create_from_scratch = true
    		break
    	end

    	if File.mtime(cache_path) != mtime
    		create_from_scratch = true
    		break
    	end

    	new_files.delete(cache_path)
    end

    if create_from_scratch
    	puts 'recreating cache'
    end

    [create_from_scratch, create_from_scratch ? files : new_files]
	end

	def cache_path
		File.join(@dir, 'cache.db')
	end

	def save_cache
        print "saving cache..."

		@cache[:mc] = @mc.dump

		tmp_path = cache_path + '.tmp'
		File.open(tmp_path, 'w') do |io|
			Marshal::dump(@cache, io)
		end
		FileUtils.mv(tmp_path, cache_path)

		puts
	end

	def load_cache
		print "loading cache..."

		@cache = if File.exist?(cache_path)
			Marshal::load(IO.read(cache_path))
		else
			{ files: Hash.new, mc: nil }
		end

		puts
	end
end
