definition module CustomString;
import StdEnv;

concat_strings :: ![{#Char}] -> {#Char};

string_to_lower:: {#Char} -> {#Char};

// assume size s1<=size s2
is_prefix :: !Int (a b) (c b) -> Bool | == b & Array c b & Array a b;

is_substr :: !Int !Int !{#Char} !{#Char} -> Bool;


match_str :: !Int !{#Char} !{#Char} -> Bool;

imatch_str:: !Int !{#Char} !{#Char} -> Bool;

split_str :: {#Char} Char -> [{#Char}];

// split string using splitterChar
get_value :: !Int !Int !Char !String -> [String];
