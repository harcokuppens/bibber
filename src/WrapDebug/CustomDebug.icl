implementation module CustomDebug;

import Debug;
import StdMisc;
import StdFunc;

ctrace_n :: !.a .b -> .b;
ctrace_n debugValue value
	=	debugBefore debugValue show value;

ctrace_tn :: !.a -> Bool;  // write  value to stderr,  result is True
ctrace_tn value
	 #! value = debugValue show value;   // print value to stderr
     // #! is a strict operator that forces evaluation of the value on the right side causint its side effects to be executed!
	 =  const  True value;  // return True ( first arg of const is strict but second arg of const is lazy, but value evaluated on previous line)
     // note:  The function const is a standard function that takes two arguments and returns the first argument, ignoring the second.
	 //        by using const we use the value making sure the compiler does not optimize code using value away!

// these examples use double arrow syntax (->>, <<- and <<->>)
(<<-) infixl 0 :: .a !.b -> .a;
(<<-) value debugValue
	=	debugBefore debugValue show value;

(->>) infixl 0 :: !.a .b -> .a;
(->>) value debugValue
	=	debugAfter debugValue show value;

<<->> :: !.a -> .a;
<<->> value
	=	debugValue show value;

// show function with default debug options ( no limits and as print terminator \n)
show =	debugShowWithOptions [];

// // show function with debug options (limit length of output and depth of nested structures)
// show
// 	=	debugShowWithOptions
// 			[DebugMaxChars 79, DebugMaxDepth 5, DebugMaxBreadth 20];


print_graph :: !.a -> Bool;
print_graph a = code {
	.d 1 0
	jsr _print_graph
	.o 0 0
	pushB TRUE
};

(->>-) infixl 0 :: !.a .b -> .a;
(->>-) value msg 
		| print_graph msg  // prints msg (on rhs of operator) to  stdout
			=  value;       // returns value (on lhs of operator, as in situation wher operator and rhs were not there)
		| otherwise      // never reached
			= undef;      // note:  The function undef represents an undefined value, 
						//        evaluating this undefined value yields a runtime error. 
