module Outline

import ParseTree;
import Flint2;

node flintOutliner(start[Main] m) {
  i = [];
  g = [];
  s = [];

  visit (m) {
    case (Decl)`iFeit <Id x> <MetaData* _> <Text t>`:
      i += ["iFact"()[@label="<x>"][@\loc=x@\loc]];
       
    case (Decl)`iFact <Id x> <MetaData* _> <Text t>`:
      i += ["iFact"()[@label="<x>"][@\loc=x@\loc]];
    
    case (Decl)`relatie <Id x>: <Relation _> <MetaData* _> <Text t>`:
      s += ["srel"()[@label="<x>"][@\loc=x@\loc]];

    case (Decl)`relation <Id x>: <Relation _> <MetaData* _> <Text t>`:
      s += ["srel"()[@label="<x>"][@\loc=x@\loc]];
      
    case (Decl)`relatie <Id d>: <Relation _> <MetaData* _> <Preconditions? _> <Action _> <Text _>`: 
      g += ["grel"()[@label="<d>"][@\loc=d@\loc]];
      
    case (Decl)`relation <Id d>: <Relation _> <MetaData* _> <Preconditions? _> <Action _> <Text _>`: 
      g += ["grel"()[@label="<d>"][@\loc=d@\loc]];
  }

  ifacts = "ifacts"(i)[@label="iFacts"];
  genrels = "genrels"(g)[@label="Generative"];
  sitrels = "sitrels"(s)[@label="Situational"];

  root = "root"(ifacts, genrels, sitrels);
  return root;
}