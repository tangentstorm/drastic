NB. ------------------------------------------------------------
NB. relation class
NB. ------------------------------------------------------------
coclass 'Rel'
typeSyms =: s:;: 'int bit nid sym str chr box'

sym2lit =: 4 s: ]

create =: monad : 0
  NB. example:  'sub:int rel:int obj:int' conew 'Rel'
  y =. (' '"_)^:(':'=])"0 y  NB. discard ':' chars
  'keyNames keyTypes' =. |: s: _2 ]\ ;: y
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

NB. -- application ---------------------------------------------
cocurrent 'base'
Rel =: conew & 'Rel'

NB. -- the syntax tree -----------------------------------------
tree =. Rel 'parent:int ord:int child:nid'
node =. Rel 'node:int nont:int altkey:int'
alts =. Rel 'nont:int altkey:int rule:int'
forw =. Rel 'from:int to:int'
rule =. Rel 'asys:int ssys:int dict:int'
ssys =. Rel ''
asys =. Rel ''
dict =. Rel 'nont:int -> key:int'
