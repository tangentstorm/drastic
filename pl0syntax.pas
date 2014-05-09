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

type TKind = ( kRule );

function rule(iden : TStr; alts : array of TVar) : TVar;
  begin result := L([kRule, iden, L(alts)])
  end;


{-- show variant strings and arrays ---------------------------}

procedure VarShow(v : TVar);
  var item : TVar;
  begin
    if VarIsStr(v) then cwriteln(v)
    else if VarIsArray(v) then
      case TKind(v[0]) of
	kRule : begin
		  cwriteln('|R@|y ' + v[1]);
		  for item in TVars(v[2]) do cwriteln(item);
		  cwriteln('|r;');
		end
      end;
  end;



{-- main : shows pretty grammar for PL/0 in color --------------}

var v : TVar;
begin
  clrscr;
  for v in L([
    '|wPL/0 syntax',
    '|Kfrom Algorithms and Data Structures by Niklaus Wirth.',

    rule('program', [
    '|r:|m block |B.' ]),

    rule('block', [
    '|r: (|B const |r( |mident |B= |mnumber |r/ |B, |r)+ |B; |r)?',
    '|r  (|B var |r( |mident |r/ |B, |r)+ |B; |r)?',
    '|r  (|B procedure |mident |B; |mblock |B; |r)*',
    '|r  |mstatement' ]),

    rule('statement', [
    '|r:|m ident |B:= |mexpression',
    '|r|||B call |mident',
    '|r|||B begin |mstatement |r( |B; |mstatement |r)* |Bend',
    '|r|||B if |mcondition |Bthen |mstatement',
    '|r|||B while |mcondition |Bdo |mstatement',
    '|r|||K (empty statement)' ]),

    rule('condition', [
    '|r|||B odd |mexpression',
    '|r|||m expression '
        + '|r( |B= |r|||B < |r|||B ≠ |r|||B > |r|||B ≤ |r|||B ≥ |r)'
        + '|m expression' ]),

    rule('expression', [
    '|r|||r ( |B+ |r|||B - |r) |mterm |r(( |B+ |r|||B - |r) |mterm|r )*' ]),

    rule('term', [
    '|r||| mfactor |r((|B × |r|||B ÷ |r) |mfactor|r )*' ]),

    rule('factor', [
    '|r|||m ident',
    '|r|||m number',
    '|r|||B (|m expression |B)' ]),

    '|w'
  ]) do VarShow(v)
end.
