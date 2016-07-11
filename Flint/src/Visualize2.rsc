module Visualize2

import vis::Figure;
import ParseTree;
import List;
import util::Editors;
import vis::KeySym;
import Flint2;
import IO;
import String;

public FProperty FONT = font("Menlo");
public FProperty FONT_SIZE = fontSize(14);
public FProperty TO_ARROW = toArrow(triangle(7));

FProperty onClick(Decl d) =
    onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
          edit(d@\loc, []);
          return true;
        });

FProperty onClickExpr(Expr d) =
    onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
          edit(d@\loc, []);
          return true;
        });


Edges exprToEdges(e:(Expr)`niet <Expr a>`)
  = [edge(exprId(a), exprId(e))] + exprToEdges(a);

Edges exprToEdges(e:(Expr)`NIET <Expr a>`)
  = [edge(exprId(a), exprId(e))] + exprToEdges(a);

Edges exprToEdges(e:(Expr)`<Expr l> en <Expr r>`)
  = [edge(exprId(l), exprId(e)), edge(exprId(r), exprId(e))]
     + exprToEdges(l) + exprToEdges(r);

Edges exprToEdges(e:(Expr)`<Expr l> EN <Expr r>`)
  = [edge(exprId(l), exprId(e)), edge(exprId(r), exprId(e))]
     + exprToEdges(l) + exprToEdges(r);

Edges exprToEdges(e:(Expr)`<Expr l> of <Expr r>`)
  = [edge(exprId(l), exprId(e)), edge(exprId(r), exprId(e))] 
     + exprToEdges(l) + exprToEdges(r);

Edges exprToEdges(e:(Expr)`<Expr l> OF <Expr r>`)
  = [edge(exprId(l), exprId(e)), edge(exprId(r), exprId(e))] 
     + exprToEdges(l) + exprToEdges(r);


Edges exprToEdges(e:(Expr)`(<Expr x>)`)
  = exprToEdges(x);

default Edges exprToEdges(Expr _) = [];


list[Figure] exprToNodes(e:(Expr)`<Id f>`)
  = [ellipse(text("<f>", FONT, FONT_SIZE), id(exprId(e)), onClickExpr(e))];

list[Figure] exprToNodes(e:(Expr)`niet <Expr a>`)
  = [ellipse(text(" ¬ ", FONT, fontSize(18)), id(exprId(e)), onClickExpr(e))] + exprToNodes(a);

list[Figure] exprToNodes(e:(Expr)`NIET <Expr a>`)
  = [ellipse(text(" ¬ ", FONT, fontSize(18)), id(exprId(e)), onClickExpr(e))] + exprToNodes(a);

list[Figure] exprToNodes(e:(Expr)`<Expr l> en <Expr r>`)
  = [ellipse(text(" ∧ ", FONT, fontSize(18)), id(exprId(e)), onClickExpr(e))]
     + exprToNodes(l) + exprToNodes(r);

list[Figure] exprToNodes(e:(Expr)`<Expr l> EN <Expr r>`)
  = [ellipse(text(" ∧ ", FONT, fontSize(18)), id(exprId(e)), onClickExpr(e))]
     + exprToNodes(l) + exprToNodes(r);

list[Figure] exprToNodes(e:(Expr)`<Expr l> of <Expr r>`)
  = [ellipse(text(" ∨ ", FONT, fontSize(18)), id(exprId(e)), onClickExpr(e))]
     + exprToNodes(l) + exprToNodes(r);

list[Figure] exprToNodes(e:(Expr)`<Expr l> OF <Expr r>`)
  = [ellipse(text(" ∨ ", FONT, fontSize(18)), id(exprId(e)), onClickExpr(e))]
     + exprToNodes(l) + exprToNodes(r);

list[Figure] exprToNodes(e:(Expr)`(<Expr x>)`)
  = exprToNodes(x);

default list[Figure] exprToNodes(Expr _) = [];

//str exprId((Expr)`<Id f>`) = "$$<f>";
str exprId((Expr)`(<Expr e>)`) = exprId(e);
default str exprId(Expr e) = "expr<e@\loc.offset>#<e@\loc.length>";

Figure visualize(start[Main] flint, loc sel) {
  list[Figure] ns = [];
  Edges es = [];
  
  println(sel);
  
  Figure relNode(Decl d, Id r, (Relation)`<Name actor> heeft de bevoegdheid jegens <Name other> tot het <Name act> van <Name obj>`) {
    t = vcat([hcat([text("ACTOR: ", FONT, FONT_SIZE, fontBold(true)), text("<actor>", FONT, FONT_SIZE)]), 
       hcat([text("POWER: ", FONT, FONT_SIZE, fontBold(true)), text("<r>", FONT, FONT_SIZE)])]);
    m = box(vcat([
          hcat([
            text("<act>", FONT, FONT_SIZE),
            text(" van ", FONT, FONT_SIZE, fontBold(true))
          ]),
          text(wrap("<obj>", 40), FONT, FONT_SIZE)
        ]), hresizable(true), hgap(0.0));
    b = hcat([text("RECIPIENT: ", FONT, FONT_SIZE, fontBold(true)), text("<other>", FONT, FONT_SIZE)]);
    return box(vcat([t, m, b]), id("<r>"), onClick(d), hgap(0.0), vgap(3.0));
  }
  
  visit (flint) {
    //case d:(Decl)`iFeit <Id x> <MetaData* _> <Text _>`: {
    //  ns += [ellipse(text("iFeit:\n<x>", FONT, FONT_SIZE), id("<x>"), onClick(d), gap(3.0))];
    //}
      
    //case d:(Decl)`actie <Id x>(<{Formal ","}* fs>) <Statement+ stats>`: {
    //  ns += [box(text("<x>(<fs>)", FONT, FONT_SIZE), id("<x>"), onClick(d), gap(3.0))];
    //  es += [ edge("<x>", "<f>", label(text("+", FONT, FONT_SIZE)), TO_ARROW) |
    //            (Statement)`+ <Id f>(<{Id ","}* _>)` <- stats ]
    //     +  [ edge("<x>", "<f>", label(text("-", FONT, FONT_SIZE)), TO_ARROW) |
    //            (Statement)`- <Id f>(<{Id ","}* _>)` <- stats ];  
    //}
       
    case d:(Decl)`relatie <Id r>: <Relation rr> <MetaData* _> <Action a> <Text t>`: {
      if (d@\loc.offset == sel.offset) {
	      println("FOUND: <r>");
	      //ns += [box(text("<r>:\n<wrap("<rr>", 20)>", FONT, FONT_SIZE), id("<r>"), onClick(d), gap(3.0))];
	      ns += [relNode(d, r, rr)];  
	      
	      // TODO: factor out
	      // TODO: use locs for ids, it's not reliable currently...
	      ns += [ellipse(text("+ <f>", FONT, FONT_SIZE), id("+<f>"), gap(3.0)) |
	                (Statement)`+ <Id f>` <- a.stats ];

	      ns += [ellipse(text("- <f>", FONT, FONT_SIZE), id("-<f>"), gap(3.0)) |
	                (Statement)`- <Id f>` <- a.stats ];
	                
	      es += [ edge("<r>", "+<f>", TO_ARROW) |
	                (Statement)`+ <Id f>` <- a.stats ]
	         +  [ edge("<r>", "-<f>", TO_ARROW) |
	                (Statement)`- <Id f>` <- a.stats ];
	    }   
    }
    
    case d:(Decl)`relatie <Id r>: <Relation rr> <MetaData* _> <Preconditions cc> <Action a> <Text t>`: {
      if (d@\loc.offset == sel.offset) {
        println("FOUND: <r>");
        //ns += [box(text("<r>:\n<wrap("<rr>", 20)>", FONT, FONT_SIZE), id("<r>"), onClick(d), gap(3.0))]
	      ns += [relNode(d, r, rr)]  
	         +  [ *exprToNodes(c) | Expr c <- cc.conditions ];
	         
	      es += [ edge(exprId(c), "<r>") | Expr c <- cc.conditions ]
	        + [ *exprToEdges(c) | Expr c <- cc.conditions ];
	        
	      ns += [ellipse(text("+ <f>", FONT, FONT_SIZE), id("+<f>"), gap(3.0)) |
	                (Statement)`+ <Id f>` <- a.stats ];

	      ns += [ellipse(text("- <f>", FONT, FONT_SIZE), id("-<f>"), gap(3.0)) |
	                (Statement)`- <Id f>` <- a.stats ];
	                
	      es += [ edge("<r>", "+<f>", TO_ARROW) |
	                (Statement)`+ <Id f>` <- a.stats ]
	         +  [ edge("<r>", "-<f>", TO_ARROW) |
	                (Statement)`- <Id f>` <- a.stats ];   
	     }
    }
    
  }

  for (n <- ns, /id(str x) := n) {
    println(x);
  }
  return graph(ns, es, gap(40.0,40.0), hint("layered"), orientation(topDown()));
}

