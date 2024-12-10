implementation module sortByCompares;

import StdEnv;

/* example compare function
compare :: a a -> .(Bool,Bool) | < a & == a
compare a b = (a==b,a<b)
*/

/*
cmpNone :: .a .b -> (.Bool,.Bool)
cmpNone a b = (True,False)

combineCompare :: u:(a -> .(b -> (v:Bool,.c))) w:(a -> .(b -> x:(y:Bool,.c))) -> z:(a -> u0:(b -> v0:(w0:Bool,.c))), [z <= u,z <= w,u0 <= z,x <= v0,y v <= w0]
combineCompare cmpf1 cmpf2 = \a b -> let (e1,l1) = cmpf1 a b in if e1 (cmpf2 a b) (e1,l1)

mergeCompares :: u:([v:(a -> .(b -> (w:Bool,x:Bool)))] -> y:(a -> z:(b -> (u0:Bool,v0:Bool)))), [y <= v,z u <= y,w <= u0,x <= v0]
mergeCompares = foldr combineCompare cmpNone

compare2lt :: u:(v:a -> .(.b -> (.c,.d))) -> w:(v:a -> x:(.b -> .d)), [w <= u,x <= v,x <= w]
compare2lt cmp = (\a b -> (snd (cmp a b)) )

sortByCompares :: u:(.[(a -> .(a -> (.Bool,.Bool)))] -> v:(w:[a] -> x:[a])), [v <= u,w <= x]
sortByCompares = ( \a b -> sortBy  ( (compare2lt o mergeCompares) a )  b )
*/


cmpNone :: a b -> (Bool,Bool);
cmpNone a b = (True,False);

compare :: a a -> (Bool,Bool) | < a & == a;
compare a b = (a==b,a<b);

compareInv :: (Bool,Bool) -> (Bool,Bool);
compareInv (a,b)
   = (a,not b);

cmpInv :: u:(v:a -> .(.b -> (.Bool,.Bool))) -> w:(v:a -> x:(.b -> (Bool,Bool))), [w <= u,x <= v,x <= w];
cmpInv cmp = (\a b -> (compareInv (cmp a b)) );

combineCompare :: u:(a -> .(b -> (v:Bool,.c))) w:(a -> .(b -> x:(y:Bool,.c))) -> z:(a -> u0:(b -> v0:(w0:Bool,.c))), [z <= u,z <= w,u0 <= z,x <= v0,y v <= w0];
combineCompare cmpf1 cmpf2 =
  ( \a b -> let  { (e1,l1) = cmpf1 a b } in  if e1 (cmpf2 a b) (e1,l1)  );
 // ( \a b -> let { (e1,l1) = cmpf1 a b  } in { if e1 (cmpf2 a b) (e1,l1) } );

mergeCompares :: u:([v:(a -> .(b -> (.Bool,.Bool)))] -> w:(a -> x:(b -> (Bool,Bool)))), [w <= v,x u <= w];
mergeCompares = foldr combineCompare cmpNone;

compare2lt :: u:(v:a -> .(.b -> (.c,.d))) -> w:(v:a -> x:(.b -> .d)), [w <= u,x <= v,x <= w];
compare2lt cmp = (\a b -> (snd (cmp a b)) );

sortByCompares :: u:(.[(a -> .(a -> (.Bool,.Bool)))] -> v:(w:[a] -> x:[a])), [v <= u,w <= x];
sortByCompares = ( \a b -> sortBy  ( (compare2lt o mergeCompares) a )  b );
