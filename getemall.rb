require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'highline/import'

Bundler.require

photoIds = Array.new
photoId = /[0-9]+/
pageCount=0

# Prompt for username and set up file system

username = ask "Please enter your username: "
baseDirectory = Dir.new(Dir.pwd)
Dir.mkdir("images") unless File.exists?("images")

puts "Loading Flickr page..."
mainDoc = Nokogiri::HTML(open("http://www.flickr.com/photos/#{username}"))
mainDoc.xpath("//div[@data-page-count]/@data-page-count").each do |i|
	pageCount = i.value.to_i
end

puts "Loading photo IDs from #{pageCount} page(s)..."
1.step(pageCount,1) do |page|
	doc = Nokogiri::HTML(open("http://www.flickr.com/photos/#{username}/page#{page}/"))
	doc.xpath("//div[@class='title']/a[@data-track='photo-click']/@href").each do |link|
		photoIdStore = photoId.match(link)
		photoIds.push(photoIdStore)
	end
end

puts "Downloading #{photoIds.length} photos..."
photoIds.each do |myPhotoId|
	imgDoc = Nokogiri::HTML(open("http://www.flickr.com/photos/#{username}/#{myPhotoId}/sizes/o/in/photostream/"))
	imgDoc.xpath("//div[@id='allsizes-photo']/img/@src").each do |link|
		open(link) do |full_size_image|
		  	File.open("images/#{myPhotoId}.jpg","wb") do |file|
		     	file.puts full_size_image.read
		   	end
		end
	end
end