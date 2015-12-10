module Resolve

import Flint;
import ParseTree;

rel[loc, loc, str] resolve(start[Main] def) {
  defs = ();
  rel[loc, loc, str] refs = {};
  
  visit (def) {
    case (Decl)`feit <Id x>(<{Formal ","}* _>)`:
      defs["<x>"] = x@\loc;

    case (Decl)`actie <Id x>(<{Formal ","}* _>) <Statement+ _>`:
      defs["<x>"] = x@\loc;
    
    case (Decl)`relatie <Id x>(<{Formal ","}* _>) <Relation _>`:
      defs["<x>"] = x@\loc;
    
    case (Decl)`rol <Id x>`:
      defs["<x>"] = x@\loc;

    case (Decl)`document <Id x>`:
      defs["<x>"] = x@\loc;
  }
  
  visit (def) {
    case (Call)`<Id f>(<{Id ","}* _>)`: 
      refs += {<f@\loc, defs["<f>"], "<f>"> | "<f>" in defs };
      
    case (Formal)`<Id x>: <Id t>`:
       refs += {<t@\loc, defs["<t>"], "<t>"> | "<t>" in defs };
    //case (Relation)`<Id x> is <Type _> jegens <Id other> omtrent <Call _>`:
    //  refs += {<x@\loc, defs["<x>"], "<x>">,
    //           <other@\loc, defs["<other>"], "<other>">};
  }
  
  return refs;
}