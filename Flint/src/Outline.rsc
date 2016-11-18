module Outline

import ParseTree;
import Flint2;
import List;

node flintOutliner(start[Main] m) {
  i = [];
  g = [];
  s = [];

  visit (m) {
    case (Decl)`iFeit <Id x> <MetaData* _> <Text t>`:
      i += ["iFact"()[@label="<x>"][@\loc=x@\loc]];
       
    case (Decl)`iFact <Id x> <MetaData* _> <Text t>`:
      i += ["iFact"()[@label="<x>"][@\loc=x@\loc]];
    
    case (Decl)`iFact <Id x> <Formals f> <MetaData* _> <Text t>`:
      i += ["iFact"()[@label="<x><f>"][@\loc=x@\loc]];
    
    case (Decl)`relatie <Id x>: <Relation _> <MetaData* _> <Text t>`:
      s += ["srel"()[@label="<x>"][@\loc=x@\loc]];

    case (Decl)`relation <Id x>: <Relation _> <MetaData* _> <Text t>`:
      s += ["srel"()[@label="<x>"][@\loc=x@\loc]];
      
    case (Decl)`relatie <Id d>: <Relation _> <MetaData* _> <Preconditions? _> <Action _> <Text _>`: 
      g += ["grel"()[@label="<d>"][@\loc=d@\loc]];
      
    case (Decl)`relation <Id d>: <Relation _> <MetaData* _> <Preconditions? _> <Action _> <Text _>`: 
      g += ["grel"()[@label="<d>"][@\loc=d@\loc]];
  }

  ifacts = "ifacts"(i)[@label="Institutional Facts (<size(i)>)"];
  genrels = "genrels"(g)[@label="Generative Relations (<size(g)>)"];
  sitrels = "sitrels"(s)[@label="Situational Relations (<size(s)>)"];

  root = "root"(ifacts, genrels, sitrels);
  return root;
}