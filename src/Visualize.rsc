module Visualize

import vis::Figure;
import ParseTree;
import List;
import util::Editors;
import vis::KeySym;
import Flint;
import IO;

str idOf(CF::split(i)) = "<i>";
str idOf(stat(i, _)) = "<i>";
str idOf(entry()) = "entry";
str idOf(exit()) = "exit";
str idOf(dummy(i)) = "dummy_<id>";

private FProperty FONT = font("Monospaced");
private FProperty FONT_SIZE = fontSize(10);
private FProperty TO_ARROW = toArrow(triangle(5));

FProperty onClick(Question q, QuestionText txt) =
    onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
          edit(q@location, [highlight(q@location.begin.line, unquote(txt.text))]);
          return true;
        });

alias FigGraph = tuple[list[Figure] nodes, list[Figure] edges];

Edges exprToEdges(e:(Expr)`niet <Expr a>`)
  = [edge(exprId(e), exprId(a))] + exprToEdges(a);

Edges exprToEdges(e:(Expr)`onbekend <Expr a>`)
  = [edge(exprId(e), exprId(a))] + exprToEdges(a);

Edges exprToEdges((Expr)`<Expr l> en <Expr r>`)
  = [edge(exprId(e), exprId(l)), edge(exprId(e), exprId(l))]
     + exprToEdges(l) + exprToEdges(r);

Edges exprToEdges(e:(Expr)`<Expr l> of <Expr r>`)
  = [edge(exprId(e), exprId(l)), edge(exprId(e), exprId(l))] 
     + exprToEdges(l) + exprToEdges(r);

default Edges exprToEdges(Expr _) = [];


list[Figure] exprToNodes(e:(Expr)`niet <Expr a>`)
  = [circle(id(exprId(e)), text("¬"))] + exprToNodes(a);

list[Figure] exprToNodes(e:(Expr)`onbekend <Expr a>`)
  = [circle(id(exprId(e)), text("?"))] + exprToNodes(a);

list[Figure] exprToNodes((Expr)`<Expr l> en <Expr r>`)
  = [circle(id(exprId(e)), text("&"))]
     + exprToNodes(l) + exprToNodes(r);

list[Figure] exprToNodes(e:(Expr)`<Expr l> of <Expr r>`)
  = [circle(id(exprId(e)), text("|"))]
     + exprToNodes(l) + exprToNodes(r);

default list[Figure] exprToNodes(Expr _) = [];

str exprId((Expr)`<Id f>(<{Id ","}* fs>)`) = "<f>";
default str exprId(Expr e) = "expr<e@\loc>";

list[Figure] getNodes(start[Main] flint) {
  visit (flint) {
    case (Decl)`feit <Id x>(<{Formal ","}* fs>)`: {
      ns += [ellipse(id("<x>"), text("iFeit:\n<x>", FONT, FONT_SIZE))];
    }
      
    case (Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr>`: {
      ns += [box(id("<r>"), text("<r>:\n<rr>"))]; 
    }
       
    case (Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr> <Preconditions cc>`: {
      ns += [box(id("<r>"), text("<r>:\n<rr>"))];
    }
    
  }

  ns = g<0> + g<2>;
  fns = [ circle(id(idOf(s)), resizable(false), width(4), height(4)) | s:split(int i) <- ns ];
  fns += [ box(text("<x.ident>: <at.name>", FONT, FONT_SIZE), id(idOf(s)), resizable(false), gap(5), onClick(q, txt)) 
           | s:stat(int i, q:question(txt, Type at, x)) <- ns ];
  fns += [ ellipse(text("<x.ident> =\n<prettyPrint(e)>", FONT, FONT_SIZE), id(idOf(s)), resizable(false), onClick(q, txt)) 
           | s:stat(int i, q:question(txt, _, x, e)) <- ns ];
  fns += [ ellipse(id(idOf(s)), resizable(false), width(10), height(10), fillColor("red")) | s <- ns, (s is entry || s is exit)];
  fns += [ ellipse(id(idOf(s))) | s:dummy(_) <- ns ];
  return fns;
}

Edges getEdges(DecisionGraph g) {
  es = [];
  es += [ edge(idOf(a), idOf(b), TO_ARROW) | <a, none(), b> <- g ];
  es += [ edge(idOf(a), idOf(b), label(text(prettyPrint(e), FONT, FONT_SIZE)), TO_ARROW)
          | <a, cond(e), b> <- g, bprintln("label = <prettyPrint(e)>") ];
  es += [ edge(idOf(a), idOf(b), label(text("otherwise", FONT, FONT_SIZE)), TO_ARROW)
          | <a, \else(), b> <- g ];
  return es;
}

Figure form2figure(Form f) {
  cfg = cflow(f);
  ns = getNodes(cfg.graph);
  es = getEdges(cfg.graph);
  return graph(ns, es, gap(50.0,50.0), hint("layered"), orientation(topDown()));
}
