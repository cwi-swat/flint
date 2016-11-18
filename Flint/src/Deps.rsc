module Deps

import Flint2;
import ParseTree;

alias DepGraph = rel[str from, loc src, str on]; 


DepGraph deps(start[Main] flint) = deps(flint.top);
DepGraph deps((Main)`<Decl* ds>`) =  ( {} | it + deps(d) | d <- ds ); 

DepGraph deps(d:(Decl)`iFact <Id name> <Formals fs> <MetaData* _> if <{Expr ","}* exps> <Text _>`)
  = { <"<name>", e@\loc, u> | Expr e <- exps, str u <- uses(e) }; 


DepGraph deps(d:(Decl)`relation <Id x>: <Name name> 
                       'has the power towards <Name p> to <Name action> <Name obj>
                       '<MetaData* _>
                       'when <{Expr ","}+ conds> 
                       'action <Formals fs>: <Statement+ stms>
                       '<Text _>`) 
  = {<"<x>", e@\loc, u> | Expr e <- conds, str u <- uses(e) }
  + {<u, s@\loc, "<x>"> | Statement s <- stms, u <- uses(s) };

default DepGraph deps(Decl _) = {};

set[str] uses(Statement s) = { "<f>" | /Ref f := s }; 
set[str] uses(Expr e) = { "<f>" | /(Expr)`<Id f>(<{Id ","}* _>)` := e };