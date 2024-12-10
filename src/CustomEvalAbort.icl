implementation module CustomEvalAbort;

import StdMisc,StdFile;


// force evaluation of x using  helper which is evaluated later
use :: .a !.b -> .a;
use helper x = helper;
// helper is used/evaluated later, thus function must be evaluated, and because !b type,
// the second argument is strict and must be evaluated before calling this function!

// operator to force evaluation of x using  helper which is evaluated now!
//  eg. # c = a <--- b;      force evaluation of b when evaluating a; c gets value of a
(<---) infix 0 :: .a !.b -> .a;
(<---) value forceEvalOfValue
	=	use value forceEvalOfValue;

// abort with exit code and print msg to stderr
errorAbort :: {#Char} -> .a;
errorAbort msg
  	# stderr = stderr <<< msg <<< "\n";    // print msg to stderr
    = abort "" <--- stderr;  // abort with exit code and force eval of stderr


/*   old implementation dependent on Debug library!

errorAbort :: {#Char} -> .a;
errorAbort msg
  	# result ="";
  	# stderr = stderr <<< msg <<< "\n";    // print msg to stderr
  	# result = use result stderr;  // force evaluation of stderr
    = abort result;  // abort with exit code



import StdDebug;

errorAbort :: {#Char} -> {#Char};
errorAbort msg
  	| trace_tn msg    // print msg to stderr
         = abort "";  // abort with exit code
*/
