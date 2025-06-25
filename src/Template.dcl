definition module Template;


/**
 *  Template is a string containing template variables which can be filled in
 *  with values from a list of variables.
 *  Template is exported as an abstract data type.
 */
:: Template ;


/** 
 *  Variables is a type synonym for a list of tuples (name,value) where name is the template variable name 
 *  and value is the value to fill in for the template variable 
 */
:: Variables :== [(String,String)];


/** 
 *  get the template variables used in the template
 *  returns a list of variable names as strings
 */
getTemplateVariables :: Template -> [String];


/** parse template from a string
 *  template variables are embedded in the string using "{{VARNAME}}" syntax
 *  VARNAME may be surrounded with whitespace with {{ }}.
 */
parseTemplate :: String -> Template;

/** fill template with values from variables
 *  when a value is not given for a template variable
 *  then {{VARNAME}} is being output to show a forgotten variable in the output.
 */
fillTemplate :: Variables Template  -> String;

/** fill template with values from variables
 *  when a value is not given for a template variable
 *  the program is aborted with an error.
 */
fillTemplateOrAbort :: Variables Template  -> String;


// when parsing bibtex entries we should verify all required fields for the template are in the bibtex otherwise do not accept
//  -> a semi-semantic check
// parse templates: [(entrykind,Template)]
// from Template -> list of vars   =>   [(entrykind,vars)] -> we use this to check al required vars are in an entry
//    check_for_missing_fieldname  entry vars  -> missing var or ""
//     if not var=="" abort with error entry at line x misses fieldname  var!

// in parsed entry merges  fieldvalue of [string] to single string (multiples strings caused by # operator in bibtex )
//  note: abbreviations are immmediately filled in at parsing => cannot be recontstructed when generating bibtex source
//   when output html or neat bib then string parts of field value are just concatenate separated with ' ' 
//   WHY not done immediately when parsing??
///   => KISS: rewrite this!