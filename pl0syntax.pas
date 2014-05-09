{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc,kvm,cw,variants;

{-- constructor for array of variants -------------------------}

type
  TVar = variant;
  TVars = array of TVar;

function L(vars : array of TVar) : TVars; inline;
  begin result := g<TVar>.fromOpenArray(vars);
  end;


{-- data constructors -----------------------------------------}

type TKind = ( kNB, kNL, kRule );

function nb( comment : TStr ) : TVar;
  begin result := L([kNB, comment])
  end;

const nl = kNL;

function rule(iden : TStr; alts : array of TVar) : TVar;
  begin result := L([kRule, iden, L(alts)])
  end;


{-- recursive show for variants -------------------------------}

procedure VarShow(v : TVar);
  var item : TVar;
  begin
    if VarIsStr(v) then cwrite(v)
    else if VarIsArray(v) then
      if VarIsStr(v[0])
        then for item in TVars(v) do VarShow(item)
        else case TKind(v[0]) of
	  kNB : cwrite(['|K', TStr(v[1])]);
	  kRule : VarShow(L(['|R@|y ' + v[1], nl, v[2], nl, nl ]));
          otherwise
	end
    else if TKind(v) = kNL then newline
  end;

{-- main : shows pretty grammar for PL/0 in color --------------}

var v : TVar;
begin
  clrscr;
  VarShow(L([
    '|wPL/0 syntax', nl,
    nb('from Algorithms and Data Structures by Niklaus Wirth.'),
    nl,

    rule('program', [
    '|R:|m block |B.' ]),

    rule('block', [
    '|R:|r (|B const |r( |mident |B= |mnumber |r/ |B, |r)+ |B; |r)?', nl,
    '|r  (|B var |r( |mident |r/ |B, |r)+ |B; |r)?',  nl,
    '|r  (|B procedure |mident |B; |mblock |B; |r)*',  nl,
    '|r  |mstatement' ]),

    rule('statement', [
    '|R:|m ident |B:= |mexpression', nl,
    '|r|||B call |mident', nl,
    '|r|||B begin |mstatement |r( |B; |mstatement |r)* |Bend', nl,
    '|r|||B if |mcondition |Bthen |mstatement', nl,
    '|r|||B while |mcondition |Bdo |mstatement', nl,
    '|r|| ', nb('empty statement') ]),

    rule('condition', [
    '|R:|B odd |mexpression', nl,
    '|r|||m expression '
        + '|r( |B= |r|||B < |r|||B ≠ |r|||B > |r|||B ≤ |r|||B ≥ |r)'
        + '|m expression' ]),

    rule('expression', [
    '|R:|r ( |B+ |r|||B - |r) |mterm |r(( |B+ |r|||B - |r) |mterm|r )*' ]),

    rule('term', [
    '|R:|m factor |r((|B × |r|||B ÷ |r) |mfactor|r )*' ]),

    rule('factor', [
    '|R:|m ident', nl,
    '|r|||m number', nl,
    '|r|||B (|m expression |B)' ]),

    '|w'
  ]))
end.
