def utc2local(input_time)
	utc_time = Time.utc(input_time[0..3], \
		input_time[5..6],\
		input_time[8..9],\
		input_time[11..12],\
		input_time[14..15],\
		input_time[17..18])
	return utc_time.getlocal("+08:00").strftime('%F %T')
end