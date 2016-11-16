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
  | Id 
  ; 
  
syntax Formals
 = "(" {Formal ","}* ")"
 ;  
 
syntax Decl
  = @Foldable iFeit: "iFeit" TemporalModifier? Id id Formals? MetaData* Text
  | @Foldable iFact: "iFact" TemporalModifier? Id  Formals?  MetaData* Text
  | @Foldable iFact: "iFact" TemporalModifier? Id Formals? MetaData* "if" {Expr ","}+ Text
  | @Foldable genRelatie: "relatie" Id id ":" Relation MetaData* Preconditions? Action Text
  | @Foldable genRelation: "relation" Id id ":" Relation MetaData* Preconditions? Action Text
  | @Foldable sitRelatie: "relatie" Id id ":" Relation MetaData* Text
  | @Foldable sitRelation: "relation" Id id ":" Relation MetaData* Text
  | Id "(" {Atom ","}* ")" 
  | Atom "is" "a" Id 
  ;

lexical String
  = [\"] ![\"]* [\"];

syntax Atom
  = String
  | Int
  | Real
  ;  
  
syntax Text
  = @Foldable "{" Content "}"
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
  = "actie" Formals? ":" Statement+ stats
  | "action" Formals? ":" Statement+ stats
  ;

syntax Info
  = Ref
  | Ref "(" {Expr ","}* ")"
  ;

syntax Statement
  = "+" Info 
  | [\-] Info
  ; 
  
syntax Ref
  = @category="Variable" Id
  ;
  
lexical Int
  = [\-]?[1-9][0-9]* !>> [0-9]
  | [0]
  ;
  
lexical Real
  = Int "." [0-9]* !>> [0-9]
  ;
  
syntax Expr
  = Id 
  | Int
  | Real
  | "now"
  | 'niet' Expr
  | 'not' Expr
  | Id "(" {Id ","}* ")"
  | left (
    Expr "*" Expr
  | Expr "/" Expr 
  | "sum" "(" Id "|" Expr ")"
  )
  >
  left (Expr "+" Expr
  |Expr "-" Expr
  )
  >
  > non-assoc (
    Expr "\<" Expr
    |  Expr "\>" Expr
    |  Expr "\>=" Expr
    |  Expr "\<=" Expr
    |  Expr "==" Expr
    |  Expr "!=" Expr
  )
  > left (
    left Expr 'en' Expr
    | left Expr 'and' Expr
  )  
  > left (
    left Expr 'of' Expr
    | left Expr 'or' Expr
  )
  
  >
  Id ":=" Expr
  | bracket "(" Expr ")"
  ;  
  
syntax Relation
  = TemporalModifier? Name from Type "jegens" Name other "tot" "het" Name action "van" Name object
  | TemporalModifier? Name from Type "jegens" Name other "tot" Name object
  | TemporalModifier? Name from Type "towards" Name "to" Name action Name object
  | TemporalModifier? Name from Type "towards" Name "to" Name object
  ; 
  
syntax TemporalModifier 
  = "yearly"
  | "monthly"
  | "weekly"
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
  = ([a-zA-Z0-9][a-zA-Z][a-zA-Z0-9.:�áóé/=]* !>> [a-zA-Z0-9.]) \ Reserved
  | [a-zA-Z] !>> [a-zA-Z0-9.]
  | "_"
  | "actor"
  | "receiver"
  ;
  
keyword Reserved
  = "now"
  | "actor"
  | "receiver"
  ;
  