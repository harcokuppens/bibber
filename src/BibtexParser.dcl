definition module BibtexParser;

read_bib_filename :: !{#Char} !*World -> *(![(Int,{#Char},[{#Char}])],!*World);

read_bib_file :: *File -> ([(Int,{#Char},.[{#Char}])],.File);

parse_entries :: ![(Int,{#Char},[{#Char}])] [({#Char},{#Char})] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];

//read_bib_file_entries :: .Int *File -> ([(Int,{#Char},.[{#Char}])],.File);