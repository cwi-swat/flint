module Flint

extend lang::std::Layout;

start syntax Main
  = Def*
  ;

syntax Def
  = "context" LineText Decl*
  ;
  
lexical LineText
  = ![\r\n]* $
  ;
  
 
syntax Formal
  = Id ":" Id 
  ; 
  
syntax Decl
  = "feit" Id "(" {Formal ","}* ")" 
  | "actie" Id "(" {Formal ","}* ")" Statement+ 
  | "regel" Id "(" {Formal ","}* ")" "=" Expr
  | "regel" "unknown" Id "(" {Formal ","}* ")" "=" Expr
  | @Foldable "relatie" Id "(" {Formal ","}* ")" Relation Preconditions?
  | "rol" Id 
  | "document" Id 
  ;
  
syntax Preconditions
  = "wanneer" {Expr ","}+ conditions
  ; 

syntax Statement
  = "+" Call
  | [\-] Call
  ; 
  
syntax Ref
  = @category="Variable" Id
  ;
  
syntax Expr
  = Call 
  | "niet" Expr
  | "onbekend" Expr
  > left Expr "en" Expr
  > left Expr "of" Expr
  ;  
  
syntax Relation
  = Id from "is" Type "jegens" Id other "omtrent" Call action
  ; 
  
syntax Call
  = Ref name "(" {Id ","}* ")"
  ;

syntax Type
  = "bevoegd" | "immuun"
  | "onbevoegd" | "gehouden" 
  ;
 
lexical Id
  = [a-zA-Z][a-zA-Z0-9.]* !>> [a-zA-Z0-9.]
  | "#" [0-9]+ !>> [0-9]
  ;