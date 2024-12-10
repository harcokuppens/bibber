definition module CustomEvalAbort;

//errorAbort :: {#Char} -> {#Char};
errorAbort :: {#Char} -> .a;

// force evaluation of x using helper which is evaluated later
use :: .a !.b -> .a;

// operator to force evaluation of x using  helper which is evaluated now!
//  eg. # c = a <--- b;      force evaluation of b when evaluating a; c gets value of a
(<---) infix 0 :: .a !.b -> .a;