definition module CustomOptions;

import StdEnv;

get_last_string :: ![u:{#.Char}] -> v:{#Char}, [u <= v];


// get last of all long options
get_long_option :: u:(a v:{#.Char}) {#.Char} -> {#Char} | Array a {#Char}, [u <= v];


get_long_options :: !Int (a {#Char}) {#Char} -> .[{#Char}] | Array a {#Char};