implementation module CustomOptions;

import StdEnv;

get_last_string :: ![u:{#.Char}] -> v:{#Char}, [u <= v];
get_last_string [] = "";
get_last_string [a] = a;
get_last_string [_:b] = get_last_string b;



// get last of all long options
get_long_option :: u:(a v:{#.Char}) {#.Char} -> {#Char} | Array a {#Char}, [u <= v];
get_long_option argv long_option
    # options =  (get_long_options 0 argv long_option);
    //# options = options <<- options;
    = get_last_string options;

get_long_options :: !Int (a {#Char}) {#Char} -> .[{#Char}] | Array a {#Char};
get_long_options n argv long_option
    | (n+1) > size argv
        = [];
    | argv.[n] == long_option
          = [ argv.[n+1]  : get_long_options (n+2) argv long_option];
          = get_long_options (n+1) argv long_option;

