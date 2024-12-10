implementation module BibtexRawOutput;
import StdEnv;

write_raw_entries :: ![(.a,b,[{#.Char}])] *File -> .File | <<< b;
write_raw_entries [(line_n,entry_kind,entry_lines):entries] file
	# file = file <<< '@' <<< entry_kind <<< '{';
	# file = write_bib_lines  entry_lines file;
	# file = file <<< "}\n\n";
	= write_raw_entries entries file;
write_raw_entries [] file
	= file;


write_line :: !.Int !{#.Char} !*File -> .File;
write_line i s file
    | i<size s
       = fwrites s file;
    = file;

write_bib_lines :: ![{#.Char}] !*File -> .File;
write_bib_lines [line] file
	= write_line 0 line file;
write_bib_lines [line:lines] file
	# file = write_line 0 line  file;
	# file = fwrites "\n" file;
	= write_bib_lines lines file;
write_bib_lines [] file
	= file;
