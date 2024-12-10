implementation module BibtexToHtml;

import StdEnv,StdStrictLists,StdOverloadedList;
import StdDebug;


write_string i s file
	| i<size s
	   = fwrites s file;
	= file;

//--------------------------------------------------------------------------------------
//    write html unsorted
//--------------------------------------------------------------------------------------

write_entries_as_html :: [(Int,String,String, [(String,[String])] )] *File -> *File;
write_entries_as_html entries file
	# file = fwrites "<body>\n" file;
	# file = write_entries entries file;
	# file = fwrites "</body>\n" file;
	= file;

//--------------------------------------------------------------------------------------
//    write html sorted by field
//--------------------------------------------------------------------------------------

write_entries_as_html_sorted_by_field :: ([String] -> [String]) (String [(String,[String])] -> String)  String [(Int,String,String, [(String,[String])] )] *File -> *File;
write_entries_as_html_sorted_by_field sortfunc get_field_value fieldname entries file
	# file = fwrites "<body>\n" file;
  # file = write_entries_sorted_by_field sortfunc get_field_value  fieldname entries file
	# file = fwrites "</body>\n" file;
	= file;


write_entries_sorted_by_field sortfunc get_field_value fieldname entries file
	# sorted_fields = removeDup (sortfunc [get_field_value fieldname field_list \\ (line_n,entry_kind,entry_name,field_list)<-entries]);
	# file = write_entries_per_field  get_field_value fieldname sorted_fields  entries file;
    = file;

write_entries_per_field get_field_value fieldname [field:fields]  entries file
  # field_entries = [entry \\ entry=:((line_n,entry_kind,entry_name,field_list)) <- entries
									| get_field_value fieldname field_list==field]
	# file = write_entries_for_field field field_entries  file;
    = write_entries_per_field get_field_value fieldname fields entries file;
write_entries_per_field get_field_value fieldname [] entries file
	= file;

write_entries_for_field fieldname field_entries file
	# file = fwrites "<h1>\n" file;
	# file = fwrites (if (size fieldname==0) "Unknown" fieldname) file;
	# file = fwrites "</h1>\n" file;

	# file = fwrites "<ol>" file;

	# file = write_entries field_entries file;

	# file = fwrites "</ol>" file;

	= file;

//--------------------------------------------------------------------------------------
//    write html entries per entry
//--------------------------------------------------------------------------------------

write_entries :: [(.a,.b,.c,[({#.Char},[{#.Char}])])] *File -> .File;
write_entries [(line_n,entry_kind,entry_name,field_list):entries] file
//	# file = fwrites "<p>\n" file;
	# file = fwrites "<li>\n" file;
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
write_entries [] file
	= file;



find_and_remove_fields fields1 fields2 fields3 [field=:("author",_):fields]
	# (fields1,fields2,fields3,fields) = find_and_remove_fields fields1 fields2 fields3 fields;
	= ([field:fields1],fields2,fields3,fields);
find_and_remove_fields fields1 fields2 fields3 [field=:("title",_):fields]
	# (fields1,fields2,fields3,fields) = find_and_remove_fields fields1 fields2 fields3 fields;
	= (fields1,[field:fields2],fields3,fields);
find_and_remove_fields fields1 fields2 fields3 [field=:("url",_):fields]
	# (fields1,fields2,fields3,fields) = find_and_remove_fields fields1 fields2 fields3 fields;
	= (fields1,fields2,[field:fields3],fields);
find_and_remove_fields fields1 fields2 fields3 [field=:(field_name,_):fields]
	| field_name=="owner" || field_name=="__markedentry" || field_name=="timestamp"
		= find_and_remove_fields fields1 fields2 fields3 fields;
		# (fields1,fields2,fields3,fields) = find_and_remove_fields fields1 fields2 fields3 fields;
		= (fields1,fields2,fields3,[field:fields]);
find_and_remove_fields fields1 fields2 fields3 []
	= (fields1,fields2,fields3,[]);

write_fields [(field_name,field_value)] file
	# file = write_field_value field_name field_value file;
	= fwritec '.' file;
write_fields [field=:(field_name,field_value):(next_field_name,next_field_value):fields] file
	// field with link
	| next_field_name == "url"+++field_name
		# file = write_field_value field_name field_value file;
		  file = fwrites " " file;
		  file = fwrites "<a href=\"" file;
		  file = write_field_value2 next_field_value file;
		  file = fwrites "\">" file;
		  file = fwrites "&uArr;" file;
		  file = fwrites "</a>" file;
/*
		# file = fwrites "<a href=\"" file;
		  file = write_field_value2 next_field_value file;
		  file = fwrites "\">" file;
		  file = write_field_value field_name field_value file;
		  file = fwrites "</a>" file;
*/
		| isEmpty fields
			= fwritec '.' file;
			# file = fwrites (if (field_name=="author" || field_name=="title") ".\n" ",\n") file;
			= write_fields fields file;
write_fields [(field_name,field_value):fields] file
	# file = write_field_value field_name field_value file;
	# file = fwrites (if (field_name=="author" || field_name=="title") ".\n" ",\n") file;
	= write_fields fields file;
write_fields [] file
	= file;



write_fields_title_and_url (_,title_field_value) (url_field_name,url_field_value) file
	# file = fwrites "<a href=\"" file;
	  file = write_field_value url_field_name url_field_value file;
	  file = fwrites "\">" file;
	  file = fwrites "<font color=\"darkblue\">" file;
	  file = write_field_value2 title_field_value file;
	  file = fwrites "</font>" file;
	= fwrites "</a>." file;

write_field_value field_name field_value file
	| field_name=="author" || field_name=="editor"
		# field_value = format_names field_value;
		= write_field_value2 field_value file;
	| field_name=="title"
		# file = fwrites "<font color=\"darkblue\">" file;
		# file = write_field_value2 field_value file;
		= fwrites "</font>" file;
	| field_name=="journal" || field_name=="booktitle"
		# file = fwrites "<i>" file;
		# file = write_field_value2 field_value file;
		= fwrites "</i>" file;
	| field_name=="urlpdf"
		# file = fwrites "<a href=\"" file;
		# file = write_field_value2 field_value file;
		= fwrites "\">pdf</a>" file;
	| field_name=="urlps"
		# file = fwrites "<a href=\"" file;
		# file = write_field_value2 field_value file;
		= fwrites "\">ps</a>" file;
	| field_name=="urlabs"
		# file = fwrites "<a href=\"" file;
		# file = write_field_value2 field_value file;
		= fwrites "\">abstract</a>" file;
	| field_name=="urlbib"
		# file = fwrites "<a href=\"" file;
		# file = write_field_value2 field_value file;
		= fwrites "\">bibtex</a>" file;
		= write_field_value2 field_value file;




format_names names
	# names = [swap_first_and_last_names 0 s \\ s<-names];
	  names = concat_strings names;
	  names = replace_and_by_comma 0 names;
	= [names];
{


	skip_spaces i s
		| i<size s && (s.[i]==' ' || s.[i]=='\t')
			= skip_spaces (i+1) s;
			= i;

	swap_first_and_last_names i s
		# i = skip_spaces i s;
		| i==size s
			= s;
		# i2 = skip_to_comma_or_and i s;
		| i2==size s
			= s;
		| s.[i2]<>','
			= swap_first_and_last_names (i2+3) s;
		# begin_i=i;
		# end_i=i2-1;
		# i = skip_spaces (i2+1) s;
		| i==size s
			= s;
		# i2 = skip_to_comma_or_and i s;
		| i2==size s
			| i2==i
				= s;
				# i2 = skip_back_spaces i2 s;
				= (s % (0,begin_i-1)) +++ (s % (i,i2-1)) +++ " " +++ (s % (begin_i,end_i));
		| s.[i2]<>','
			# i2 = skip_back_spaces i2 s;
			# s1 = (s % (0,begin_i-1)) +++ (s % (i,i2-1)) +++ " " +++ (s % (begin_i,end_i));
			# s2 = s % (i2,size s-1);
			= s1 +++ swap_first_and_last_names 0 s2;
		| trace_tn ("too many commas in author field: "+++s+++" ; maybe you forget to separate authors with 'and' keyword?")
			= s;

	skip_to_space_or_comma :: !Int !{#Char} -> (!Bool,!Int);
	skip_to_space_or_comma i s
		| i<size s
			# c=s.[i]
			| c==' ' || c=='\t'
				= (False,i);
			| c==','
				= (True,i);
			| c<>'{'
				= skip_to_space_or_comma (i+1) s;
				# i = skip_to_brace (i+1) 1 s;
				= skip_to_space_or_comma i s;
			= (False,i);

	skip_to_comma_or_and :: !Int !{#Char} -> Int;
	skip_to_comma_or_and i s
		| i<size s
			# c=s.[i]
			| c==','
				= i;
			| c=='a' && i+2<size s && s.[i+1]=='n' && s.[i+2]=='d'
				= i;
			| c<>'{'
				| isAlpha c
					= skip_to_comma_or_and (skip_name (i+1) s) s;
					= skip_to_comma_or_and (i+1) s;
				# i = skip_to_brace (i+1) 1 s;
				= skip_to_comma_or_and i s;
			= i;

	skip_name i s
		| i<size s && isAlpha s.[i]
			= skip_name (i+1) s;
			= i;

	skip_to_brace i n_braces s
		| i<size s
			| s.[i]=='}'
				| n_braces==1
					= i+1;
					= skip_to_brace (i+1) (n_braces-1) s;
			| s.[i]=='{'
				= skip_to_brace (i+1) (n_braces+1) s;
				= skip_to_brace (i+1) n_braces s;
			= i;

	skip_back_spaces :: !Int !{#Char} -> Int;
	skip_back_spaces i s
		| i>0 && s.[i-1]==' '
			= skip_back_spaces (i-1) s;
			= i;

	concat_strings [s] = s;
	concat_strings [s1:s2:ss] = concat_strings [s1+++" "+++s2:ss];
	concat_strings [] = "";

	replace_and_by_comma i s
		# i0 = i;
		# i = skip_spaces i s;
		| i==size s
			= s;
		# (comma,i2) = skip_to_space_or_comma i s;
		| i2==size s
			= s;
		| comma
			= replace_and_by_comma (i2+1) s;
		| not (i2-i==3 && s.[i]=='a' && s.[i+1]=='n' && s.[i+2]=='d')
			= replace_and_by_comma i2 s;
			= replace_and_by_comma2 i2 i0 i2 s;

	replace_and_by_comma2 i begin_i end_i s
		# i0 = i;
		# i = skip_spaces i s;
		| i==size s
			= s;
		# (comma,i2) = skip_to_space_or_comma i s;
		| i2==size s
			= s;
		| comma
			= replace_and_by_comma2 (i2+1) begin_i end_i s;
		| not (i2-i==3 && s.[i]=='a' && s.[i+1]=='n' && s.[i+2]=='d')
			= replace_and_by_comma2 i2 begin_i end_i s;
			# s = s % (0,begin_i-1) +++ ", " +++ s % (end_i,size s-1);
			# d = (end_i-begin_i)-2;
			= replace_and_by_comma2 (i2-d) (i0-d) (i2-d) s;

	skip_to_space i s
		| i<size s
			# c=s.[i]
			| c==' ' || c=='\t'
				= i;
			| c<>'{'
				= skip_to_space (i+1) s;
				# i = skip_to_brace (i+1) 1 s;
				= skip_to_space i s;
			= i;
}

write_field_value2 [s] file
	= write_string 0 s file;
write_field_value2 [s:ss] file
	| size s==0
		= write_field_value2 ss file;
		# file = write_string 0 s file;
		# file = fwritec ' ' file;
		= write_field_value2 ss file;
write_field_value2 [] file
	= file;










