write_xml_entries [(line_n,entry_kind,entry_name,field_list):entries] file
//	# file = fwrites "<p>\n" file;
//	# file = fwrites "<li>\n" file;
	# (fields1,fields2,fields3,fields) = find_and_remove_fields [] [] [] field_list;
	# file
		= case (fields2,fields3) of {
			([title_field],[url_field])
				# file = write_fields fields1 file;
				# file = fwritec '\n' file;
				# file = write_fields_title_and_url title_field url_field file;
				| isEmpty fields
					-> file;
					# file = fwritec '\n' file;
					-> write_fields fields file;
			_
				# fields = fields1++fields2++fields;
				-> write_fields fields file;
			}
//	# file = fwrites "</p>\n" file;
	# file = fwrites "</li>\n" file;
	= write_entries entries file;
write_xml_entries [] file
	= file;

write_xml entries file_name w
	# (ok,file,w) = fopen file_name FWriteText w;
	| not ok
		= abort ("Could not create file: "+++file_name);

//	# file = fwrites "<body>\n" file;

	# file = write_entries entries file;

//	# file = fwrites "</body>\n" file;

	# (ok,w) = fclose file w;
	| not ok
		= abort ("Error writing file: "+++file_name);
	= w;
