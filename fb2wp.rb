# encoding: utf-8
def fb2wp(fb_name)
	dict = {"林怡"=>"riseswallow",
		"Larry Lai"=>"ponylai",
		"Po-Nan Li"=>"leeneil",
		"蘇璿允"=>"dailycold",
		"Joey Lu"=>"ldjoeybond",
		"何昱泓"=>"imobert",
		"Ting Lee"=>"dailycold",
		"Kūo Tsànyǔ"=>"dailycold",
		"Shazza Lin"=>"dailycold"}
	wp_name = dict[fb_name]
	if wp_name.nil?
		return "dailycold"
	else
		return wp_name
	end
end