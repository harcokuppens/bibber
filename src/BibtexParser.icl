implementation module BibtexParser;


import StdEnv,StdStrictLists,StdOverloadedList;
import StdDebug;


:: *PS = {line_i::!Int,line::!{#Char},line_n::!Int,file::!*File};

// obsolete -> use read_bib_file instead, and let opening file handle to program
read_bib_filename :: !{#Char} !*World -> *(![(Int,{#Char},[{#Char}])],!*World);
read_bib_filename file_name w
	# (ok,file,w) = fopen file_name FReadText w;
	| not ok
		= abort ("Could not open file: "+++file_name);
	# (entries,file) = read_bib_file_entries 1 file;
	# (ok,w) = fclose file w;
	| not ok
		= abort ("Error reading file: "+++file_name);
	= (entries,w);



// read in line with data ( skipped comments and empty lines)
// ----------------------------------------------------------

remove_newline s
	# n=size s;
	| n>0
	    | s.[n-1]=='\r'
		   = s % (0,n-2);
	    | s.[n-1]=='\n'
	       | s.[n-2]=='\r'
		      = s % (0,n-3);
		   = s % (0,n-2);
		= s;

// read in line with data ( skipped comments and empty lines)
read_line line_n file
	# (line,file) = freadline file;
	| size line==0                    // EOF reached (note: empty line still has one char, which is newline)
		= (line,line_n,file);
	| size line>=2 && line.[0]=='%' && line.[1]=='%'
		= read_line (line_n+1) file;     // skip comment line
	# line = remove_newline line;       // remove newline
	| size line==0
		= read_line (line_n+1) file;   // skip empty line
	= (line,line_n,file);               // return found line



// read in raw bibtex entries,  just @entrykind{<entrylines>}
// -----------------------------------------------------------


read_bib_file :: *File -> ([(Int,{#Char},.[{#Char}])],.File);
read_bib_file file
	# (entries,file) = read_bib_file_entries 1 file;
	= (entries,file);

// read bib entries from file starting from line_n to EOF
read_bib_file_entries :: .Int *File -> ([(Int,{#Char},.[{#Char}])],.File);
read_bib_file_entries line_n file
	# (line,line_n,file) = read_line line_n file;   // read in line with data ( skipped comments and empty lines)
	# (entries,ps) = read_entries {line_i=0,line=line,line_n=line_n,file=file};
	= (entries,ps.file);


read_entries ps
	# ps = skip_spaces_ps ps;
	| size ps.line==0             // EOF reached, ok we are finished parsing all entries succesfull! (no abort needed!)
		= ([],ps);
	# ps = skip_to_char_ps '@' ps;
	#! i = ps.line_i;
	#! line = ps.line;
	#! line_n = ps.line_n;
	# i2 = skip_ident i line;
	| i2==i
		= abort ("Error at line "+++toString ps.line_n+++" entry kind expected after @");
	# entry_kind = line % (i,i2-1);
	# ps = {ps & line_i=i2,line=line};
	# (end_bracket,ps) = skip_to_bracket_ps ps;           //find starting { or (, then we know end_bracket is } or )
	#! line_i = ps.line_i;
	# (entry_lines,ps) = read_entry 1 line_i end_bracket ps;  // read lines from entry until end_bracket found
	# (entries,ps) = read_entries ps;
	= ([(line_n,entry_kind,entry_lines):entries],ps);

skip_to_char_ps c ps=:{line_i,line,line_n,file}
	| line_i<size line
		| line.[line_i]==c
			= skip_spaces_ps {ps & line_i=line_i+1};     // reached c, then skip spaces after c, and then return ps (position)
		| line.[line_i]=='%'
			# (line,line_n,file) = read_line (line_n+1) file; // when finding start of comment on line, continue to next line
			| size line<>0
				= skip_to_char_ps c {ps & line_i=0,line=line,line_n=line_n,file=file};  // continue search for c on next line
			    = abort (toString c+++" expected at line "+++toString line_n);  // EOF line reached unexpected
		    = skip_to_char_ps c {ps & line_i=line_i+1};  // char <> c thus continue search to next char
	= abort (toString c+++" expected at line "+++toString line_n); // char not found in none-empty data of line

skip_to_bracket_ps ps=:{line_i,line,line_n}
	| line_i<size line
		| line.[line_i]=='{'
			= ('}',skip_spaces_ps {ps & line_i=line_i+1});
		| line.[line_i]=='('
			= (')',skip_spaces_ps {ps & line_i=line_i+1});
		    = skip_to_bracket_ps {ps & line_i=line_i+1};
	    = abort (" { or ( expected at line "+++toString line_n);

skip_spaces_ps ps=:{line_i,line,line_n,file}
	| line_i<size line
		| line.[line_i]==' ' || line.[line_i]=='\t'
			= skip_spaces_ps {ps & line_i=line_i+1};   //  continue skip spaces next char
			= ps;                                      // found a none-space -> finished
	# (line,line_n,file) = read_line (line_n+1) file;  // goto next line
	| size line<>0
			= skip_spaces_ps {ps & line_i=0,line=line,line_n=line_n,file=file};  // continue skip spaces next line
	        = {ps & line_i=0,line=line,line_n=line_n,file=file};                // EOF reached  -> finished


read_entry n_braces first_i end_bracket ps=:{line_i,line,line_n,file}
	| line_i<size line
		| line.[line_i]=='{'
			= read_entry (n_braces+1) first_i end_bracket {ps & line_i=line_i+1};
		| line.[line_i]=='}' && n_braces>1
			= read_entry (n_braces-1) first_i end_bracket {ps & line_i=line_i+1};
		| line.[line_i]==end_bracket && n_braces==1
			= ([line % (first_i,line_i-1)],{ps & line_i=line_i+1});             // found end bracket, so return
		    = read_entry n_braces first_i end_bracket {ps & line_i=line_i+1};   // found end bracket but at wrong nesting level of { }, so continue searching for right one
    # (next_line,line_n,file) = read_line (line_n+1) file;
	| size line<>0
			# (lines,ps) = read_entry n_braces 0 end_bracket {ps & line_i=0,line=next_line,line_n=line_n,file=file}; // search further on next line
			= ([line % (first_i,size line-1):lines],ps);                                                             // return current line + lines found by further search
	| abort ("unexpected end of file while reading entry at line "+++toString line_n)       //reached EOF
			= ([],{ps & line_i=0,line=line,line_n=line_n,file=file});





// used for reading raw bib entries & for parsing bib entries
// used for reading identifier: used for entrykind, entryid, fieldname, and  for fieldvalue being just  a number/month (without surrounding "" or {} )
skip_ident i s
	| i<size s && (let {c = s.[i] } in isAlphanum c || c==':' || c=='_' || c=='-' || c=='/' || c=='.')
		= skip_ident (i+1) s;
		= i;



// parse entrylines of bibtex entry from  raw bibtex entry: @entrykind{<entrylines>}
// ----------------------------------------------------------------------------------




skip_spaces i s
	| i<size s && (s.[i]==' ' || s.[i]=='\t')
		= skip_spaces (i+1) s;
		= i;

string_to_lower s
	= {toLower c\\c<-:s};


parse_entries :: ![(Int,{#Char},[{#Char}])] [({#Char},{#Char})] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];
parse_entries [] variables
	= [];
parse_entries [(line_n,entry_kind,entry_list):entries] variables
	# entry_kind = string_to_lower entry_kind;
	| entry_kind=="inproceedings"
	|| entry_kind=="techreport"
	|| entry_kind=="article"
	|| entry_kind=="unpublished"
	|| entry_kind=="proceedings"
	|| entry_kind=="inbook"
	|| entry_kind=="incollection"
	|| entry_kind=="phdthesis"
	|| entry_kind=="mastersthesis"
	|| entry_kind=="book"
	|| entry_kind=="manual"
	|| entry_kind=="conference"
	|| entry_kind=="misc"
		# (entry_name,field_list) = parse_entry_name entry_list line_n;
		# field_list = parse_fields0 field_list line_n;
		= [(line_n,entry_kind,entry_name,field_list):parse_entries entries variables];
	| entry_kind=="preamble"
		= parse_entries entries variables;
	| entry_kind=="string"
		# field_list = parse_field_name0 entry_list line_n;
		= case field_list of {
			[(var_name,[var_value])]
				# variables = variables++[(var_name,var_value)];
				-> parse_entries entries variables;
			[(var_name,[var_value1,var_value2])]
				# var_value = var_value1+++var_value2;
				# variables = variables++[(var_name,var_value)];
				-> parse_entries entries variables;
			_
				-> abort ("Error in @string entry at line "+++toString line_n);
			}
		= abort ("Unknown entry "+++entry_kind+++" at line "+++toString line_n);
where {
	parse_entry_name [line:lines] line_n
		# i = skip_ident 0 line;
		| i==0
			= abort ("Error in name of entry at line "+++toString line_n);
		# name = line % (0,i-1);
		# i2 = skip_spaces i line;
		| i2<size line
			= (name,[line % (i2,size line-1):lines]);
			= (name,lines);

	parse_fields0 [line:lines] line_n
		= parse_fields 0 line lines line_n;
	parse_fields0 [] line_n
		= [];

	parse_fields i line lines line_n
		# i = skip_spaces i line;
		| i==size line
			= parse_fields0 lines line_n;
		| line.[i]==','
			= parse_field_name (i+1) line lines line_n;
			= abort (", expected in entry at line "+++toString line_n+++" ; maybe you forget the key field in the entry");

	parse_field_name0 [line:lines] line_n
		= parse_field_name 0 line lines line_n;

	parse_field_name i line lines line_n
		# i = skip_spaces i line;
		| i==size line
			= case lines of {
				[line:lines] -> parse_field_name 0 line lines line_n;
				[] -> [];
			  };
		# i2 = skip_ident i line;
		| i==i2
			= abort ("field name expected in entry at line "+++toString line_n);
		# field_name = line % (i,i2-1);
		# field_name = string_to_lower field_name;
		= parse_field_eq i2 line lines field_name line_n;

	parse_field_eq i line lines field_name line_n
		# i = skip_spaces i line;
		| i==size line
			= case lines of {
				[] -> abort ("= expected after "+++field_name+++" in entry at line "+++toString line_n);
				[line:lines] -> parse_field_eq 0 line lines field_name line_n;
			  };
		| line.[i]<>'='
			= abort ("= expected after "+++field_name+++" in entry at line "+++toString line_n);
			# (field_value,i,line,lines) = parse_field_value (i+1) line lines field_name line_n;
			# fields = parse_fields i line lines line_n;
			= [(field_name,field_value):fields];

	parse_field_value i line lines field_name line_n
		# i = skip_spaces i line;
		| i==size line
			= case lines of {
				[] -> abort ("{ expected after "+++field_name+++" = in entry at line "+++toString line_n);
				[line:lines] -> parse_field_value 0 line lines field_name line_n;
			  };
		| line.[i]=='{'
			= parse_field_value2 (i+1) line lines 1 '}' (i+1) field_name line_n
		| line.[i]=='"'
			= parse_field_value2 (i+1) line lines 1 '"' (i+1) field_name line_n
		# i2 = skip_ident i line;
		| i==i2
			= abort ("{ expected after "+++field_name+++" = in entry at line "+++toString line_n);
		# name = line % (i,i2-1);
		| is_number 0 name
			= parse_field_value3 i2 line lines name field_name line_n;
		# name = case string_to_lower name of {
			"jan" -> "January";
			"feb" -> "February";
			"mar" -> "March";
			"apr" -> "April";
			"may" -> "May";
			"jun" -> "June";
			"jul" -> "July";
			"aug" -> "August";
			"sep" -> "September";
			"oct" -> "October";
			"nov" -> "November";
			"dec" -> "December";
			name
				-> find_variable (string_to_lower name) variables;
	//			| trace_tn name
	//				->name
			}
		= parse_field_value3 i2 line lines name field_name line_n;

	parse_field_value2 i line lines n_braces end_char first_i field_name line_n
		| i==size line
			= case lines of {
				[] -> abort ("} expected after "+++field_name+++" = in entry at line "+++toString line_n);
				[next_line:lines]
					| first_i==size line
						-> parse_field_value2 0 next_line lines n_braces end_char 0 field_name line_n;
					# (value_lines,i,next_line,lines) = parse_field_value2 0 next_line lines n_braces end_char 0 field_name line_n;
					| first_i==0
						-> ([line:value_lines],i,next_line,lines);
						-> ([line % (first_i,size line-1):value_lines],i,next_line,lines);
			  };
		| line.[i]=='{'
			= parse_field_value2 (i+1) line lines (n_braces+1) end_char first_i field_name line_n;
		| line.[i]=='}' && n_braces>1
			= parse_field_value2 (i+1) line lines (n_braces-1) end_char first_i field_name line_n;
		| line.[i]==end_char && n_braces==1
			# value_line = line % (first_i,i-1);
			= parse_field_value3 (i+1) line lines value_line field_name line_n;
			= parse_field_value2 (i+1) line lines n_braces end_char first_i field_name line_n;

	parse_field_value3 i line lines value_line field_name line_n
		# i=skip_spaces i line;
		| i==size line
			= case lines of {
				[] -> ([value_line],i,line,lines);
				[line:lines] -> parse_field_value3 0 line lines value_line field_name line_n;
			  };
		| line.[i]<>'#'
			= ([value_line],i,line,lines);
			# (values_lines,i,line,lines) = parse_field_value (i+1) line lines field_name line_n;
			= ([value_line:values_lines],i,line,lines);
}

find_variable name [(var_name,var_value):variables]
	| var_name==name
		= var_value;
		= find_variable name variables;
find_variable name []
	| trace_tn ("variable "+++name+++" not defined")
		= name;

is_number i s
	| i<size s
		| isDigit s.[i]
			= is_number (i+1) s;
			= False;
		= True;




