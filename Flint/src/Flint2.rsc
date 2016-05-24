module Flint2

extend lang::std::Layout;

start syntax Main
  = Decl*
  ;

  
lexical LineText
  = ![\r\n]* $
  ;
  
 
syntax Formal
  = Id ":" Id 
  ; 
  
syntax Decl
  = @Foldable "iFeit" Id MetaData* Text
  | @Foldable "iFact" Id MetaData* Text
  | @Foldable "relatie" Id ":" Relation Preconditions? Action
  | @Foldable "relation" Id ":" Relation Preconditions? Action
  ;  
  
  
syntax Text
  = "{" Content "}"
  ;
  
lexical Content
  = @category="Comment" ![{}]* >> "}"
  ;
  
syntax MetaData
  = Id ":" LineText
  ;
  
syntax Preconditions
  = "wanneer" {Expr ","}+ conditions
  | "when"  {Expr ","}+ conditions
  ; 

syntax Action
  = "actie" ":" Statement+
  | "action" ":" Statement+
  ;

syntax Statement
  = "+" Ref
  | [\-] Ref
  ; 
  
syntax Ref
  = @category="Variable" Id
  ;
  
syntax Expr
  = Ref 
  | 'niet' Expr
  | 'not' Expr
  > left (
    left Expr 'en' Expr
    | left Expr 'and' Expr
  )  
  > left (
    left Expr 'of' Expr
    | left Expr 'or' Expr
  )
  | bracket "(" Expr ")"
  ;  
  
syntax Relation
  = Name from Type "jegens" Name other "tot" "het" Name action "van" Name object
  | Name from Type "towards" Name "to" Name action Name object
  ; 

syntax Name
  = "[" Id+ "]"
  ;  

syntax Type // english
  = "has" "the" "power" 
  | "is" "immune" 
  | "is" "liable"
  | "has" "the" "freedom"
  ;
   
syntax Type
  = "heeft" "de" "bevoegdheid" | "is" "immuun"
  | "is" "onbevoegd" | "is" "gehouden" 
  ;
 
lexical Id
  = [a-zA-Z][a-zA-Z0-9.:�]* !>> [a-zA-Z0-9.]
  ;