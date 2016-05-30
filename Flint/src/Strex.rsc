module Strex

import IO;
import ParseTree;

data T 
  = tree(list[T] trees)
  | string(str s)
  ;


T tree([*a, string(str x), string(str y), *b]) 
  = tree([*a, string(x + y), *b]);


void example() {
  tree(string(/function/), 
}

T toT(Tree t) {
  switch (t) {
    case appl(regular(Symbol s), args): 
      return tree([ toT(a) | a <- args ]);
      
    case appl(prod(Symbol s, _, _), args): {
      println(s);
      if (!(s is lex)) {
        return tree([ toT(a) | a <- args ]);
      }
      else {
        return string("<t>");
      }
    }
    default: {
      rprintln(t);
      return string("<t>");
    }
  }
}
  
  
/*

@ = tree(_)
(* p *) = /p
(% p... %) = tree([p...])
regexp = string(/regexp/)
*/   
