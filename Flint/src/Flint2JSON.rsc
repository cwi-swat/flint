module Flint2JSON

import Flint2;
import IO;
import String;
import List;
import ParseTree;


str flint2json(loc path) {
  try {
    pt = parse(#start[Main], path);
    return flint2json(path, implode(pt));
  }
  catch ParseError(x): {
    return "{\"parseError\": \"<x>\"}";
  } 
}


data FLINT = flint(list[DECL] decls);

alias META
 = tuple[str key, str meta];

data DECL
  = iFact(str name, str text, list[META] metaData)
  | genRel(str name, str text, list[META] metaData, str actor, str typ, str other, str action, str obj
       , list[EXPR] pre, list[ACTION] post)
  | sitRel(str name, str text, list[META] metaData)
  ;
  
data ACTION
  = add(str ifact)
  | del(str ifact)
  ;

data EXPR
  = ref(str name)
  | not(EXPR arg)
  | and(EXPR lhs, EXPR rhs)
  | or(EXPR lhs, EXPR rhs)
  ;  
  
  
  
str flint2json(loc path, FLINT flint) {
  str decls2json(list[DECL] ds) = intercalate(",\n", [ decl2json(d) | d <- ds ]);

str norm(str x) = replaceAll(x, "\n", " ");
  
  str decl2json(iFact(str name, str text, list[META] meta))
    = "{
      '  \"type\": \"iFact\",
      '  \"name\": \"<name>\",
      '  \"text\": \"<norm(text)>\",
      '  \"meta\": <meta2json(meta)>
      '}";

  str decl2json(genRel(str name, str text, list[META] metaData, str actor, str typ, str other, str action, str obj
       , list[EXPR] pre, list[ACTION] post)) 
    = "{
      '  \"type\": \"genRelation\",
      '  \"name\": \"<name>\",
      '  \"text\": \"<norm(text)>\",
      '  \"meta\": <meta2json(metaData)>,
      '  \"actor\": \"<actor>\",
      '  \"rtype\": \"<typ>\",
      '  \"recipient\": \"<other>\",
      '  \"action\": \"<action>\",
      '  \"object\": \"<obj>\",
      '  \"pre\": [<intercalate(", ", [ exp2json(e) | e <- pre ])>],
      '  \"post\": [<intercalate(", ", [ action2json(a) | a <- post ])>]
      '}";
 
  str exp2json(ref(str name)) = "{\"ref\": \"<name>\"}";
  str exp2json(not(EXPR arg)) = "{\"not\": <exp2json(arg)>}";
  str exp2json(and(EXPR lhs, EXPR rhs)) = "{\"and\": [<exp2json(lhs)>, <exp2json(rhs)>]}";
  str exp2json(or(EXPR lhs, EXPR rhs)) = "{\"or\": [<exp2json(lhs)>, <exp2json(rhs)>]}";

  str action2json(add(str ifact)) = "{\"add\": \"<ifact>\"}";
  str action2json(del(str ifact)) = "{\"del\": \"<ifact>\"}";

  str meta2json(list[META] meta) = "{<intercalate(", ", [ "\"<k>\": \"<v>\"" | <k, v> <- meta ])>}";

  return "{\"path\": \"<path.path>\", 
         ' \"decls\": [
         '   <decls2json(flint.decls)>
         ' ]
         '}";
}  
  
FLINT implode(start[Main] pt) {
  decls = [];
  
  void addIFact(str name, str txt, list[META] metaData) {
    decls += [iFact(name, trim(txt[1..-1]), metaData)];
  }
  
  void addGenRel(str name, str txt, list[META] metaData, tuple[str, str, str, str, str] r, list[EXPR] cs, list[ACTION] as) {
    decls += [genRel(name, trim(txt[1..-1]), metaData, r[0][1..-1], r[1], r[2][1..-1], r[3][1..-1], r[4][1..-1], cs, as)];
  }
  
  META decomp((MetaData)`<Id k>: <LineText v>`) = <"<k>", "<v>">;
  
  tuple[str, str, str, str, str] decomp((Relation)`<Name from> <Type t> jegens <Name other> tot het <Name action> van <Name object>`)
    = <"<from>", "<t>", "<other>", "<action>", "<object>">;
  
  tuple[str, str, str, str, str] decomp((Relation)`<Name from> <Type t> towards <Name other> to <Name action> <Name object>`)
    = <"<from>", "<t>", "<other>", "<action>", "<object>">;
    
  EXPR exprOf((Expr)`<Expr l> en <Expr r>`) = and(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`<Expr l> and <Expr r>`) = and(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`<Expr l> of <Expr r>`) = or(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`<Expr l> or <Expr r>`) = or(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`niet <Expr x>`) = not(exprOf(x));
  EXPR exprOf((Expr)`not <Expr x>`) = not(exprOf(x));
  EXPR exprOf((Expr)`<Expr l> EN <Expr r>`) = and(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`<Expr l> AND <Expr r>`) = and(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`<Expr l> OF <Expr r>`) = or(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`<Expr l> OR <Expr r>`) = or(exprOf(l), exprOf(r));
  EXPR exprOf((Expr)`NIET <Expr x>`) = not(exprOf(x));
  EXPR exprOf((Expr)`NOT <Expr x>`) = not(exprOf(x));

  EXPR exprOf((Expr)`(<Expr x>)`) = exprOf(x);
  EXPR exprOf((Expr)`<Ref x>`) = ref("<x>");
  
  ACTION actionOf((Statement)`+ <Ref r>`) = add("<r>");
  ACTION actionOf((Statement)`- <Ref r>`) = del("<r>");
  
  top-down-break visit (pt) {
    case d:(Decl)`iFeit <Id x> <MetaData* ms> <Text t>`: addIFact("<x>", "<t>", [ decomp(m) | m <- ms ]);
    
    case d:(Decl)`iFact <Id x> <MetaData* ms> <Text t>`: addIFact("<x>", "<t>", [ decomp(m) | m <- ms ]);
    
    case d:(Decl)`relatie <Id r>: <Relation rr> <MetaData* ms> <Action a> <Text t>`:
      addGenRel("<r>", "<t>", [ decomp(m) | m <- ms ], decomp(rr), [], [ actionOf(s) | s <- a.stats ]);
    
    case d:(Decl)`relation <Id r>: <Relation rr> <MetaData* ms> <Action a> <Text t>`:
      addGenRel("<r>", "<t>", [ decomp(m) | m <- ms ], decomp(rr), [], [ actionOf(s) | s <- a.stats ]);

    case d:(Decl)`relatie <Id r>: <Relation rr> <MetaData* ms> <Preconditions cc> <Action a> <Text t>`:
      addGenRel("<r>", "<t>", [ decomp(m) | m <- ms ], decomp(rr),[ exprOf(c) | c <- cc.conditions, bprintln(c) ], [ actionOf(s) | s <- a.stats ]);

    case d:(Decl)`relation <Id r>: <Relation rr> <MetaData* ms> <Preconditions cc> <Action a> <Text t>`:
      addGenRel("<r>", "<t>", [ decomp(m) | m <- ms ], decomp(rr), [ exprOf(c) | c <- cc.conditions ], [ actionOf(s) | s <- a.stats ]);
      
  }
  
  return flint(decls);
}