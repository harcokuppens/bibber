module bibber;

import StdEnv,ArgEnv;

import BibtexParser;

import BibtexToBibtex;
import BibtexToHtml;
import BibtexRawOutput;

import CustomEvalAbort;
import CustomFileConsole;
import CustomString;
import CustomOptions;
import sortByCompares;

import LatexToHtml;

import CustomDebug;

//-------------------------------------------------------------------------
//
//-------------------------------------------------------------------------


get_field_value :: String [(String,[String])] -> String;
get_field_value name [(field_name,field_value):fields]
	| field_name==name
		= case field_value of {
			 [x]
				-> x;
			 [x:y]
			    -> concat_strings [x:y];
			 []
			    -> "";
			 _
			 	-> "unknown";
		};
	 	= get_field_value name fields;
get_field_value name []
	= "";



fields_match fieldname matchvalue  fields
     # fieldvalue = get_field_value fieldname fields
     = imatch_str 0 matchvalue fieldvalue;


// use on raw entries (not fully parsed yet)
is_string_entry (line_n,entry_kind,entry_list)
     # entry_kind = string_to_lower entry_kind;
     | entry_kind=="string"
         = True;
         = False;

//-------------------------------------------------------------------------
// helpers for --filter
//-------------------------------------------------------------------------




parse_str_filter :: {#Char} -> ({#Char},{#Char});
parse_str_filter  str_filter
    # mylst=split_str str_filter '=' ;
    # sizelst=length mylst;
//    # sizelst=size mylst;
    | sizelst==2
        = ((mylst !! 0 ), (mylst !! 1));
        = abort "invalid filter predicate";


filter_combo_entries  combo_entries str_filter
   #(fieldname,matchvalue) =  parse_str_filter  str_filter;
   = [ entry \\ entry=:((_,_,_,fields),_) <- combo_entries | fields_match fieldname matchvalue fields ];

//-------------------------------------------------------------------------
// helpers for --sort
//-------------------------------------------------------------------------



parse_signed_str :: {#Char} -> (Bool,{#Char});
parse_signed_str str
    # sign = str.[0];
    | sign == '-'
        # end=(size str)-1;
        # name = str % ( 1, end );
        = (False,name);
    | sign == '+'
        # end=(size str)-1;
        # name = str % ( 1, end ) ;
        = (True,name);
    = (True,str);


cmp_combo_on_fieldname fieldname ((_,_,_,fields_a),_) ((_,_,_,fields_b),_)
     # fieldvalue_a = get_field_value fieldname fields_a;
     # fieldvalue_b = get_field_value fieldname fields_b;
     = compare fieldvalue_a fieldvalue_b;

// get a compare function for a fieldname
get_cmp_combo signed_fieldname
    # (ascending,fieldname) = parse_signed_str signed_fieldname;
    | ascending == True
        = (cmp_combo_on_fieldname fieldname);
        = (cmpInv(cmp_combo_on_fieldname fieldname));  // invert sort order


//-------------------------------------------------------------------------
// helper for sorting/filter entries
//-------------------------------------------------------------------------


// note: an empty list for filter_predicates/signed_sort_fields means
//       that just no filter/sort is done
sort_filter_entries  parsed_entries  bib_entries filter_predicates signed_sort_fields

    // combine parsed and raw entries
    //   such that you can use parsed entries to do sorting/filtering for raw entries
    # combo_entries = [ (a,b) \\ a <-parsed_entries & b <- bib_entries ];

    // filter combo: apply all filters in serie (on parsed entry of combo)
    # combo_entries = foldl filter_combo_entries combo_entries filter_predicates;
    // note: foldl on empty list of filter_predicates just returns unfiltered list

    // sort combo on parsed entry
    cmps = [ get_cmp_combo x \\ x <- signed_sort_fields ];
    # combo_entries = sortByCompares cmps combo_entries;
    // note: sort on emptly list of cmps just returns  unsorted list

    // retreive parsed and raw bib_entries from sorted/filtered combo
    # parsed_entries = [ x \\  (x,_) <- combo_entries ]
    # bib_entries = [ x \\  (_,x) <- combo_entries ]
    //# bib_entries = [ snd entry \\  entry <- combo_entries ]
    = (parsed_entries, bib_entries);

//-------------------------------------------------------------------------
//    main
//-------------------------------------------------------------------------

usage_msg ::  {#Char};
usage_msg = "" +++
"bibber - bibtex tool to sort/filter bibtex and convert to different outputs\n" +++
"\n" +++
"usage: bibber  inputfile outputfile [--filter \"field:value,..\"]  [--sort \"[+-]field,..\"]\n" +++
"                [--output format]  [--latex2html]  [--limit-fields]\n" +++
"\n" +++
"where:\n" +++
"       inputfile:  input filename, if this is \"-\" input is read from stdin\n" +++
"       outputfile:  output filename, if this is \"-\" input is read from stdin\n" +++
"       output: output format which can be origbib,ppbib,html,htmlsectioned\n" +++
"               where htmlsectioned is sectioned on first sort field.\n" +++
"               If no sortfield is given \"-year\" is used.\n" +++
"               Default output format is \"origbib\". The origbib format means\n"  +++
"               outputting the bibtex entries with the original formatting as\n" +++
"               in the source file. The ppbib format however does output bibtex\n" +++
"               with pretty printing applied.\n" +++
"       latex2html: convert field values from latex to html\n" +++
"       limit-fields: limit output fields. Has no effect on output 'origbib'\n" +++
"                     which outputs the original bibtex only sorted and filtered.\n" +++
"\n";


write_usage file
	# file = file <<< usage_msg;
    = file;

OLDwrite_usage file
	# file = file <<<
"bibber - bibtex tool to sort/filter bibtex and convert to different outputs\n" <<<
"\n" <<<
"usage: bibber  inputfile outputfile [--filter \"field:value,..\"]  [--sort \"[+-]field,..\"]\n" <<<
"                [--output format]  [--latex2html]  [--limit-fields]\n" <<<
"\n" <<<
"where:\n" <<<
"       inputfile:  input filename, if this is \"-\" input is read from stdin\n" <<<
"       outputfile:  output filename, if this is \"-\" input is read from stdin\n" <<<
"       output: output format which can be origbib,ppbib,html,htmlsectioned\n" <<<
"               where htmlsectioned is sectioned on first sort field.\n" <<<
"               If no sortfield is given \"-year\" is used.\n" <<<
"               Default output format is \"origbib\". The origbib format means\n"  <<<
"               outputting the bibtex entries with the original formatting as\n" <<<
"               in the source file. The ppbib format however does output bibtex\n" <<<
"               with pretty printing applied.\n" <<<
"       latex2html: convert field values from latex to html\n" <<<
"       limit-fields: limit output fields. Has no effect on output 'origbib'\n" <<<
"                     which outputs the original bibtex only sorted and filtered.\n" <<<
"\n";
	= file;

standard_fields = ["address", "annote", "author", "booktitle", "chapter", "crossref", "edition", "editor", "eprint",
"howpublished", "institution", "journal", "key", "month", "note", "number", "organization", "pages",
"publisher", "school", "series", "title", "type", "url", "volume", "year"];
extra_fields = [ "url","urlpage", "ps","pszip","pdf","doi"];
custom_url_fields = [ "urlwebpage", "urlps", "urlpszip", "urlpdf", "urldoi", "urlabs"];
bibber_fields = ["tags"];

output_formats= ["rawbib","origbib","ppbib","html","htmlsectioned","template" ];

limited_fields ::  [{#Char}];
//limited_fields = [ "author", "year", "title" ];
limited_fields = standard_fields++extra_fields++custom_url_fields;

filter_fields_in_entry ::   (Int,{#Char},{#Char},[({#Char},[{#Char}])]) -> (Int,{#Char},{#Char},[({#Char},[{#Char}])]);
filter_fields_in_entry  (line_n,entry_kind,entry_name,field_list)
     # filtered_field_list = [ (name,value) \\  (name,value) <- field_list | isMember name limited_fields];
     //= (line_n,entry_kind,entry_name,filtered_field_list) ->> filtered_field_list;
     = (line_n,entry_kind,entry_name,filtered_field_list);

//entries::  [(line_n,entry_kind,entry_name,field_list):entries]
filter_fields:: [(Int,{#Char},{#Char},[({#Char},[{#Char}])])] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];
filter_fields []
    = [];
filter_fields [entry]
    = [filter_fields_in_entry entry];
filter_fields [entry:entries]
    = [filter_fields_in_entry entry: filter_fields entries];

// compare tuples
cmp1 :: (a,b) (a,b) -> (Bool,Bool)| < a & == a;
cmp1 (a,_) (b,_) = compare a b;

sort_fields_in_entry ::  (Int,{#Char},{#Char},[({#Char},[{#Char}])]) -> (Int,{#Char},{#Char},[({#Char},[{#Char}])]);
sort_fields_in_entry (line_n,entry_kind,entry_name,field_list)
     # sorted_field_list = sortByCompares [cmp1] field_list;
     = (line_n,entry_kind,entry_name,sorted_field_list);

//entries::  [(line_n,entry_kind,entry_name,field_list):entries]
sort_fields::  [(Int,{#Char},{#Char},[({#Char},[{#Char}])])] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];
sort_fields []
    = [];
sort_fields [entry]
    = [sort_fields_in_entry entry];
sort_fields [entry:entries]
    = [sort_fields_in_entry entry: sort_fields entries];

format_fields_in_entry ::  (String -> String) (Int,{#Char},{#Char},[({#Char},[{#Char}])]) -> (Int,{#Char},{#Char},[({#Char},[{#Char}])]);
format_fields_in_entry format (line_n,entry_kind,entry_name,field_list)
     # filtered_field_list = [ (name,map format value) \\  (name,value) <- field_list ];
     //= (line_n,entry_kind,entry_name,filtered_field_list) ->> filtered_field_list;
     = (line_n,entry_kind,entry_name,filtered_field_list);

//entries::  [(line_n,entry_kind,entry_name,field_list):entries]
format_fields:: (String -> String) [(Int,{#Char},{#Char},[({#Char},[{#Char}])])] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];
format_fields format []
    = [];
format_fields format [entry]
    = [format_fields_in_entry  format entry];
format_fields format [entry:entries]
    = [format_fields_in_entry format entry: format_fields format entries];

rev_sort fields = (reverse (sort fields));


Start :: !*World  -> *World;
Start w
    # argv = getCommandLine;
    //# testfile="W:\\projects\\systeembeheer_afdeling\\publications\\mbsd-bib\\tool\\test\\good.bib";
    //# argv = {# "prog" , testfile , "-", "--sort", "-year,+author" , "--filter", "author=luc,fyear=2008"};

    // next line forgets the options; you should first filter the options out
    // TODO:  split_options_positional_args :: argv -> options pos_args
    //        this allows options everywhere on the line
    | size argv < 3
        = errorAbort usage_msg;

    // cmdline arguments handling
    # input_filename = argv.[1];
    # output_filename = argv.[2];

    # sort_opt = get_long_option  argv "--sort";
    # signed_sort_fields = split_str sort_opt ',' ;

    # filter_opt = get_long_option  argv "--filter";
    # filter_predicates = split_str filter_opt ',' ;

    // get output type
	# output_opt = get_long_option  argv "--output";
    // default is rawbib
    # output_opt = if ( output_opt == "" ) "rawbib" output_opt
    // display error and usage message if unsupported type is give
    | not (isMember output_opt output_formats)
        # usage_msg = "ERROR: invalid output type: " +++ output_opt  +++ "\n\n" +++ usage_msg;
        = errorAbort usage_msg;


    // boolean opts
	# limit_fields_opt = isMember "--limit-fields"  [ x \\ x <-: argv];
	# sort_fields_opt = isMember "--sort-fields"  [ x \\ x <-: argv];
	# latex2html_opt = isMember "--latex2html"  [ x \\ x <-: argv];
	# verbose_opt = isMember "--verbose"  [ x \\ x <-: argv];

	// open input file/stdin ( latter when input_filename="-")
	# (input_file,w) = file_open_read input_filename w;
	// read raw bibtex entries from input
    # (entries,input_file) = read_bib_file input_file;
    # w = file_close input_file  w;


    // split raw entries in raw string definitions and raw bibtex entries
    # string_entries = [ entry \\ entry=:(_,x,_) <- entries | string_to_lower x == "string"  ];
    # bib_entries = filter (not o is_string_entry) entries;

    //# counter = fromInt (length bib_entries);
    # counter_parsed = length bib_entries;

    // parse raw entries into parsed entries
    # parsed_entries = parse_entries entries [];
    //__parse_entries :: ![(Int,{#Char},[{#Char}])] [({#Char},{#Char})] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];

    // format latex strings in bibtex fields to html 
    //#  parsed_entries  = format_fields ( \x -> "-->"+++x+++"<--" ) parsed_entries;
    # parsed_entries  = if latex2html_opt (format_fields str_latex2html parsed_entries) parsed_entries;

    // sort/filter parsed and raw entries  using parsed entries
    # (parsed_entries, bib_entries) = sort_filter_entries  parsed_entries  bib_entries filter_predicates signed_sort_fields;

    // count sorted entries
    # counter_sorted = length bib_entries;

    // limit fields in parse entries.
    // Note: only possible for parsed entries because only there we have access to fields.
    # parsed_entries = if limit_fields_opt (filter_fields parsed_entries) parsed_entries;

    # parsed_entries = if sort_fields_opt (sort_fields parsed_entries) parsed_entries;


    # (output_file,w) = file_open_write output_filename w;
    # output_file = case output_opt of {
          "rawbib" // write raw bibtex entries filtered and sorted
              # filteredsorted_raw_entries = string_entries++bib_entries
              -> write_raw_entries filteredsorted_raw_entries output_file;
          "ppbib" // write pretty printed bibtex
              -> write_bib_entries parsed_entries output_file;
          "html"
              -> write_entries_as_html parsed_entries output_file;
          "htmlsectioned"
              -> write_entries_as_html_sorted_by_field  rev_sort get_field_value "year"   parsed_entries output_file;
          "template"
              -> write_entries_as_html_sorted_by_field  rev_sort get_field_value "year"   parsed_entries output_file;
	       _  // output_opt already validated earlier to be one of above values
              -> errorAbort "should not be reached"
	  }

   /*
    # (output_file,w) = file_open_write output_filename w;
    # filteredsorted_raw_entries = string_entries++bib_entries
    # output_file = write_raw_entries filteredsorted_raw_entries output_file;
	# w = file_close output_file  w;
   */
    # w = file_close output_file  w;

    // only following line doesn't work
    //# stderr = if verbose_opt ( fwrites counter stderr ) stderr <--- w;
    // instead use next line without <---w (otherwise uniques problem) and close stderr
    # stderr = if verbose_opt (  stderr <<< "number of entries parsed: " <<< counter_parsed <<< "\n" ) stderr;
    # stderr = if verbose_opt (  stderr <<< "number of entries used (entries left over after filtering): " <<< counter_sorted <<< "\n" ) stderr;
    # w = file_close  stderr  w;
	= w;

/*
	= finished w "end or program";
*/

// force eval world and return something else
finished :: !*World a -> a;
finished w result = result;


