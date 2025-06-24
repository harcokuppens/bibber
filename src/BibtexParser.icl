implementation module BibtexParser;


import StdEnv,StdStrictLists,StdOverloadedList;
import StdDebug;

// Parsing State record (PS); unique typed value passed along as environment/state! 
// All fields in record are strict. The line field is a string, which is an unboxed array of chars.
:: *PS = {
	 line_i :: !Int,     // current index inside current line string (starting with 0; strings are indexed from 0 to size-1) -> better name would be column!
	 line   :: !{#Char}, // current line string
	 line_n :: !Int,     // current line number; first line in file is line 1 ! 
	 file   :: !*File    // current state of file (how far read)
};



// read in line with data ( skipped comments and empty lines)
// ----------------------------------------------------------

remove_newline s
	# n=size s;
	| n>0
	    | s.[n-1]=='\r'
		   = s % (0,n-2);
	    | s.[n-1]=='\n'
	       | n>=2 && s.[n-2]=='\r'
		   // fixed bug// | s.[n-2]=='\r'
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


// next type declaration not needed, because clean automatically infers that ps must be of type PS 
// which defines a record! (because no alternative record defined which matches)
// note: fields of PS record are defined strict, so when calling "read_entries ps", 
//       then fields in ps argument are immediately evaluated! (record then created, strictness then requires it then to be immediately evaluated!)
read_entries :: *PS -> ([(Int,{#Char},.[{#Char}])],*PS);
read_entries ps
    // first read optional spaces to next entry 
	//   check for EOF
	// then read @ (aborts if not found) with identifier directly after it,  
	//   check id found not empty 
	// then read either { or ( and then read to matching } or ) -> gives entry_lines
	// then entry found and recursively call to find remaining entries
	// and return list of entries with at head of list current found entry and as tail recursively found entries
	# ps = skip_spaces_ps ps;
	| size ps.line==0             // EOF reached, ok we are finished parsing all entries succesfull! (no abort needed!)
		= ([],ps);
	# ps = skip_to_char_ps '@' ps;
	#! i = ps.line_i;
	#! line = ps.line;
	#! line_n = ps.line_n;
	# i2 = skip_ident i line;
	| i2==i
	    // no identifier found
		= abort ("Error at line "+++toString ps.line_n+++" entry kind expected after @");
	# entry_kind = line % (i,i2-1);
	# ps = {ps & line_i=i2,line=line};
	# (end_bracket,ps) = skip_to_bracket_ps ps;           //find starting { or (, then we know end_bracket is } or )
	#! line_i = ps.line_i;
	# (entry_lines,ps) = read_entry 1 line_i end_bracket ps;  // read lines from entry until end_bracket found
	# (entries,ps) = read_entries ps;
	= ([(line_n,entry_kind,entry_lines):entries],ps);
    //  => entry is (line_n,entry_kind,entry_lines)
	//                `-> line where entry starts with @ENTRYKIND 
	//                    read_entry hides line where entry ends in line_n in ps!

// find char in current line; only if we find % in line we continue on next line. If found return with also space behind c removed, otherwise we stop search at end of line with abort if not found. 
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

// read chars until { or (  found on current line; skip_spaces_ps lets you continue on next line if % read 
// note: it allows any char befor it! -> to liberal, should be more strict!
skip_to_bracket_ps ps=:{line_i,line,line_n}
	| line_i<size line
		| line.[line_i]=='{'
			= ('}',skip_spaces_ps {ps & line_i=line_i+1});
		| line.[line_i]=='('
			= (')',skip_spaces_ps {ps & line_i=line_i+1});
		= skip_to_bracket_ps {ps & line_i=line_i+1};
	= abort (" { or ( expected at line "+++toString line_n);

// skip found spaces and tabs until either a none-space-or-tab char is found or at EOF
skip_spaces_ps ps=:{line_i,line,line_n,file}
	| line_i<size line
		| line.[line_i]==' ' || line.[line_i]=='\t'
			= skip_spaces_ps {ps & line_i=line_i+1};   //  continue skip spaces next char
		= ps;                                      // found a none-space -> finished
	# (line,line_n,file) = read_line (line_n+1) file;  // goto next line
	| size line<>0
		= skip_spaces_ps {ps & line_i=0,line=line,line_n=line_n,file=file};  // continue skip spaces next line
	= {ps & line_i=0,line=line,line_n=line_n,file=file};   // EOF reached  (size line == 0, no newline)


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




// skip identifier
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

// parse_entries gets list of entries, where entry is (line_n,entry_kind,entry_lines)
//  returns list of parse entries where a parsed entry looks like
//     (line_n,entry_kind,entry_name,field_list)
//  where field_list = list of (fieldname,fieldvalue)
//  where fieldvalue = list of strings   ( because in bibtex a field value can be a concatenate list of strings using # operator)
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
	    // skip preamble
		= parse_entries entries variables;
	| entry_kind=="string"
	    // string abbreviation to be used in bibtex entries
		// store in list as tuple of (str_abbreviation, str_value)
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
		    // no identifier found
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
		  // empty line found
			= case lines of {
				[line:lines] -> parse_field_name 0 line lines line_n;
				[] -> [];
			  };
		# i2 = skip_ident i line;
		| i==i2
		    // no identifier found
			= abort ("field name expected in entry at line "+++toString line_n);
		// get fieldname , and then call parse_field_eq to get = after fieldname
		# field_name = line % (i,i2-1);
		# field_name = string_to_lower field_name;
		= parse_field_eq i2 line lines field_name line_n;

    // get = 
	parse_field_eq i line lines field_name line_n
		# i = skip_spaces i line;
		| i==size line
		   // empty line found (or rest of line empty from i)
			= case lines of {
				[] -> abort ("= expected after "+++field_name+++" in entry at line "+++toString line_n);
				[line:lines] -> parse_field_eq 0 line lines field_name line_n;
			  };
		| line.[i]<>'='
			= abort ("= expected after "+++field_name+++" in entry at line "+++toString line_n);
			// found = , now call parse_field_value to get value of field
			# (field_value,i,line,lines) = parse_field_value (i+1) line lines field_name line_n;
			# fields = parse_fields i line lines line_n;
			= [(field_name,field_value):fields];

    // get value of field(name)
	parse_field_value i line lines field_name line_n
		# i = skip_spaces i line;
		| i==size line
		    // empty line (or rest of line empty from i)
			= case lines of {
				[] -> abort ("{ expected after "+++field_name+++" = in entry at line "+++toString line_n);
				[line:lines] -> parse_field_value 0 line lines field_name line_n;
			  };
		// if { or " found, call parse_field_value2 to get field value between {...} or "..."
		| line.[i]=='{'
			= parse_field_value2 (i+1) line lines 1 '}' (i+1) field_name line_n
		| line.[i]=='"'
			= parse_field_value2 (i+1) line lines 1 '"' (i+1) field_name line_n
		// field value directly , not between {...} or "..."
		# i2 = skip_ident i line;
		| i==i2
		    // no identifier found!!
			= abort ("{ expected after "+++field_name+++" = in entry at line "+++toString line_n);
		// value found
		//   value can be an integer
		# name = line % (i,i2-1);
		| is_number 0 name
			= parse_field_value3 i2 line lines name field_name line_n;
		//   value can be a month
		//   value can be and abbreviation
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

    // parse  {value} or "value"
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
		// parse nested {   number of braces given by n_braces' 
		| line.[i]=='{'
			= parse_field_value2 (i+1) line lines (n_braces+1) end_char first_i field_name line_n;
		| line.[i]=='}' && n_braces>1
			= parse_field_value2 (i+1) line lines (n_braces-1) end_char first_i field_name line_n;
		| line.[i]==end_char && n_braces==1
		    // value between begin end char found 
			# value_line = line % (first_i,i-1);
			// value found, now parse to check if after value we have # to concatenate another value
			= parse_field_value3 (i+1) line lines value_line field_name line_n;
			// recursive call to next char at i+1
			= parse_field_value2 (i+1) line lines n_braces end_char first_i field_name line_n;

	parse_field_value3 i line lines value_line field_name line_n
		# i=skip_spaces i line;
		| i==size line
		    // empty space found on line
		    // if we have more lines continue with next line,
			// otherwise value is just value_line 
			= case lines of {
				[] -> ([value_line],i,line,lines);
				[line:lines] -> parse_field_value3 0 line lines value_line field_name line_n;
			  };
		// # is operator to concatenate strings in bibtex
		| line.[i]<>'#'
		    // no concatenate operator found, so value is value_line 
			= ([value_line],i,line,lines);
			// concatenate operator found; parse for another field after the # char 
			# (values_lines,i,line,lines) = parse_field_value (i+1) line lines field_name line_n;
			= ([value_line:values_lines],i,line,lines);
}

// lineair loop through list of tuples until var_name found and its matching value
// if not found then display a message to stderr and return the name itself (no abort done)
find_variable name [(var_name,var_value):variables]
	| var_name==name
		= var_value;
		= find_variable name variables;
find_variable name []
	| trace_tn ("variable "+++name+++" not defined")
		= name;

// loop through chars and if each char is a digit then it is a number
is_number i s
	| i<size s
		| isDigit s.[i]
			= is_number (i+1) s;
			= False;
		= True;




