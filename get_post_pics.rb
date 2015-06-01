# encoding=utf-8 
require 'open-uri'
require 'json'
require 'date'
require 'time'
require 'to_xml'

if ARGV.length > 0
	lim = ARGV[0].to_i
else
	lim = 1
end

page_id = '413364295402646'
# token = 'CAACEdEose0cBAL7ZAFaYGYt6WEDlSdgolMUG3EJZCA1Oa5SZBsdBso8ZCT7aFBQWYMmpgcpAH28624POqmbvaTDZBdHG9GeAKmDRejoQ68IoyWbz4OVB5WyBvRJDw4r3mZBjD2UELM6BmkZCRJWxUUZCzZBXbW4EXZCtZAzPUcKSd8fbozdjq9ctswucFJtMClPovRmIyGJTgKFwAF5KJjy9yNE'
token = STDIN.read


url = 'https://graph.facebook.com/v2.3/' + page_id + '/posts/?fields=id,message,type,object_id,created_time,admin_creator&limit=' + lim.to_s

url = url + '&access_token=' + token

# puts url

json = open(url)

data_hash = JSON.parse(json.read)
# xml_hash = {"channel"=>{"item"=>[]}}
xml_hash = {"channel"=>[]}

pat = /【(.+)】/

count = 0;

data_hash["data"].each do |datum|
	
	title = datum["message"].scan(pat).to_a
	# puts title[0]
	# puts datum["message"]
	
	post_hash = {"item"=>{}}
	post_hash = {}
	# post_hash = {"item"=>{
	# 	"title"=>"",
	# 	# "link"=>"",
	# 	"pubDate"=>"",
	# 	"dc:creater"=>"",
	# 	"content:encoded"=>"",

	# 	}}

	# post_hash["item"] << {"title"=>title[0]}
	if title.length > 0
		post_hash["title"] = title[0][0]
	else
		count = count + 1
		post_hash["title"] = "未命名-" + count.to_s
	end

	puts post_hash["title"]

	# post_hash["item"]["content:encoded"] = "<![CDATA[" + datum["message"] + "]]>"
	post_hash["content:encoded"] = "<![CDATA[" + datum["message"] + "]]>"
	# post_hash["item"]["pubDate"] = datum["created_time"]
	created_time = Time.utc(datum["created_time"][0..3], \
		datum["created_time"][5..6],\
		datum["created_time"][8..9],\
		datum["created_time"][11..12],\
		datum["created_time"][14..15],\
		datum["created_time"][17..18])
	post_hash["pubDate"] = created_time.strftime('%F %T')
	# post_hash["item"]["dc:creater"] = datum["admin_creator"]["name"]
	if datum["admin_creator"].nil?
		post_hash["dc_creator"] = "每日一冷"
	else
		post_hash["dc_creator"] = datum["admin_creator"]["name"]
	end
	post_hash["wp:post_type"] = "post"
	post_hash["wp:status"] = "publish"
	obj_url = "https://graph.facebook.com/" + datum["id"] + "/?fields=full_picture"
	obj_url = obj_url + '&access_token=' + token
	json = open(obj_url)
	obj_hash = JSON.parse(json.read)

	# obj_hash["full_picture"]
	
	# unless datum["type"] == "status"
	# 	open(datum["id"]+".jpg", 'wb') do |file|
	# 		file << open(obj_hash["full_picture"]).read
	# 	end
	# end

	# xml_hash["channel"]["item"] << post_hash
	xml_hash["channel"] << post_hash


	# puts post_hash
end

# puts xml_hash
xml = xml_hash.to_xml
# xml = xml_hash.to_json.to_xml
# puts xml
open("dailycold_archieve.xml", 'wb') do |file|
	open("xml_template.txt", 'r') do |tmp|
		file << tmp.read
	end
	file << xml[18..(xml.length-1)]
	file << "</rss>"
end

