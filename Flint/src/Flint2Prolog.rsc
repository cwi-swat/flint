module Flint2Prolog

import Flint2;
import String;
import List;

// only english for now.

str name2atom((Name)`[<Id+ xs>]`) = "\'<intercalate("_", [ "<x>" | x <- xs ])>\'"; 

str flint2prolog(start[Main] pt) 
  = "sum([], 0).
    'sum([X|Xs], N) :- sum(Xs, N0), N is N0 + X.\n\n" + flint2prolog(pt.top);

str flint2prolog((Main)`<Decl* decls>`) = intercalate("\n\n", [ flint2prolog(d) | d <- decls ]);

int formals2arity((Formals)`(<{Formal ","}* fs>)`) = ( 0 | it + 1 | _ <- fs );

list[str] formals2vars((Formals)`(<{Formal ","}* fs>)`) = [ formal2var(f) | f <- fs ];

str formal2var((Formal)`<Id x>`) = capitalize("<x>");

str atom2prolog((Atom)`<String s>`) = "\'<"<s>"[1..-1]>\'";
str atom2prolog((Atom)`<Int n>`) = "<n>";
str atom2prolog((Atom)`<Real r>`) = "<r>";

str flint2prolog((Decl)`<Id f>(<{Atom ","}* args>)`)
  = "<f>(<intercalate(", ", [ atom2prolog(a) | a <- args ])>).";
  
str flint2prolog((Decl)`<Atom a> is a <Id x>`)
  = "classify(\'<x>\', <atom2prolog(a)>).";  

str flint2prolog((Decl)`iFact <TemporalModifier _> <Id name> <Formals fs> <MetaData* _> <Text _>`)
  = ":- dynamic <name>/<formals2arity(fs)>.";

str flint2prolog((Decl)`iFact <Id name> <Formals fs> <MetaData* _> <Text _>`)
  = ":- dynamic <name>/<formals2arity(fs)>.";
  

str flint2prolog((Decl)`iFact <TemporalModifier _> <Id name> <Formals fs> <MetaData* _> if <{Expr ","}* exps> <Text _>`)
  = "<name>(<intercalate(", ", formals2vars(fs))>) :- \n  <intercalate(", \n  ", [ expr2cond(e) | e <- exps ])>.";

str flint2prolog((Decl)`iFact <Id name> <Formals fs> <MetaData* _> if <{Expr ","}* exps> <Text _>`)
  = "<name>(<intercalate(", ", formals2vars(fs))>) :- <intercalate(", ", [ expr2cond(e) | e <- exps ])>.";


str flint2prolog((Decl)`relation <Id x>: <TemporalModifier _> <Name name> 
                       'has the power towards <Name p> to <Name action> <Name obj>
                       '<MetaData* _>
                       'when <{Expr ","}+ conds> 
                       'action <Formals fs>: <Statement+ stms>
                       '<Text _>`)
  = "hasPower(<x>, ACTOR, RECV, OBJ, <name2atom(action)>) :-
    '  classify(<name2atom(name)>, ACTOR),
    '  classify(<name2atom(p)>, RECV),
    '  classify(<name2atom(obj)>, OBJ),
    '  <intercalate(", ", [ expr2cond(e) | e <- conds])>.
    '
    'executePower(<x>, ACTOR, RECV, <name2atom(action)>, OBJ, [<intercalate(", ", formals2vars(fs))>]) :-
    '  hasPower(<x>, ACTOR, RECV, OBJ, <name2atom(action)>),
    '  get_time(NOW),
    '  <intercalate(", ", [ stm2assert(s) | s <- stms ])>.";  

str stm2assert((Statement)`+ <Id x>(<{Expr ","}* args>)`)
  = "assert(<x>(<intercalate(", ", [ expr2prolog(e) | e <- args ])>))";


str expr2cond((Expr)`<Id f>(<{Id ","}* xs>)`)
  = "<f>(<intercalate(", ", [ expr2prolog((Expr)`<Id x>`) | x <- xs ])>)";
  
str expr2cond((Expr)`<Expr l> \> <Expr r>`) = "<expr2prolog(l)> \> <expr2prolog(r)>";
str expr2cond((Expr)`<Expr l> \>= <Expr r>`) = "<expr2prolog(l)> \>= <expr2prolog(r)>";
str expr2cond((Expr)`<Expr l> \< <Expr r>`) = "<expr2prolog(l)> \< <expr2prolog(r)>";
str expr2cond((Expr)`<Expr l> \<= <Expr r>`) = "<expr2prolog(l)> \<= <expr2prolog(r)>";

str expr2cond((Expr)`<Expr l> == <Expr r>`) = "<expr2prolog(l)> = <expr2prolog(r)>";
str expr2cond((Expr)`<Expr l> != <Expr r>`) = "<expr2prolog(l)> \\= <expr2prolog(r)>";

str expr2cond((Expr)`<Expr l> and <Expr r>`) = "(<expr2prolog(l)> , <expr2prolog(r)>)";
str expr2cond((Expr)`<Expr l> or <Expr r>`) = "(<expr2prolog(l)> ; <expr2prolog(r)>)";

str expr2cond((Expr)`(<Expr e>)`) = expr2cond(e);

// this must be here, because findall is not an arithmetic expression.
str expr2cond((Expr)`<Id x> := sum(<Id n> | <Expr r>)`) 
  = "findall(<capitalize("<n>")>, <expr2cond(r)>, LIST), sum(LIST, <capitalize("<x>")>)";
  
default str expr2cond((Expr)`<Id x> := <Expr r>`) = "<capitalize("<x>")> is <expr2prolog(r)>";

str expr2cond((Expr)`not(<Expr e>)`) = "not(<expr2prolog(e)>)";

str expr2prolog((Expr)`<Expr l> + <Expr r>`) = "<expr2prolog(l)> + <expr2prolog(r)>";
str expr2prolog((Expr)`<Expr l> - <Expr r>`) = "<expr2prolog(l)> - <expr2prolog(r)>";
str expr2prolog((Expr)`<Expr l> * <Expr r>`) = "<expr2prolog(l)> * <expr2prolog(r)>";
str expr2prolog((Expr)`<Expr l> / <Expr r>`) = "<expr2prolog(l)> / <expr2prolog(r)>";
str expr2prolog((Expr)`<Int n>`) = "<n>";
str expr2prolog((Expr)`<Real n>`) = "<n>";
str expr2prolog((Expr)`now`) = "NOW";
str expr2prolog((Expr)`actor`) = "ACTOR";
str expr2prolog((Expr)`receiver`) = "RECV";
default str expr2prolog((Expr)`<Id x>`) = capitalize("<x>");
str expr2prolog((Expr)`(<Expr e>)`) = "(<expr2prolog(e)>)";

default str expr2prolog(Expr e) = "\'UNSUPPORTED: <e>\'";





