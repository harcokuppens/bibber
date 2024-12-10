implementation module CustomDebug;

import Debug;

// these examples use double arrow syntax (->>, <<- and <<->>)
(<<-) infix 0 :: .a !.b -> .a;
(<<-) value debugValue
	=	debugBefore debugValue show value;

(->>) infix 0 :: !.a .b -> .a;
(->>) value debugValue
	=	debugAfter debugValue show value;

<<->> :: !.a -> .a;
<<->> value
	=	debugValue show value;

// show function with debug options
show
	=	debugShowWithOptions
			[DebugMaxChars 79, DebugMaxDepth 5, DebugMaxBreadth 20];
