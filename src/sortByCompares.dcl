definition module sortByCompares;


import StdEnv;

/*
cmpNone :: .a .b -> (.Bool,.Bool)

combineCompare :: u:(a -> .(b -> (v:Bool,.c))) w:(a -> .(b -> x:(y:Bool,.c))) -> z:(a -> u0:(b -> v0:(w0:Bool,.c))), [z <= u,z <= w,u0 <= z,x <= v0,y v <= w0]

mergeCompares :: u:([v:(a -> .(b -> (w:Bool,x:Bool)))] -> y:(a -> z:(b -> (u0:Bool,v0:Bool)))), [y <= v,z u <= y,w <= u0,x <= v0]
compare2lt :: u:(v:a -> .(.b -> (.c,.d))) -> w:(v:a -> x:(.b -> .d)), [w <= u,x <= v,x <= w]
sortByCompares :: u:(.[(a -> .(a -> (.Bool,.Bool)))] -> v:(w:[a] -> x:[a])), [v <= u,w <= x]
*/

cmpNone :: a b -> (Bool,Bool);

compare :: a a -> (Bool,Bool) | < a & == a;

compareInv :: (Bool,Bool) -> (Bool,Bool);

cmpInv :: u:(v:a -> .(.b -> (.Bool,.Bool))) -> w:(v:a -> x:(.b -> (Bool,Bool))), [w <= u,x <= v,x <= w];

combineCompare :: u:(a -> .(b -> (v:Bool,.c))) w:(a -> .(b -> x:(y:Bool,.c))) -> z:(a -> u0:(b -> v0:(w0:Bool,.c))), [z <= u,z <= w,u0 <= z,x <= v0,y v <= w0];

mergeCompares :: u:([v:(a -> .(b -> (.Bool,.Bool)))] -> w:(a -> x:(b -> (Bool,Bool)))), [w <= v,x u <= w];

compare2lt :: u:(v:a -> .(.b -> (.c,.d))) -> w:(v:a -> x:(.b -> .d)), [w <= u,x <= v,x <= w];

sortByCompares :: u:(.[(a -> .(a -> (.Bool,.Bool)))] -> v:(w:[a] -> x:[a])), [v <= u,w <= x];
