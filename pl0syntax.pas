{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc, kvm, cw, variants, uvar, sysutils;

{-- data constructors -----------------------------------------}

type TKind = ( kNB, kNL, kSeq, kAlt, kRule, kLit, kSub, kOpt, kRep, kOrp, kHBox );

const nl = kNL;

function nb (s : TStr) : TVar; begin result := A([kNB,  s]) end;
function lit(s : TStr) : TVar; begin result := A([kLIT, s]) end;
function sub(s : TStr) : TVar; begin result := A([kSub, s]) end;

function seq(vars : array of TVar):TVar; begin result:=A([kSeq, A(vars)]) end;
function alt(vars : array of TVar):TVar; begin result:=A([kAlt, A(vars)]) end;
function opt(vars : array of TVar):TVar; begin result:=A([kOpt, A(vars)]) end;
function rep(vars : array of TVar):TVar; begin result:=A([kRep, A(vars)]) end;
function orp(vars : array of TVar):TVar; begin result:=A([kOrp, A(vars)]) end;

function rule(iden : TStr; alts : array of TVar) : TVar;
  begin result := A([kRule, iden, A(alts)])
  end;

function hbox(vars : array of TVar) : TVar;
  begin result := A([kHBox, A(vars)])
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
        kAlt : varshow(implode(' ', A([ '|r( ',
				        implode( ' |r|| ', behead( TVars( v ))),
				        ' |r)' ])));
        kSeq : if length(TVars(v[1])) > 0 then begin
                 varshow(TVars(v[1])[0]);
                 cwrite('|>');
                 for item in drop(1, TVars(v[1])) do varshow(item);
                 cwrite('|<');
               end;
        kRule : VarShow(A(['|R@|y ', v[1], '|_|R:',
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

    rule('program', [
      seq([ ' ', sub('block'), ' ', lit('.') ]) ]),

    rule('block', [ seq([
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

    rule('statement', [
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

    rule( 'condition', [
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

    rule('expression', [
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

    rule('term', [
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

    rule('factor', [
      seq([ ' ', sub('ident') ]),
      seq([ ' ', sub('number') ]),
      seq([ ' ', lit('('), ' ', sub('expression'), ' ', lit(')') ]) ]),

    '|w'
  ]))
end.
