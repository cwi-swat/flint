module Simulate

import Flint;
import List;
import Set;
import ParseTree;
import IO;

alias World = tuple[Objects objects, Facts facts];
alias Objects = map[int id, str class];

data Action = action();

alias Facts = rel[bool enabled, str name, list[int] args];

alias Env = map[Id name, int obj];

public World initialWorld = <
(1: "Minister", 
 2: "Aanvrager",
 3: "Aanvrager",
 4: "Aanvraag",
 5: "Aanvraag"),
{
<true, "Vw.14.1.a.aanvraag", [2, 4]>,
<true, "Vw.14.1.a.aanvraag", [3, 5]>,
<false, "Vw.16.1.a", [3]>,
<true, "Vw.16.1.a", [2]>
}
>;

Relation instantiate(Relation r, Env e) {
  return visit(r) {
     case Id x => parse(#Id, "#<e[x]>")
       when x in e
  }
}

set[Env] allBindings({Formal ","}* fs, World world) {
  classes = { "<x>" | (Formal)`<Id _>: <Id x>` <- fs };
  objs = { k | k <- world.objects };
  set[str] typesOf(set[int] objs) = { world.objects[k] | k <- objs }; 

  result = {};
  for (subset <- power(objs), typesOf(subset) == classes) {
    // for now assume that each formal has different class.
    result += ( f: obj | (Formal)`<Id f>: <Id c>` <- fs,
      obj <- subset, typesOf({obj}) == {"<c>"} );
  }
  return result;
}

bool eval({Expr ","}+ conds, Env env, World world) 
  = all(c <- conds, eval(c, env, world));

bool eval((Expr)`<Id f>(<{Id ","}* args>)`, Env env, World world) {
  objs = [ env[a] | a <- args ];
  return <true, "<f>", objs> in world.facts;
}

bool eval((Expr)`niet <Id f>(<{Id ","}* args>)`, Env env, World world) {
  objs = [ env[a] | a <- args ];
  val = <false, "<f>", objs> in world.facts;
  println("VAL = <val>");
  return val;
} 

bool eval((Expr)`onbekend <Id f>(<{Id ","}* args>)`, Env env, World world) {
  objs = [ env[a] | a <- args ];
  return !any(<_, "<f>", objs> <- world.facts);
} 

bool eval((Expr)`<Expr l> en <Expr r>`, Env env, World world)
  = eval(l, env, world) && eval(r, env, world);

bool eval((Expr)`<Expr l> of <Expr r>`, Env env, World world)
  = eval(l, env, world) || eval(r, env, world);


set[Relation] relations(start[Main] flint, World world) {
  result = {};
  
  visit (flint) {
    case (Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr>`:
      result += { instantiate(rr, env) | env <- allBindings(fs, world) }; 
    case (Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr> <Preconditions cc>`:
      result += { instantiate(rr, env) | env <- allBindings(fs, world), eval(cc.conditions, env, world) }; 
  }

  return result;
  /*
   for all relations, and all possible bindings of the parameters
     if the preconditions are true in the current world, enable
     the action for the "owner" 
  
  */
}

