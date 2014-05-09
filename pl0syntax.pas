{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc,kvm,cw,variants;

type TVar = variant; TVars = array of TVar;
function L(vars : array of TVar) : TVars; inline;
  begin result := g<TVar>.fromOpenArray(vars);
  end;



var v : TVar;
begin
  clrscr;
  for v in L([
    '|wPL/0 syntax',
    '|Kfrom Algorithms and Data Structures by Niklaus Wirth.',
 
    '|R@|y program',
    '|r:|m block |B.',
    '|r;',
  
    '|R@|y block',
    '|r: (|B const |r( |mident |B= |mnumber |r/ |B, |r)+ |B; |r)?',
    '|r  (|B var |r( |mident |r/ |B, |r)+ |B; |r)?',
    '|r  (|B procedure |mident |B; |mblock |B; |r)*',
    '|r  |mstatement',
    '|r;',

    '|R@|y statement',
    '|r:|m ident |B:= |mexpression',
    '|r|||B call |mident',
    '|r|||B begin |mstatement |r( |B; |mstatement |r)* |Bend',
    '|r|||B if |mcondition |Bthen |mstatement',
    '|r|||B while |mcondition |Bdo |mstatement',
    '|r|||K (empty statement)',
    '|r;',

    '|R@|y condition',
    '|r|||B odd |mexpression',
    '|r|||m expression '
        + '|r( |B= |r|||B < |r|||B ≠ |r|||B > |r|||B ≤ |r|||B ≥ |r)',
    '|m expression',
    '|r;',

    '|R@|y expression',
    '|r|||r ( |B+ |r|||B - |r) |mterm |r(( |B+ |r|||B - |r) |mterm|r )*',
    '|r;',

    '|R@|y term',
    '|r||| mfactor |r((|B × |r|||B ÷ |r) |mfactor|r )*',
    '|r;',
  
    '|R@|y factor',
    '|r|||m ident',
    '|r|||m number',
    '|r|||B (|m expression |B)',
    '|r;',
    '|w'
  ]) do cwriteln(v)
end.
