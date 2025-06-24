definition module CustomEvalAbort;

//errorAbort :: {#Char} -> {#Char};
errorAbort :: {#Char} -> .a;

// force evaluation of x using helper which is evaluated later
use :: .a !.b -> .a;

// operator to force evaluation of b using helper a: we force eval of b when a is evaluated.
//  eg. # c = a <--- b;      force evaluation of b when evaluating a; c gets value of a
(<---) infix 0 :: .a !.b -> .a;