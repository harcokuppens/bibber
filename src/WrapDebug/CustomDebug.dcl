definition module CustomDebug;

(<<-) infixl 0 :: .a !.b -> .a;

(->>) infixl 0 :: !.a .b -> .a;


<<->> :: !.a -> .a;

ctrace_n :: !.a .b -> .b;
ctrace_tn :: !.a -> Bool;  // write  value to stderr,  result is True


print_graph :: !.a -> Bool;

(->>-) infixl 0 :: !.a .b -> .a;