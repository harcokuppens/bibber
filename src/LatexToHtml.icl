implementation module LatexToHtml;

import StdEnv,StdStrictLists,StdOverloadedList;
import StdDebug;


class (<<<<) infixl a :: ![{#Char}] !a -> [{#Char}];
/*	Overloaded write to file */

//instance <<<< Int;
//instance <<<< Real


instance <<<< {#Char} where {
  (<<<<) :: ![{#Char}] !{#Char} -> [{#Char}];
  (<<<<) list_of_strs str =  list_of_strs ++ [str];
}

instance <<<< Char  where {
  (<<<<) :: ![{#Char}] !Char -> [{#Char}];
  (<<<<) list_of_strs ch =  list_of_strs ++ [(toString ch)];
}


skip_arg i s
	| i<size s
		| s.[i]=='{'
			= skip_arg2 (i+1) s;
		| s.[i]==' ' || s.[i]=='\t'
			= skip_arg (i+1) s;
			= abort "{ expected after \\noopsort";
		= abort "{ expected after \\noopsort";

skip_arg2 i s
	| i<size s
		| s.[i]=='}'
			= i+1;
			= skip_arg2 (i+1) s;
		= abort "} expected after \\noopsort{";

write_string_to :: !String ![String] -> [String];
write_string_to string destination = destination++[string];

write_char_to :: !Char ![String] -> [String];
write_char_to char destination = destination++[(toString char)];


concat_strings [s] = s;
concat_strings [s1:s2:ss] = concat_strings [s1+++s2:ss];
concat_strings [] = "";


str_latex2html :: !{#Char} -> {#Char};
str_latex2html str
     # str_list = latex2html 0 str [];
     //# str_list = [ "sfs", "sdf" ];
     //= toString str_list;
     = concat_strings str_list;
     //= foldl (+++) "" str_list;


//latex2html :: Int (a Char) *File -> .File | Array a Char;
latex2html :: !Int !String ![String] -> [String];
latex2html i s file
	| i<size s
		# c=s.[i];
		| c=='{' || c=='}' || c=='$'
			= latex2html (i+1) s file;
		| c=='~'
			# file = write_string_to "&nbsp;" file;
			= latex2html (i+1) s file;
		| c=='-' && i+1<size s && s.[i+1]=='-'
			# file = write_char_to c file;
			= latex2html (i+2) s file;
		| c=='\\'
			| i+8<size s && s.[i+1]=='n' && s.[i+2]=='o' && s.[i+3]=='o' && s.[i+4]=='p'
						 && s.[i+5]=='s' && s.[i+6]=='o' && s.[i+7]=='r' && s.[i+8]=='t'
				# i = skip_arg (i+9) s;
				= latex2html i s file;
			| i+6<size s && s.[i+1]=='l' && s.[i+2]=='a' && s.[i+3]=='m'
						 && s.[i+4]=='b' && s.[i+5]=='d' && s.[i+6]=='a'
				# file = write_string_to "&\lambda;" file;
				= latex2html (i+7) s file;
			| i+3<size s && s.[i+1]=='u' && s.[i+2]=='r' && s.[i+3]=='l'
				= latex2html (i+4) s file;
			| i+6<size s && s.[i+1]=='t' && s.[i+2]=='e' && s.[i+3]=='x'
						 && s.[i+4]=='t' && s.[i+5]=='s' && s.[i+6]=='f'
				= latex2html (i+7) s file;
			| i+6<size s && s.[i+1]=='t' && s.[i+2]=='e' && s.[i+3]=='x'
						 && s.[i+4]=='t' && s.[i+5]=='t' && s.[i+6]=='t'
				= latex2html (i+7) s file;
			| i+1<size s
				# c=s.[i+1]
				| c=='&'
					# file = write_char_to c file;
					= latex2html (i+2) s file;
				| c=='-'
					= latex2html (i+2) s file;

				| c=='~'
					| i+2<size s && is_tilde_char s.[i+2]
						= latex2html (i+3) s (file <<<< '&' <<<<s.[i+2] <<<< "tilde;");
					| i+4<size s && s.[i+2]=='{' && is_tilde_char s.[i+3] && s.[i+4]=='}'
						= latex2html (i+5) s (file <<<< '&' <<<<s.[i+3] <<<< "tilde;");
						# file = write_char_to s.[i] file;
						# file = write_char_to c file;
						= latex2html (i+2) s file;
				| c=='"'
					| i+2<size s && is_uml_char s.[i+2]
						= latex2html (i+3) s (file <<<< '&' <<<< s.[i+2] <<<< "uml;");
					| i+4<size s && s.[i+2]=='{' && is_uml_char s.[i+3] && s.[i+4]=='}'
						= latex2html (i+5) s (file <<<< '&' <<<< s.[i+3] <<<< "uml;");
						# file = write_char_to s.[i] file;
						# file = write_char_to c file;
						= latex2html (i+2) s file;
				| c=='\''
					| i+2<size s && is_acute_char s.[i+2]
						= latex2html (i+3) s (file <<<< '&' <<<< s.[i+2] <<<< "acute;");
					| i+4<size s && s.[i+2]=='{' && is_acute_char s.[i+3] && s.[i+4]=='}'
						= latex2html (i+5) s (file <<<< '&' <<<< s.[i+3] <<<< "acute;");
						# file = write_char_to s.[i] file;
						# file = write_char_to c file;
						= latex2html (i+2) s file;
				| c=='^'
					| i+2<size s && is_circ_char s.[i+2]
						= latex2html (i+3) s (file <<<< '&' <<<< s.[i+2] <<<< "circ;");
					| i+4<size s && s.[i+2]=='{' && is_circ_char s.[i+3] && s.[i+4]=='}'
						= latex2html (i+5) s (file <<<< '&' <<<< s.[i+3] <<<< "circ;");
						# file = write_char_to s.[i] file;
						# file = write_char_to c file;
						= latex2html (i+2) s file;

					# file = write_char_to s.[i] file;
					# file = write_char_to c file;
					= latex2html (i+2) s file;
				= write_char_to c file;
			# file = write_char_to c file;
			= latex2html (i+1) s file;
		= file;



is_acute_char c = c=='a' || c=='e' || c=='o' || c=='u';
is_tilde_char c = c=='a' || c=='n';
is_uml_char c = c=='a' || c=='e' || c=='o' || c=='u';
is_circ_char c = c=='o';
