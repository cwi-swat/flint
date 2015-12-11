module Resolve

import Flint;
import ParseTree;
import Message;

tuple[set[Message], rel[loc, loc, str]] resolve(start[Main] def) {
  defs = ();
  rel[loc, loc, str] refs = {};
  
  msgs = {};
  
  visit (def) {
    case (Decl)`feit <Id x>(<{Formal ","}* _>) <Text _>`:
      defs["<x>"] = x@\loc;

    case (Decl)`actie <Id x>(<{Formal ","}* _>) <Statement+ _>`:
      defs["<x>"] = x@\loc;
    
    //case (Decl)`relatie <Id x>(<{Formal ","}* _>) <Relation _>`:
    //  defs["<x>"] = x@\loc;
    //
    //case (Decl)`relatie <Id x>(<{Formal ","}* _>) <Relation _> <Preconditions _>`:
    //  defs["<x>"] = x@\loc;
    
    case (Decl)`rol <Id x>`:
      defs["<x>"] = x@\loc;

    case (Decl)`document <Id x>`:
      defs["<x>"] = x@\loc;
  }
  
  visit (def) {
    case c:(Call)`<Id f>(<{Id ","}* _>)`:
      if ("<f>" in defs) { 
        refs += {<f@\loc, defs["<f>"], "<f>"> };
      }
      else {
        msgs += {error("Ongedefinieerd feit of actie", c@\loc)}; 
      }
      
    case f:(Formal)`<Id x>: <Id t>`:
       if ("<t>" in defs) {
         refs += {<t@\loc, defs["<t>"], "<t>"> };
       }
       else {
         msgs += {error("Ongedefinieerde object type of rol", f@\loc)};
       }
  }
  
  msgs += { warning("Ongebruikt element", d) | d <- defs<1>, d notin refs<1> };
  
  return <msgs, refs>;
}