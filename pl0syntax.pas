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
        for item in TVars(v) do VarShow(item)
      else try case TKind(v[0]) of
        kNB   : cwrite([ '|K', TStr(v[1])]);
        kHBox : for item in behead( TVars( v )) do varshow(item);
        kLit : cwrite([ '|B', TStr( v[1]) ]);
        kSub : cwrite([ '|m', TStr( v[1]) ]);
        kOpt : varshow(implode(' ', A([ '|r(', behead( TVars(v)), '|r)?' ])));
        kRep : varshow(implode(' ', A([ '|r(', behead( TVars(v)), '|r)+' ])));
        kOrp : varshow(implode(' ', A([ '|r(', behead( TVars(v)), '|r)*' ])));
        kAlt : varshow(implode(' ', A([ '|r(', implode(' |r|| ', v[1]),
				        ' |r)' ])));
        kSeq : if length(TVars(v[1])) > 0 then begin
                 varshow(TVars(v[1])[0]);
                 cwrite('|>');
                 for item in behead(TVars(v[1])) do varshow(item);
                 cwrite('|<');
               end;
        kDef : VarShow(A(['|R@|y ', v[1], '|_|R:',
                           implode('|_|r||', v[2]), nl, nl ]));
        otherwise
          cwrite('|!r|y'); write('<', TKind(v[0]), '>'); cwrite('|w|!k');
      end except on e:EVariantError do for item in tvars(v) do varshow(v) end
    else if TKind(v) = kNL then cwrite('|_') // newline but with indentation
  end;


{-- main : shows pretty grammar for PL/0 in color --------------}

begin
  clrscr;
  VarShow(A([
    '|wPL/0 syntax', nl,
    nb('from Algorithms and Data Structures by Niklaus Wirth.'), nl,

    def('program', [
      seq([ ' ', sub('block'), ' ', lit('.') ]) ]),

    def('block', [ seq([
      ' ',
      opt([ lit('const'),
            ' ',
            rep([ sub('ident'),
                  ' ',
                  lit('='),
                  ' ',
                  sub('number'),
                  ' ',
                  '|r/',
                  ' ',
                  lit(',') ]),
            ' ',
            lit(';') ]),
      nl,
      opt([ lit('var'),
            ' ',
            rep([ sub('ident'),
                  ' ',
                  '|r/',
                  ' ',
                  lit(',') ]),
            ' ',
            lit(';') ]),
      nl,
      orp([ lit('procedure'),
            ' ',
            sub('ident'),
            ' ',
            lit(';'),
            ' ',
            sub('block'),
            ' ',
            lit(';') ]),
      nl,
      sub('statement') ]) ]),

    def('statement', [
      seq([ ' ',
            sub('ident'),
            ' ',
            lit(':='),
            ' ',
            sub('expression') ]),
      seq([ ' ',
            lit('call'),
            ' ',
            sub('ident') ]),
      seq([ ' ',
            lit('begin'),
            ' ',
            sub('statement'),
            ' ',
            orp([ lit(';'),
                  ' ',
                  sub('statement')]),
            ' ',
            lit('end') ]),
      seq([ ' ',
            lit('if'),
            ' ',
            sub('condition'),
            ' ',
            lit('then'),
            ' ',
            sub('statement') ]),
      seq([ ' ',
            lit('while'),
            ' ',
            sub('condition'),
            ' ',
            lit('do'),
            ' ',
            sub('statement') ]),
      nb(' empty statement') ]),

    def( 'condition', [
      seq([ ' ',
            lit('odd'),
            ' ',
            sub('expression') ]),
      seq([ ' ',
            sub('expression'),
            ' ',
         // grp([        //  TODO
            alt([ lit('='),
                  lit('<'),
                  lit('≠'),
                  lit('>'),
                  lit('≤'),
                  lit('≥') ]),
            ' ',
            sub('expression') ]) ]),

    def('expression', [
      seq([ '|r (',
                 ' ',
                 lit('+'),
                 ' ',
                 '|r||',
                 lit('-'),
                 ' ', '|r)',
           ' ',
           sub('term'),
           ' ',
           orp([ '|r(',
                     ' ',
                     lit('+'),
                     ' ',
                     '|r||',
                     ' ',
                     lit('-'),
                     ' ', '|r)',
                 ' ',
                 sub('term') ]) ]) ]),

    def('term', [
      seq([ ' ',
            sub('factor'),
            ' ',
            orp([ '(',
                      ' ',
                      lit('×'),
                      ' ',
                      '|r||',
                      ' ',
                      lit('÷'),
                      ' ', '|r)',
                 ' ',
                 sub('factor') ]) ]) ]),

    def('factor', [
      seq([ ' ', sub('ident') ]),
      seq([ ' ', sub('number') ]),
      seq([ ' ', lit('('), ' ', sub('expression'), ' ', lit(')') ]) ]),

    '|w'
  ]))
end.
