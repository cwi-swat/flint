module Visualize

import vis::Figure;
import ParseTree;
import List;
import util::Editors;
import vis::KeySym;
import Flint;
import IO;

private FProperty FONT = font("Menlo");
private FProperty FONT_SIZE = fontSize(16);
private FProperty TO_ARROW = toArrow(triangle(7));

FProperty onClick(Decl d) =
    onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
          edit(d@\loc, [highlight(d@\loc.begin.line, "<d>")]);
          return true;
        });

FProperty onClickExpr(Expr d) =
    onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
          edit(d@\loc, [highlight(d@\loc.begin.line, "<d>")]);
          return true;
        });


Edges exprToEdges(e:(Expr)`niet <Expr a>`)
  = [edge(exprId(a), exprId(e))] + exprToEdges(a);

Edges exprToEdges(e:(Expr)`onbekend <Expr a>`)
  = [edge(exprId(e), exprId(a))] + exprToEdges(a);

Edges exprToEdges(e:(Expr)`<Expr l> en <Expr r>`)
  = [edge(exprId(l), exprId(e)), edge(exprId(r), exprId(e))]
     + exprToEdges(l) + exprToEdges(r);

Edges exprToEdges(e:(Expr)`<Expr l> of <Expr r>`)
  = [edge(exprId(e), exprId(l)), edge(exprId(e), exprId(r))] 
     + exprToEdges(l) + exprToEdges(r);

default Edges exprToEdges(Expr _) = [];


list[Figure] exprToNodes(e:(Expr)`niet <Expr a>`)
  = [ellipse(text(" ¬ "), id(exprId(e)), onClickExpr(e))] + exprToNodes(a);

list[Figure] exprToNodes(e:(Expr)`onbekend <Expr a>`)
  = [ellipse(text(" ? "), id(exprId(e))), onClickExpr(e)] + exprToNodes(a);

list[Figure] exprToNodes(e:(Expr)`<Expr l> en <Expr r>`)
  = [ellipse(text(" & "), id(exprId(e)), onClickExpr(e))]
     + exprToNodes(l) + exprToNodes(r);

list[Figure] exprToNodes(e:(Expr)`<Expr l> of <Expr r>`)
  = [ellipse(text("|"), id(exprId(e)), onClickExpr(e))]
     + exprToNodes(l) + exprToNodes(r);

default list[Figure] exprToNodes(Expr _) = [];

str exprId((Expr)`<Id f>(<{Id ","}* fs>)`) = "<f>";
default str exprId(Expr e) = "expr<e@\loc>";

Figure visualize(start[Main] flint) {
  list[Figure] ns = [];
  Edges es = [];
  
  visit (flint) {
    case d:(Decl)`feit <Id x>(<{Formal ","}* fs>)`: {
      ns += [ellipse(text("iFeit:\n<x>", FONT, FONT_SIZE), id("<x>"), onClick(d), gap(3.0))];
    }
      
    case d:(Decl)`actie <Id x>(<{Formal ","}* fs>) <Statement+ stats>`: {
      ns += [box(text("<x>(<fs>)", FONT, FONT_SIZE), id("<x>"), onClick(d), gap(3.0))];
      es += [ edge("<x>", "<f>", label(text("+", FONT, FONT_SIZE)), TO_ARROW) |
                (Statement)`+ <Id f>(<{Id ","}* _>)` <- stats ]
         +  [ edge("<x>", "<f>", label(text("-", FONT, FONT_SIZE)), TO_ARROW) |
                (Statement)`- <Id f>(<{Id ","}* _>)` <- stats ];  
    }
       
    case d:(Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr>`: {
      ns += [box(text("<r>(<fs>):\n<rr>", FONT, FONT_SIZE), id("<r>"), onClick(d), gap(3.0))];
      es += [ edge("<r>", "<rr.action.name>", TO_ARROW) ]; 
    }
    
    case d:(Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr> <Preconditions cc>`: {
      ns += [box(text("<r>(<fs>):\n<rr>", FONT, FONT_SIZE), id("<r>"), onClick(d), gap(3.0))]
         +  [ *exprToNodes(c) | c <- cc.conditions ];
         
      es += [ edge(exprId(c), "<r>") | c <- cc.conditions ]
        + [ edge("<r>", "<rr.action.name>", TO_ARROW) ]
        + [ *exprToEdges(c) | c <- cc.conditions ];
    }
    
  }

  return graph(ns, es, gap(40.0,40.0), hint("layered"), orientation(topDown()));
}

//Edges getEdges(DecisionGraph g) {
//  es = [];
//  es += [ edge(idOf(a), idOf(b), TO_ARROW) | <a, none(), b> <- g ];
//  es += [ edge(idOf(a), idOf(b), label(text(prettyPrint(e), FONT, FONT_SIZE)), TO_ARROW)
//          | <a, cond(e), b> <- g, bprintln("label = <prettyPrint(e)>") ];
//  es += [ edge(idOf(a), idOf(b), label(text("otherwise", FONT, FONT_SIZE)), TO_ARROW)
//          | <a, \else(), b> <- g ];
//  return es;

