implementation module CustomFileConsole;

import StdFile,StdMisc,StdBool,StdString;

file_open_write :: !{#Char} *a -> (*File,*a) | FileSystem a;
file_open_write  filename  w
    | filename == "-"
           = stdio w;
	# (ok,file,w) = fopen filename FWriteText w;
	| not ok
		= abort ("Could not open file for writing: "+++filename);
	= (file,w);

file_open_read :: !{#Char} *a -> (*File,*a) | FileSystem a;
file_open_read  filename  w
    | filename == "-"
           = stdio w;
	# (ok,file,w) = fopen filename FReadData w;
	| not ok
		= abort ("Could not open file for reading: "+++filename);
	= (file,w);

file_close :: *File *a -> *a | FileSystem a;
file_close  file  w
	# (ok,w) = fclose file w;
	| not ok
		= abort ("Error closing file");
	= w;

