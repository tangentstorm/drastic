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
  begin result := L([kNB, comment])
  end;

const nl = kNL;

function seq(parts : array of TVar) : TVar;
  begin result := L([kSeq, L(parts)])
  end;

function lit(s : TStr) : TVar; begin result := L([kLIT, s]) end;
function sub(s : TStr) : TVar; begin result := L([kSub, s]) end;

function opt(vars : array of TVar):TVar; begin result:=L([kOpt, L(vars)]) end;
function rep(vars : array of TVar):TVar; begin result:=L([kRep, L(vars)]) end;
function orp(vars : array of TVar):TVar; begin result:=L([kOrp, L(vars)]) end;

function rule(iden : TStr; alts : array of TVar) : TVar;
  begin result := L([kRule, iden, L(alts)])
  end;

function hbox(vars : array of TVar) : TVar;
  begin result := L([kHBox, L(vars)])
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
        kNB   : cwrite(['|K', TStr(v[1])]);
        kHBox : for item in drop(1, TVars(v)) do varshow(item);
        kLit : cwrite(['|M', TStr(v[1])]);
        kSub : cwrite(['|C', TStr(v[1])]);
        kOpt : varshow(implode(' ', L(['|r(', drop(1, TVars(v)), '|r)?' ])));
        kRep : varshow(implode(' ', L(['|r(', drop(1, TVars(v)), '|r)+' ])));
        kOrp : varshow(implode(' ', L(['|r(', drop(1, TVars(v)), '|r)*' ])));
        kSeq : if length(TVars(v[1])) > 0 then begin
                 varshow(TVars(v[1])[0]);
                 cwrite('|>');
                 for item in drop(1, TVars(v[1])) do varshow(item);
                 cwrite('|<');
               end;
        kRule : VarShow(L(['|R@|y ', v[1], '|_|R:',
                           implode('|_|r||', v[2]), nl, nl ]));
        otherwise for item in tvars(v) do varshow(v)
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
      seq([ ' ', sub('block'), ' ', lit('.') ]) ]),

    rule('block', [ seq([
      ' ',
      opt(['|Bconst |r( |mident |B= |mnumber |r/ |B, |r)+ |B;']), nl,
      opt(['|Bvar |r( |mident |r/ |B, |r)+ |B;']), nl,
      orp(['|Bprocedure |mident |B; |mblock |B;']), nl,
      sub('statement') ]) ]),

    rule('statement', [
      seq(['|m ident |B:= |mexpression']),
      seq(['|B call', ' ', '|mident' ]),
      seq(['|B begin |mstatement',
	   ' ',
	   orp(['|B; |mstatement']),
	   ' ',
	   '|Bend']),
      seq(['|B if |mcondition |Bthen |mstatement' ]),
      seq(['|B while |mcondition |Bdo |mstatement' ]),
      nb(' empty statement') ]),

    rule('condition', [
      seq(['|B odd |mexpression']),
      seq(['|m expression '
        + '|r( |B= |r|||B < |r|||B ≠ |r|||B > |r|||B ≤ |r|||B ≥ |r)'
        + '|m expression' ]) ]),

    rule('expression', [
      seq(['|r ( |B+ |r|||B - |r) |mterm',
	   ' ',
	   orp(['( |B+ |r|||B - |r) |mterm']) ]) ]),

    rule('term', [
      seq(['|m factor',
	   ' ',
	   orp(['(|B × |r|||B ÷ |r) |mfactor' ]) ]) ]),

    rule('factor', [
      seq([ ' ', sub('ident') ]),
      seq([ ' ', sub('number') ]),
      seq([ ' ', lit('('), sub('expression'), lit(')') ]) ]),

    '|w'
  ]))
end.
