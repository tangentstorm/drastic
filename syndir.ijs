coinsert  'rel'    NB. make next section available in base locale.

NB. ============================================================
NB. -- relational calculus -------------------------------------
NB. ============================================================
cocurrent 'rel'

NB. helper for tests
is =: dyad : 0
  NB. 5!:5 = linear representation of an object
  if. -. x -: y do. echo (5!:5<'x'),' ~: ',(5!:5<'y') end. x -: y
)

NB. some test relations (rows separated by ';')
r1 =: > 0 1 ; 0 2 ; 1 3 ; 2 4
r2 =: > 0 1 11 ; 0 2 22 ; 1 3 33 ; 2 4 44
r3 =: > 0 1 11 111; 0 2 22 222; 1 3 33 333; 2 4 44 444

NB. ------------------------------------------------------------
NB.   R ar y : apply binary relation R to y
NB. x R ar y : same, but treat n-ary R as binary with split at x
NB. ------------------------------------------------------------
ar =: adverb : 0
    }."1 m #~ y ="1   {."1 m
:
  x }."1 m #~ y -:"1 x {."1 m
)
assert (,. 1 2 ) is r1 ar 0     NB. two-row result for key=0
assert (,. 3   ) is r1 ar 1     NB. one-row result for key=1
assert (0 1 $ _) is r1 ar 9     NB. no results for key=9

NB. dyadic case should let us specify the size of the key
assert (,.  11)    is 2 r2 ar 0 1
assert (,: 11 111) is 2 r3 ar 0 1
assert (,. 111)    is 3 r3 ar 0 1 11

NB. inverse of a binary relation (reverses the direction)
iv =: ( |."_1 ) : ( -@[ |."1 ] )
assert (     r1) is (> 0 1 ; 0 2 ; 1 3 ; 2 4)
assert (  iv r1) is (> 1 0 ; 2 0 ; 3 1 ; 4 2 )
assert (1 iv r1) is (> 1 0 ; 2 0 ; 3 1 ; 4 2 )

r2 =: > 0 1 11 ; 0 2 22 ; 1 3 33 ; 2 4 44
assert (     r2) is (> 0 1 11; 0 2 22; 1 3 33; 2 4 44)
assert (2 iv r2) is (> 1 11 0; 2 22 0; 3 33 1; 4 44 2)

NB. ------------------------------------------------------------
NB.   R ai y : apply inverse of binary relation R to y
NB. x R ai y : same, but treat n-ary R as binary with split at x
NB. ------------------------------------------------------------
ai =: adverb : 0
  ((iv m) ar)  :. (m ar) y
:
  x (((x iv m) ar) :. (m ar)) y
)


r4 =: > 0 1 11 ; 0 2 22 ; 1 2 22
assert (,. 1 11 ,: 2 22) is r4 ar 0    NB. nothing new here.
assert (        ,: 2 22) is r4 ar 1
NB. monadic case: ( a | b c )
assert (,.   0)  is 2 r4 ai 1 11       NB. but ac maps value to key


NB. dyadic case: ( a b | c ) (when x = 2)
assert (,.   0)  is 2 r4 ai 1 11       NB. but ac maps value to key
assert (,. 0 1)  is 2 r4 ai 2 22       NB. (or to multiple keys)


NB. ============================================================
NB. relation class
NB. ============================================================
coclass 'Rel'
coinsert 'relwords'
typeSyms =: s:;: 'int bit nid sym str chr box'

sym2lit =: 4 s: ]
findsplit =: [: -: @: I. (s:<'|') = ]
assert 0 = findsplit s: ;: 'a:int b:int c:int'
assert 1 = findsplit s: ;: 'a:int | b:int c:int'
assert 2 = findsplit s: ;: 'a:int b:int | c:int'

create =: monad : 0
  NB. example:  'sub:int rel:int obj:int' conew 'Rel'
  y =. (' '"_)^:(':'=])"0 y  NB. discard ':' chars
  split =: findsplit toks =. s: ;: y
  'keyNames keyTypes' =. |: _2 ]\ toks -. s:<'|'
  for_i. i. # keyNames do.
    n =. i { keyNames
    k =. i { keyTypes
    if. -. k e. typeSyms do.
      echo 'unknown type:', sym2lit k
      throw.
    elseif. -. '[[:alpha:]][_[:alnum:]]*' rxeq sym2lit n do.
      echo 'invalid name:', sym2lit n
      throw.
    elseif. 1 do.
      NB. TODO...
    end.
  end.
)

NB. (ap__R K) : apply relation R to key k
ap =: verb : 'split }."1 r #~ y = split {."1 m'


NB. makes a function total (defined for all domains)
tl =: :: ]

NB. ============================================================
NB. -- application ---------------------------------------------
NB. ============================================================
cocurrent 'base'
Rel =: conew & 'Rel'

NB. -- the syntax tree -----------------------------------------
tree =: Rel 'node:nid | ord:int child:nid'  NB. connections
udfn =: Rel 'node:nid | nont:int'           NB. undefined nodes
defn =: Rel 'node:nid | altk:int rule:int'  NB. defined nodes

forw =: Rel 'from:int | to:int'
rule =: Rel 'asys:int ssys:int dict:int'
NB. asys =. Rel '' (term | nont)^2 // sequences of non-terminals
NB. ssys =. Rel '' (node | node*int) -> (node|nont|nont*altk)
dict =: Rel 'nont:int | i:int'


NB. --- editor functions ---------------------------------------

lang_ind =: 0 : 0
  key:int  cmd:int
  up       cmd_prev
  dn       cmd_next
  n        cmd_succ
  h        cmd_pred
  rt       cmd_in
  lf       cmd_out
  g        cmd_get
  p        cmd_put
  d        cmd_del
  u        cmd_undel
)

lang_dep =: 0 : 0
  key:int  cmd:int
)

process =: lang_ind , lang_dep

N =: 0 NB. current node
move   =: verb : 'N =: u y'
parent =: verb : '{. iv ap__tree y'
rtsib  =: verb : '(0 1 + ])&.ai__tree y'

NB. positioning commands
cmd_out =: verb : 'move (parent tl) N'
cmd_in  =: verb : 'move ((T ap) tl) (,1:) N'
