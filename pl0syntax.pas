{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc,kvm,cw,variants,sysutils;

{-- constructor for array of variants -------------------------}

type
  TVar = variant;
  TVars = array of TVar;

function A(vars : array of TVar) : TVars; inline;
  begin result := g<TVar>.fromOpenArray(vars);
  end;

{-- helpers ----------------------------------------------------}

function drop(n : word; vars: tvars) : TVars; inline;
  var i : integer;
  begin
    if length(vars) > n then begin
      setlength(result, length(vars)-n);
      for i := n to length(vars) -1 do result[i-n] := vars[i];;
    end
   else setlength(result,0)
  end;

function implode(glue : tvar; vars: tvars) : TVars; inline;
  var i : integer;
  begin
    if length(vars) <= 1 then result := vars
    else begin
      setlength(result, length(vars)*2-1);
      for i := 0 to length(vars)-2 do begin
        result[i*2]:=vars[i]; result[i*2+1]:=glue
      end;
      result[2*(length(vars)-1)] := vars[length(vars)-1]
    end
  end;


{-- data constructors -----------------------------------------}

type TKind = ( kNB, kNL, kSeq, kRule, kLit, kSub, kOpt, kRep, kOrp, kHBox );

function nb( comment : TStr ) : TVar;
  begin result := A([kNB, comment])
  end;

const nl = kNL;

function seq(parts : array of TVar) : TVar;
  begin result := A([kSeq, A(parts)])
  end;

function lit(s : TStr) : TVar; begin result := A([kLIT, s]) end;
function sub(s : TStr) : TVar; begin result := A([kSub, s]) end;

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
        kHBox : for item in drop(1, TVars(v)) do varshow(item);
        kLit : cwrite([ '|B', TStr(v[1]) ]);
        kSub : cwrite([ '|m', TStr(v[1]) ]);
        kOpt : varshow(implode(' ', A([ '|r(', drop(1, TVars(v)), '|r)?' ])));
        kRep : varshow(implode(' ', A([ '|r(', drop(1, TVars(v)), '|r)+' ])));
        kOrp : varshow(implode(' ', A([ '|r(', drop(1, TVars(v)), '|r)*' ])));
        kSeq : if length(TVars(v[1])) > 0 then begin
                 varshow(TVars(v[1])[0]);
                 cwrite('|>');
                 for item in drop(1, TVars(v[1])) do varshow(item);
                 cwrite('|<');
               end;
        kRule : VarShow(A(['|R@|y ', v[1], '|_|R:',
                           implode('|_|r||', v[2]), nl, nl ]));
        otherwise for item in tvars(v) do varshow(v)
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
            '|r(',
                  ' ',
                  lit('='),
                  ' ',
                  '|r||',
                  ' ',
                  lit('<'),
                  ' ',
                  '|r||',
                  ' ',
                  lit('≠'),
                  ' ',
                  '|r||',
                  ' ',
                  lit('>'),
                  ' ',
                  '|r||',
                  ' ',
                  lit('≤'),
                  ' ',
                  '|r||',
                  ' ',
                  lit('≥'),
                  ' ', '|r)',
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
