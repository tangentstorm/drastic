{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc,kvm,cw,variants,sysutils;

{-- constructor for array of variants -------------------------}

type
  TVar = variant;
  TVars = array of TVar;

function L(vars : array of TVar) : TVars; inline;
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


{-- data constructors -----------------------------------------}

type TKind = ( kNB, kNL, kSeq, kRule );

function nb( comment : TStr ) : TVar;
  begin result := L([kNB, comment])
  end;

const nl = kNL;

function seq(parts : array of TVar) : TVar;
  begin result := L([kSeq, L(parts)])
  end;


function rule(iden : TStr; alts : array of TVar) : TVar;
  begin result := L([kRule, iden, L(alts)])
  end;


{-- recursive show for variants -------------------------------}

procedure VarShow(v : TVar);
  var item : TVar;
  begin
    if VarIsStr(v) then cwrite(v)
    else if VarIsArray(v) then
      if VarIsStr(v[0]) then
        for item in TVars(v) do VarShow(item)
      else if VarIsArray(v[0]) then varshow(v[0])
      else try case TKind(v[0]) of
        kNB  : cwrite(['|K', TStr(v[1])]);
        kSeq : if length(TVars(v[1])) > 1 then begin
                 varshow(TVars(v[1])[0]);
                 cwrite('|>');
                 for item in drop(1, TVars(v[1])) do varshow(item);
                 cwrite('|<');
               end;
        kRule : VarShow(L(['|R@|y ' + v[1] + '|_|R:', v[2], nl, nl ]));
        otherwise
      end except on e:EVariantError do for item in tvars(v) do varshow(v) end
    else if TKind(v) = kNL then cwrite('|_') // newline but with indentation
  end;

{-- main : shows pretty grammar for PL/0 in color --------------}

begin
  clrscr;
  VarShow(L([
    '|wPL/0 syntax', nl,
    nb('from Algorithms and Data Structures by Niklaus Wirth.'), nl,

    rule('program', [
    '|m block |B.' ]),

    rule('block', [ seq([
    '|r (|B const |r( |mident |B= |mnumber |r/ |B, |r)+ |B; |r)?', nl,
    '|r(|B var |r( |mident |r/ |B, |r)+ |B; |r)?',  nl,
    '|r(|B procedure |mident |B; |mblock |B; |r)*',  nl,
    '|r|mstatement' ]) ]),

    rule('statement', [
    '|m ident |B:= |mexpression', nl,
    '|r|||B call |mident', nl,
    '|r|||B begin |mstatement |r( |B; |mstatement |r)* |Bend', nl,
    '|r|||B if |mcondition |Bthen |mstatement', nl,
    '|r|||B while |mcondition |Bdo |mstatement', nl,
    '|r|| ', nb('empty statement') ]),

    rule('condition', [
    '|B odd |mexpression', nl,
    '|r|||m expression '
        + '|r( |B= |r|||B < |r|||B ≠ |r|||B > |r|||B ≤ |r|||B ≥ |r)'
        + '|m expression' ]),

    rule('expression', [
    '|r ( |B+ |r|||B - |r) |mterm |r(( |B+ |r|||B - |r) |mterm|r )*' ]),

    rule('term', [
    '|m factor |r((|B × |r|||B ÷ |r) |mfactor|r )*' ]),

    rule('factor', [
    '|m ident', nl,
    '|r|||m number', nl,
    '|r|||B (|m expression |B)' ]),

    '|w'
  ]))
end.
