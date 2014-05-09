{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc, kvm, cw, variants, uvar, sysutils;

// type uvar.TVar = variant, TVars = array of variant;
// function uvar.A( {open} array of TVar) : TVars { array constructor }


{-- data constructors -----------------------------------------}

type
  TKind = (
    kNB,                  { nota bene (comment) }
    kNL, kHBox, kVBox,    { newline and horizontal/vertical formatting }
    kLit, kNul, kSeq,     { empty pattern, literals, and sequences }
    kAlt, kOpt,           { alternatives and optional }
    kRep, kOrp,           { repeat and optional repeat }
    kDef, kSub            { define and use named patterns }
  );

const nl = kNL;

function nb (s : TStr) : TVar; begin result := A([kNB,  s]) end;
function lit(s : TStr) : TVar; begin result := A([kLIT, s]) end;
function sub(s : TStr) : TVar; begin result := A([kSub, s]) end;

{$define combinator := (vars : array of TVar):TVar; begin result:= }
function seq combinator A([kSeq, A(vars)]) end;
function alt combinator A([kAlt, A(vars)]) end;
function opt combinator A([kOpt, A(vars)]) end;
function rep combinator A([kRep, A(vars)]) end;
function orp combinator A([kOrp, A(vars)]) end;
function hbox combinator A([kHBox, A(vars)]) end;

function def(iden : TStr; alts : array of TVar) : TVar;
  begin result := A([kDef, iden, A(alts)])
  end;



{-- recursive show for variants -------------------------------}

procedure VarShow(v : TVar);
  var item : TVar;
  begin
    if VarIsStr(v) then cwrite(v)
    else if VarIsArray(v) then
      if VarIsStr(v[0]) or VarIsArray(v[0]) then
	//  TODO: ignore spaces if last item was kNB (to fix seq)
        for item in TVars(v) do VarShow(item)
      else try case TKind(v[0]) of
        kNB   : cwrite([ '|K', TStr(v[1])]);
        kHBox : varshow(A([ implode(nl, v[1]) ]));
        kLit : cwrite([ '|B', TStr( v[1]) ]);
        kSub : cwrite([ '|m', TStr( v[1]) ]);
        kOpt : varshow(A([ '|r( ', implode(' ', v[1]), ' |r)?' ]));
        kRep : varshow(A([ '|r( ', implode(' ', v[1]), ' |r)+' ]));
        kOrp : varshow(A([ '|r( ', implode(' ', v[1]), ' |r)*' ]));
        kAlt : varshow(A([ '|r( ', implode(' |r|| ', v[1]), ' |r)' ]));
        kSeq : varshow(A([ '|>', implode(' ', v[1]), '|<' ]));
        kDef : VarShow(A(['|R@|y ', v[1], '|_|R: ',
                           implode('|_|r|| ' , v[2]), nl ]));
        otherwise
          cwrite('|!r|y'); write('<', TKind(v[0]), '>'); cwrite('|w|!k');
      end except on e:EVariantError do for item in tvars(v) do varshow(v) end
    else if TKind(v) = kNL then cwrite('|_') // newline but with indentation
  end;


{-- main : shows pretty grammar for PL/0 in color --------------}

begin
  clrscr;
  VarShow(hbox([
    '|wPL/0 syntax',
    nb('from Algorithms and Data Structures by Niklaus Wirth.'),

    def('program', [
      seq([ sub('block'), lit('.') ]) ]),

    def('block', [ seq([
      hbox([
        opt([ lit('const'),
            rep([ sub('ident'), lit('='), sub('number'), '|r/', lit(',') ]),
            lit(';') ]),
        opt([ lit('var'), rep([ sub('ident'), '|r/', lit(',') ]), lit(';') ]),
        orp([ lit('procedure'), sub('ident'), lit(';'), sub('block'), lit(';') ]),
        sub('statement') ]) ]) ]),

    def('statement', [
      seq([ sub('ident'), lit(':='), sub('expression') ]),
      seq([ lit('call'), sub('ident') ]),
      seq([ lit('begin'),
	      sub('statement'),
	      orp([ lit(';'), sub('statement')]),
            lit('end') ]),
      seq([ lit('if'), sub('condition'), lit('then'), sub('statement') ]),
      seq([ lit('while'), sub('condition'), lit('do'), sub('statement') ]),
      nb('empty statement') ]),

    def( 'condition', [
      seq([ lit('odd'), sub('expression') ]),
      seq([ sub('expression'),
            alt([ lit('='), lit('≠'),
                  lit('<'), lit('>'),
                  lit('≤'), lit('≥') ]),
            sub('expression') ]) ]),

    def('expression', [
      seq([ alt([ lit('+'), lit('-') ]),
            sub('term'),
            orp([ alt([ lit('+'), lit('-') ]),
                  sub('term') ]) ]) ]),

    def('term', [
      seq([ sub('factor'),
            orp([ alt([ lit('×'), lit('÷') ]),
                  sub('factor') ]) ]) ]),

    def('factor', [
      sub('ident'),
      sub('number'),
      seq([ lit('('), sub('expression'), lit(')') ]) ]),

    '|w' ]))
end.
