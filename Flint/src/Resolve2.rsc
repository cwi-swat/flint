module Resolve2

import Flint2;
import ParseTree;
import String;
import List;

tuple[rel[loc,loc, str], set[Message]] resolve(start[Main] m) {
  env = ();

  visit (m) {
    case (Decl)`iFeit <Id x> <MetaData* _> <Text _>`:
      env["<x>"] = x@\loc; 
    case (Decl)`iFact <Id x> <MetaData* _> <Text _>`:
      env["<x>"] = x@\loc; 
    case (Decl)`relatie <Id x>: <Relation _> <MetaData* _> <Text _>`:
      env["<x>"] = x@\loc; 
    case (Decl)`relation <Id x>: <Relation _> <MetaData* _> <Text _>`:
      env["<x>"] = x@\loc; 
  }
  
  rel[loc, loc, str] r = {};
  set[Message] errs = {};
  
  visit (m) {
    // Ref is used in expression and statements
    case (Ref)`<Id x>`: { 
      n = "<x>";
      if (n in env) {
        r += {<x@\loc, env[n], n>};
      }
      else {
        //alts = suggestions(env, n);
        alts = {};
        if (alts == {}) {
          errs += {error("Undefined iFact/relation <x>", x@\loc)};
        }
        else {
          errs += {error("Undefined iFact/relation <x>\n(Did you mean <alts>)", x@\loc)};
        } 
      }
    }
  }
  
  errs += { warning("Unused iFact/relation <k>", env[k]) | k <- env, env[k] notin r<1> }; 

  return <r, errs>;
}


@memo
set[str] suggestions(map[str, loc] env, str n) 
  = { k | k <- env, distance(k, n) <= 3 };

int distance(str lhs, str rhs) {
    len0 = size(lhs) + 1;                                                     
    len1 = size(rhs) + 1;                                                     
                                                                                    
    // the array of distances                                                       
    cost = [ i | i <- [0..len0] ];                                                     
    newcost = [ 0 | i <- [0..len0] ];                                                  
                                                                                    
    // dynamically computing the array of distances                                  
                                                                                    
    // transformation cost for each letter in s1                                    
    for (int j <- [1..len1]) {                                                
        // initial cost of skipping prefix in String s1                             
        newcost[0] = j;                                                             
                                                                                    
        // transformation cost for each letter in s0                                
        for (int i <- [1..len0]) {                                             
            // matching current letters in both strings                             
            int match = (lhs[i - 1] == rhs[j - 1]) ? 0 : 1;             
                                                                                    
            // computing cost for each transformation                               
            int cost_replace = cost[i - 1] + match;                                 
            int cost_insert  = cost[i] + 1;                                         
            int cost_delete  = newcost[i - 1] + 1;                                  
                                                                                    
            // keep minimum cost                                                    
            newcost[i] = min([ min([cost_insert, cost_delete]), cost_replace]);
        }                                                                           
                                                                                    
        // swap cost/newcost arrays                                                 
        list[int] swap = cost; 
        cost = newcost; 
        newcost = swap;                          
    }                                                                               
                                                                                    
    // the distance is the cost for transforming all letters in both strings        
    return cost[len0 - 1];                                                          
}
