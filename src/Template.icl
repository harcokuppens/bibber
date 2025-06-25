implementation module Template;

import StdEnv,ArgEnv;
import StdString;

// TemplateVarOrString is an algebraic type that can be either a template variable or a string
// - TemplateVar is a template variable with a name
// - Str is just a string in the template
// The full template is a concatenation of list of TemplateVarOrString
:: TemplateVarOrString
    = TemplateVar String
    | Str String;

// type synonyms
// - Template is a list of TemplateVarOrString (template variables and strings)
:: Template :== [TemplateVarOrString];
// - Variables is a list of tuples (name,value) where name is the template variable name and value is the value to fill in
//   for the template variable 
:: Variables :== [(String,String)];

/** parse template from a string
 *  template variables are embedded in the string using "{{VARNAME}}" syntax
 *  VARNAME may be surrounded with whitespace with {{ }}.
 */
parseTemplate :: String -> Template;
parseTemplate str
    = reverse ( parseParts [] str );
where {
    parseParts acc s 
        | s == "" = acc
        # (prefix, rest1) = splitAtFirst "{{" s;
        | prefix == s = [Str prefix : acc]; // no {{ found
        // {{ found
        // note if str ends with "{{" then we have match, but it will be regarded as string because no matchin "}}" in string
        # (var, rest2) = splitAtFirst "}}" rest1;
        | var == rest1 = [Str s : acc];  // we found {{ but no }} , so malformed, we treat s just as string with {{ in it.
        # var = strip var
        = parseParts [TemplateVar var : Str prefix : acc] rest2;
}

// Helper function to find the index of the first occurrence of a delimiter in a string
// Returns -1 if the delimiter is not found
findIndex :: String Int String -> Int;
findIndex delim idx str
   // first check if delim fits in remaining string
   # size_delim = size delim ;
   # remaining_size = size str - idx ;
   | size_delim  >  remaining_size 
       =  -1; // Return -1 if the delim is not found
   // check delim matches str at current idx    
   # slicestr = str % ( idx , idx + (size_delim-1)  );
   | slicestr == delim 
      = idx; // yes, delim found at i !
   | otherwise
   //| trace_tn ("findidx "+++(toString idx)+++" ")
       // delim not found, search at next idx
       =  findIndex delim (idx+1) str;

// Helper function to split a string at the first occurrence of a delimiter
splitAtFirst :: String String -> (String, String);
splitAtFirst delim str
    # i = findIndex delim 0 str;
    | i == -1 
        = (str, ""); // Delimiter not found
    | otherwise 
        # before = str % (0,i-1);
        # begin_idx =  i + size delim;
        # end_idx =  size str - 1 ;
        # after = str % (begin_idx, end_idx );
        = ( before  , after );
        //= (take i str, drop (i + size delim) str);

// Helper function to find the first non-space character in a string
find_first_none_space i s
	| i<size s && (s.[i]==' ' || s.[i]=='\t')
		= find_first_none_space (i+1) s;
    | i == size s = -1; // not found ; string is only whitespace     
	| otherwise	= i;

// Helper function to find the last non-space character in a string
find_last_none_space i s
	| i > -1 && (s.[i]==' ' || s.[i]=='\t')
		= find_last_none_space (i-1) s;
    | i == -1 = -1; // not found ; string is only whitespace
    | otherwise = i;

// Helper function to strip space characters at beginning of a string
lstrip :: String -> String;
lstrip s 
   # i = find_first_none_space 0 s;
   | i == -1 = "";
   | otherwise = s % (i, size s - 1);

// Helper function to strip space characters at end of a string
rstrip :: String -> String;
rstrip s 
   # i = find_last_none_space (size s - 1) s;
   | i == -1 = "";
   | otherwise = s % (0, i);   

// Helper function to strip space characters at beginning and end of a string
strip :: String -> String;
strip s = (lstrip o rstrip) s;


// Concatenate strings using foldl
concatStrings :: [String] -> String;
concatStrings lst = (foldl (+++) "") lst;


processTemplateVarOrString :: Variables TemplateVarOrString  -> String;
processTemplateVarOrString variables template_part  = case template_part of {
    (TemplateVar var) ->  find_variable var variables;
    (Str s) ->  s;
};

processTemplateVarOrStringOrAbort :: Variables TemplateVarOrString  -> String;
processTemplateVarOrStringOrAbort variables template_part  = case template_part of {
    (TemplateVar var) ->  find_variable_or_abort var variables;
    (Str s) ->  s;
};

/** fill template with values from variables
 *  when a value is not given for a template variable
 *  then {{VARNAME}} is being output to show a forgotten variable in the output.
 */
fillTemplate :: Variables Template  -> String;
fillTemplate  variables template = concatStrings ( map (processTemplateVarOrString variables) template  );


/** fill template with values from variables
 *  when a value is not given for a template variable
 *  the program is aborted with an error.
 */
fillTemplateOrAbort :: Variables Template  -> String;
fillTemplateOrAbort  variables template = concatStrings ( map (processTemplateVarOrStringOrAbort variables) template  );

// lineair loop through list of tuples until var_name found ant its matching value
find_variable name [(var_name,var_value):variables]
	| var_name==name
		= var_value;
		= find_variable name variables;
find_variable name []
	//| trace_tn ("variable "+++name+++" not defined")
    // variable not define, just leave template var in output with its {{ }}.
		= "{{" +++ name +++ "}}";

// lineair loop through list of tuples until var_name found ant its matching value
find_variable_or_abort name [(var_name,var_value):variables]
	| var_name==name
		= var_value;
		= find_variable_or_abort name variables;
find_variable_or_abort name []
	//| trace_tn ("variable "+++name+++" not defined")
    // variable not define, abort with error
		= abort ("Error: required variable '"+++name+++"' to fill template not given.\n");


/** 
 *  get the template variables used in the template
 *  returns a list of variable names as strings
 */
getTemplateVariables :: Template -> [String];
getTemplateVariables template = getTemplateVariables_acc template [];
where {
    getTemplateVariables_acc :: Template [String] -> [String];
    getTemplateVariables_acc [] acc = acc;
    getTemplateVariables_acc [TemplateVar var : xs] acc = getTemplateVariables_acc xs [var : acc];
    getTemplateVariables_acc [Str str : xs] acc = getTemplateVariables_acc xs acc;
}    
