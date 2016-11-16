module Eval


/*


Universe: opaque, untyped objects

World = set[Fact]

Fact = fact(str rel, list[Object])


Cond
  = Pattern
  | Cond & Cond


Pattern
  = pattern(str rel, list[str] vars)

derivations (also capture events here?)
  = Pattern if Condition
  
  
  
rules
  if Cond then REL Action*
  
  
Rel
  = hasPower(Role x, action, Role y)
  
Action
  + pattern
  - pattern
  


  
  

  


*/