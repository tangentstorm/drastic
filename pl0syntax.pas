{ drastic: direct representation of abstract syntax trees }
{$mode delphiunicode}{$i xpc.inc}
program drastic;
uses xpc,kvm,cw;
begin
  clrscr;

  cwriteln('|wPL/0 syntax');
  cwriteln('|Kfrom Algorithms and Data Structures by Niklaus Wirth.');
 
  cwriteln('|R@|y program');
  cwriteln('|r:|m block |B.');
  cwriteln('|r;');
  
  cwriteln('|R@|y block');
  cwriteln('|r: (|B const |r( |mident |B= |mnumber |r/ |B, |r)+ |B; |r)?');
  cwriteln('|r  (|B var |r( |mident |r/ |B, |r)+ |B; |r)?');
  cwriteln('|r  (|B procedure |mident |B; |mblock |B; |r)*');
  cwriteln('|r  |mstatement');
  cwriteln('|r;');

  cwriteln('|R@|y statement');
  cwriteln('|r:|m ident |B:= |mexpression');
  cwriteln('|r|||B call |mident');
  cwriteln('|r|||B begin |mstatement |r( |B; |mstatement |r)* |Bend');
  cwriteln('|r|||B if |mcondition |Bthen |mstatement');
  cwriteln('|r|||B while |mcondition |Bdo |mstatement');
  cwriteln('|r|||K (empty statement)');
  cwriteln('|r;');

  cwriteln('|R@|y condition');
  cwriteln('|r|||B odd |mexpression');
  cwrite('|r|||m expression ');
  cwrite('|r( |B= |r|||B < |r|||B ≠ |r|||B > |r|||B ≤ |r|||B ≥ |r)');
  cwriteln('|m expression');
  cwriteln('|r;');

  cwriteln('|R@|y expression');
  cwriteln('|r|||r ( |B+ |r|||B - |r) |mterm |r(( |B+ |r|||B - |r) |mterm|r )*');
  cwriteln('|r;');

  cwriteln('|R@|y term');
  cwriteln('|r||| mfactor |r((|B × |r|||B ÷ |r) |mfactor|r )*');
  cwriteln('|r;');
  
  cwriteln('|R@|y factor');
  cwriteln('|r|||m ident');
  cwriteln('|r|||m number');
  cwriteln('|r|||B (|m expression |B)');
  cwriteln('|r;');
  cwriteln('|w');
end.
