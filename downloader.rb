#!/usr/bin/env ruby -W

require 'nokogiri'
require 'open-uri'
require 'fileutils'




def download_file(url, path)
	tmp_path = path + '.tmp'

	tries = 3
	data = nil
	# from https://stackoverflow.com/questions/27407938/ruby-open-uri-redirect-forbidden
	begin
	  data = url.open(redirect: false).read
	rescue OpenURI::HTTPRedirect => redirect
	  url = redirect.uri # assigned from the "Location" response header
	  retry if (tries -= 1) > 0
	  raise
	end
	File.open(tmp_path, 'w') { |io| io.write(data) }
	FileUtils.mv(tmp_path, path)
end

def fetch_download_link(url)
	book_doc = Nokogiri::HTML(url.open)
	links = book_doc.search('a.link').select do |node|
		node['type'] =~ %r{text/html}
	end
	links.delete_if { |x| x.text =~ /with images/ }

	links.first
end


# bookshelves: https://www.gutenberg.org/wiki/Category:Bookshelf

#shelf = 'https://www.gutenberg.org/wiki/Science_Fiction_(Bookshelf)'
#shelf = 'https://www.gutenberg.org/wiki/Detective_Fiction_(Bookshelf)'
shelf = 'https://www.gutenberg.org/wiki/Western_(Bookshelf)'
shelf_url = URI.parse(shelf)

shelf_name = shelf.split('/').last.gsub(%r{_\(Bookshelf\)}, '')
downloads_dir = File.join('texts', shelf_name)
unless File.directory?(downloads_dir)
	FileUtils.mkdir_p(downloads_dir)
end
puts "downloading to '#{shelf_name}'"

print 'fetching list...'
doc = Nokogiri::HTML(shelf_url.open)
puts

doc.search('li').each do |node|
	next if node.text =~ /\(Illustrated\)/

	link = node.at('a')
	next if link.nil?
	book_url = link['href']
	next unless book_url =~ %r{/ebooks/(\d+)}
	book_id = $1

	unless book_url =~ /^http/
		book_url = URI.join(shelf_url, book_url)
	end

	title = link.text.gsub(/\(.+$/, '').strip

	print title << ' '
	local_path = File.join(downloads_dir, book_id + '.html')
	if File.exist?(local_path)
		print '[local]'
	else
		download_url = fetch_download_link(book_url)
		if download_url.nil?
			print '[not found]'
		else
			download_url = URI.join(book_url, download_url['href'])
			download_file(download_url, local_path)

			print '[downloaded]'
		end
	end
	puts
end
