module Resolve2

import Flint2;
import ParseTree;
import String;
import List;
import Set;
import IO;

tuple[rel[loc,loc, str], set[Message], map[loc, str]] resolve(start[Main] m) {
  env = ();

  str makeDoc(str label, Text t) = "<label>: <trim("<t>"[1..-1])>";
  
  set[str] srcs = {};
  
  str getSrc(MetaData* md) {
    for (MetaData m <- md) {
      switch (m) {
        case (MetaData)`bron: <LineText t>`: { srcs += {"<t>"}; return "<t>"; }
        case (MetaData)`source: <LineText t>`: { srcs += {"<t>"}; return "<t>"; }
      }
    }
    return "";
  }
  
  visit (m) {
    case (Decl)`iFeit <Id x> <MetaData* md> <Text t>`:
      env["<x>"] = <x@\loc, makeDoc("iFeit", t), getSrc(md)>; 
    case (Decl)`iFact <Id x> <MetaData* md> <Text t>`:
      env["<x>"] = <x@\loc, makeDoc("iFact", t), getSrc(md)>; 
    case (Decl)`relatie <Id x>: <Relation _> <MetaData* md> <Text t>`:
      env["<x>"] = <x@\loc, makeDoc("relatie", t), getSrc(md)>; 
    case (Decl)`relation <Id x>: <Relation _> <MetaData* md> <Text t>`:
      env["<x>"] = <x@\loc, makeDoc("relation", t), getSrc(md)>; 
  }
  
  
  println(size(srcs));
  for (str s <- sort(srcs)) {
    println(s);
  }

  
  rel[loc, loc, str] r = {};
  set[Message] errs = {};
  map[loc, str] docs = ();
  
  ctx = "";
  // used-in links
  rel[loc, loc, str] rinv = {};
  
  
  
  top-down visit (m) {
    // Ref is used in expression and statements
    
    case (Decl)`relatie <Id d>: <Relation _> <MetaData* md> <Preconditions? _> <Action _> <Text _>`: { 
      ctx = "<d>";
    }
      
    case (Decl)`relation <Id d>: <Relation _> <MetaData* md> <Preconditions? _> <Action _> <Text _>`: { 
      ctx = "<d>";
    }
  
    
    case (Ref)`<Id x>`: { 
      n = "<x>";
      if (n in env) {
        r += {<x@\loc, env[n][0], n>};
        docs[x@\loc] = "Source: <env[n][2]>\<br\><env[n][1]>";
        rinv += {<env[n][0], x@\loc, ctx>};
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
  
  errs += { warning("Unused iFact/relation <k>", env[k][0]) | k <- env, env[k][0] notin r<1> }; 

  return <r + rinv, errs, docs>;
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
