definition module BibtexParser;

read_bib_file :: *File -> ([(Int,{#Char},.[{#Char}])],.File);

parse_entries :: ![(Int,{#Char},[{#Char}])] [({#Char},{#Char})] -> [(Int,{#Char},{#Char},[({#Char},[{#Char}])])];
