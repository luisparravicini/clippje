require 'fileutils'
require 'zlib'


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

    dirty = false
    files.each_with_index do |path, i|
      print Term::clear_eol
      print "\rreading #{i+1}/#{files.size} files..."

      txt = IO.read(path, encoding: 'utf-8').scrub
      doc = Nokogiri::HTML(txt)

      if doc.at('pre')&.text =~ /Language: (\S+)/
        lang = $1
        unless lang == 'English'
          next
        end
      else
        puts "\nLanguage not found for #{path}"
        next
      end

      all_texts = doc.search('p').map(&:text)
      @mc.add_texts(all_texts)
      @cache[:files][File.basename(path)] = File.mtime(path)
      dirty = true
    end
    puts

    save_cache if dirty
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
      Zlib::GzipWriter.wrap(io) do |gzio|
			  Marshal::dump(@cache, gzio)
      end
		end
		FileUtils.mv(tmp_path, cache_path)

		puts
	end

	def load_cache
		print 'loading cache...'

		@cache = if File.exist?(cache_path)
      File.open(cache_path) do |io|
        Zlib::GzipReader.wrap(io) do |gzio|
			    Marshal::load(gzio)
        end
      end
		else
			{ files: Hash.new, mc: nil }
		end

		puts
	end
end
