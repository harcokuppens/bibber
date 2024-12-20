implementation module BibtexToBibtex;

import StdEnv,StdStrictLists,StdOverloadedList;
import StdDebug;


write_string i s file
	| i<size s
	   = fwrites s file;
	= file;

write_bib_entries :: [(Int,String,String, [(String,[String])] )] *File -> *File;
write_bib_entries [(line_n,entry_kind,entry_name,field_list):entries] file
	# file = file <<< '@' <<< entry_kind <<< '{' <<< entry_name <<< ",\n";
	# file = write_bib_fields field_list file;
	# file = file <<< "\n}\n";
	= write_bib_entries entries file;
write_bib_entries [] file
	= file;

write_bib_fields [(field_name,field_value)] file
	= write_bib_field_value field_name field_value file;
write_bib_fields [(field_name,field_value):fields] file
	# file = write_bib_field_value field_name field_value file;
	# file = fwrites ",\n" file;
	= write_bib_fields fields file;
write_bib_fields [] file
	= file;

write_bib_field_value field_name field_value file
	# file = file <<< '\t' <<< field_name <<< " = {";
	= write_bib_field_value2 field_value file;

write_bib_field_value2 [s] file
	# file = write_string 0 s file;
	= file <<< "}";
write_bib_field_value2 [s:ss] file
	| size s==0
		= write_bib_field_value2 ss file;
		# file = write_string 0 s file;
		# file = fwritec ' ' file;
		= write_bib_field_value2 ss file;
write_bib_field_value2 [] file
	= file <<< "}";
