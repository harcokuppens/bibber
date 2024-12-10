definition module BibtexToHtml

import StdEnv,StdStrictLists,StdOverloadedList;
import StdDebug;

write_entries_as_html :: [(Int,String,String, [(String,[String])] )] *File -> *File;

write_entries_as_html_sorted_by_field :: ([String] -> [String]) (String [(String,[String])] -> String)  String [(Int,String,String, [(String,[String])] )] *File -> *File;


