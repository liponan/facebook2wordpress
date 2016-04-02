# encoding=utf-8 
require 'open-uri'
require 'json'
require 'date'
require 'time'
require './utc2local'
require './fb2wp'
require 'to_xml'

get_pic = false

if ARGV.length > 0
	lim = ARGV[0].to_i
else
	lim = 1
end

page_id = '413364295402646'
# token = 'CAACEdEose0cBAL7ZAFaYGYt6WEDlSdgolMUG3EJZCA1Oa5SZBsdBso8ZCT7aFBQWYMmpgcpAH28624POqmbvaTDZBdHG9GeAKmDRejoQ68IoyWbz4OVB5WyBvRJDw4r3mZBjD2UELM6BmkZCRJWxUUZCzZBXbW4EXZCtZAzPUcKSd8fbozdjq9ctswucFJtMClPovRmIyGJTgKFwAF5KJjy9yNE'
token = STDIN.read

if lim < 250
	url = 'https://graph.facebook.com/v2.3/' + page_id + '/posts/?fields=id,message,type,object_id,created_time,admin_creator&limit=' + lim.to_s
else
	url = 'https://graph.facebook.com/v2.3/' + page_id + '/posts/?fields=id,message,type,object_id,created_time,admin_creator&limit=250'
end

url = url + '&access_token=' + token

puts url

json = open(url)

puts "get first json"

data_hash = JSON.parse(json.read)
# xml_hash = {"channel"=>{"item"=>[]}}


authors = {}

# xml_hash = {"channel"=>[]}

pat1 = /【(.+)】/
pat2 = /#([^\s0-9～]+)/

count = 0
untitled = 0

while count < lim
	if data_hash["data"].empty?
		break
	end
	data_hash["data"].each do |datum|
		# puts datum["id"]
		if datum["message"].nil?
			next
		end

		# intiate a hash for single post
		post_hash = {"item"=>{}}
		post_hash = {}

		# detect author

		if datum["admin_creator"].nil?
			creator = "dailycold"
		else
			creator = fb2wp( datum["admin_creator"]["name"] )
		end
		post_hash["dc_creator"] = creator

		if authors[creator].nil?
			authors[creator] = {"channel"=>[]}
		end

		title = datum["message"].scan(pat1).to_a
		cats  = datum["message"].scan(pat2).to_a

		if title.length > 0
			post_hash["title"] = title[0][0]
		else
			untitled = untitled + 1
			post_hash["title"] = "未命名-" + untitled.to_s
		end

		puts post_hash["title"]


		obj_url = "https://graph.facebook.com/" + datum["id"] + "/?fields=full_picture"
		obj_url = obj_url + '&access_token=' + token

		json = open(obj_url)
		obj_hash = JSON.parse(json.read)


		# post_hash["item"]["content:encoded"] = "<![CDATA[" + datum["message"] + "]]>"
		
		post_hash["content:encoded"] = "<![CDATA["
		unless obj_hash["full_picture"].nil?
			post_hash["content:encoded"] = post_hash["content:encoded"] \
			+ '<img src="' + "../../../wp-content/uploads/archive/" \
			+ datum["id"]+".jpg" + '">' + "\n"
		end
		post_hash["content:encoded"] = post_hash["content:encoded"] \
		+ datum["message"] \
		+ "\n\n" + '本文曾刊登於 <a href="https://www.facebook.com/' \
		+ datum["id"].sub("_","/posts/") + '" target="_blank">' \
		+ '每日一冷</a>' \
		+ ']]>'

		post_hash["pubDate"] = utc2local(datum["created_time"])
		post_hash["wp:post_date"] = utc2local(datum["created_time"])
		# post_hash["item"]["dc:creater"] = datum["admin_creator"]["name"]
		if datum["admin_creator"].nil?
			post_hash["dc_creator"] = "dailycold"
		else
			post_hash["dc_creator"] = fb2wp( datum["admin_creator"]["name"] )
		end
		post_hash["wp:post_type"] = "post"
		# post_hash["wp:status"] = "publish"
		post_hash["wp:status"] = "private" 
		
		
		# for cat in cats
		# 	post_hash['category domain="post_tag" nicename="'+cat[0]+'"'] = cat[0]
		# end



		# obj_hash["full_picture"]
		if get_pic
			unless datum["type"] == "status" || datum["type"] == "link"
				unless obj_hash["full_picture"].nil?
					open("pics_archive/" + datum["id"]+".jpg", 'wb') do |file|
						file << open(obj_hash["full_picture"]).read
					end
				end
			end
		end

		authors[creator]["channel"] << post_hash

		count = count + 1
		if count >= lim
			break
		end

		# puts post_hash
	end

	url = data_hash["paging"]["next"]
	json = open(url)
	data_hash = JSON.parse(json.read)	

end

puts "counts = " + count.to_s

# puts xml_hash

# xml = xml_hash.to_json.to_xml
# puts xml

authors.each_key { |key| 
	puts "Exporting " + "post_archive/" + key + ".json"
	File.open("post_archive/" + key + ".json", 'wb') do |f|
  		f.write(authors[key].to_json)
	end
	xml = authors[key].to_xml
	puts "Exporting " + "post_archive/" + key + ".xml"
	open("post_archive/" + key + ".xml", 'wb') do |file|
		open("xml_template.xml", 'r') do |tmp|
			file << tmp.read
		end
		file << "\t<wp:author>" \
		+ "<wp:author_login>" + key +  "</wp:author_login>" \
		+ "</wp:author>\n\n"
		file << xml[18..(xml.length-1)]
		file << "</rss>"
	end
}

