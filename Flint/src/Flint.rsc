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
  = @Foldable "feit" Id "(" {Formal ","}* ")" Text
  | "actie" Id "(" {Formal ","}* ")" Statement+ 
  | "regel" Id "(" {Formal ","}* ")" "=" Expr
  | "regel" "unknown" Id "(" {Formal ","}* ")" "=" Expr
  | @Foldable "relatie" Id "(" {Formal ","}* ")" Relation Preconditions?
  | "rol" Id 
  | "document" Id 
  | @Foldable "situatie" Id name "{" Object* Fact* "}"
  ;
  
syntax Decl // english
  = @Foldable "iFact" Id "(" {Formal ","}* ")" Text
  | "action" Id "(" {Formal ","}* ")" Statement+ 
  | "rule" Id "(" {Formal ","}* ")" "=" Expr
  | "rule" "unknown" Id "(" {Formal ","}* ")" "=" Expr
  | @Foldable "relation" Id "(" {Formal ","}* ")" Relation Preconditions?
  | "role" Id 
  | "document" Id 
  | @Foldable "situation" Id name "{" Object* Fact* "}"
  ;  
  
syntax Object
  = Id id ":" Id class;
  
syntax Fact
  = Call call;
  
syntax Text
  = "{" Content "}"
  ;
  
lexical Content
  = @category="Comment" ![{}]* >> "}"
  ;
  
syntax Preconditions
  = "wanneer" {Expr ","}+ conditions
  | "when"  {Expr ","}+ conditions
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
  | "not" Expr
  | "onbekend" Expr
  | "unknown" Expr
  > left (
    left Expr "en" Expr
    | left Expr "and" Expr
  )  
  > left (
    left Expr "of" Expr
    | left Expr "or" Expr
  )
  | bracket "(" Expr ")"
  ;  
  
syntax Relation
  = Id from "is" Type "jegens" Id other "omtrent" Call action
  | Id from Type "to" Call action "of" Id other
  ; 
  
syntax Call
  = Ref name "(" {Id ","}* args ")"
  ;

syntax Type // english
  = "has" "the" "power"
  | "is" "immune" 
  | "is" "liable"
  | "has" "the" "freedom"
  ;
   
syntax Type
  = "bevoegd" | "immuun"
  | "onbevoegd" | "gehouden" 
  ;
 
lexical Id
  = [a-zA-Z][a-zA-Z0-9.]* !>> [a-zA-Z0-9.]
  | "#" [0-9]+ !>> [0-9]
  | "#" [a-zA-Z][a-zA-Z0-9.]* !>> [a-zA-Z0-9.]
  ;