implementation module CustomString;

import StdEnv;

//-------------------------------------------------------------------------
//    String lib
//-------------------------------------------------------------------------

concat_strings :: ![{#Char}] -> {#Char};
concat_strings [s] = s;
concat_strings [s1:s2:ss] = concat_strings [s1+++" "+++s2:ss];
concat_strings [] = "";


string_to_lower:: {#Char} -> {#Char};
string_to_lower s
	= {toLower c\\c<-:s};



// assume size s1<=size s2
is_prefix :: !Int (a b) (c b) -> Bool | == b & Array c b & Array a b;
// _is_prefix :: !Int !{#Char} !{#Char} -> Bool
// _is_prefix :: !Int !String !String -> Bool
is_prefix i s1 s2
	| i<size s1
		= s1.[i]==s2.[i] && is_prefix (i+1) s1 s2;
		= True;


is_substr :: !Int !Int !{#Char} !{#Char} -> Bool;
is_substr offset_s2 i s1 s2
	| i<size s1
		= s1.[i]==s2.[i+offset_s2] && is_substr  offset_s2 (i+1) s1 s2;
		= True;



/*
// match for list of chars (not for array of chars)
str_match [m:ms] [h:hs]
   = m == h && str_match ms hs;
str_match [_:_] []
   = False;
str_match [] a
   = True;

*/

match_str :: !Int !{#Char} !{#Char} -> Bool;
match_str offset_s2 s1 s2
   | (size s1) + offset_s2 > (size s2)
       = False;
   | is_substr offset_s2 0 s1 s2
       = True;
       = match_str (offset_s2+1) s1 s2;


imatch_str:: !Int !{#Char} !{#Char} -> Bool;
imatch_str i s1 s2
   = match_str  i (string_to_lower s1) (string_to_lower s2);



split_str :: {#Char} Char -> [{#Char}];
split_str  str splitterChar = get_value 0 0 splitterChar str;

// split string using splitterChar
get_value :: !Int !Int !Char !String -> [String];
get_value start_i current_i splitterChar str
   | current_i <size str                         // check if eof
       | str.[current_i]==splitterChar
            | start_i == current_i      // first char found is splitterChar
                  = get_value (current_i+1) (current_i+1) splitterChar str; // continue after splitterChar
            # value = str % (start_i,current_i-1);             // value for splitter
            # values = get_value (current_i+1) (current_i+1) splitterChar str;   // values after splitter
            = [value:values];
            = get_value start_i (current_i+1) splitterChar str;  // continue next char
   | start_i < size str
       # value = str % (start_i,(size str)-1);
       = [value];
       = [];