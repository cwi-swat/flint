module Simulate

import Flint;
import List;
import Set;
import ParseTree;
import IO;

alias World = tuple[Objects objects, Facts facts];
alias Objects = map[str id, str class];

data Action = action();

alias Facts = rel[bool enabled, str name, list[str] args];

alias Env = map[Id name, str obj];

public World initialWorld = <
("1": "Minister", 
 "2": "Aanvrager",
 "3": "Aanvrager",
 "4": "Aanvraag",
 "5": "Aanvraag"),
{
<true, "Vw.14.1.a.aanvraag", ["2", "4"]>,
<true, "Vw.14.1.a.aanvraag", ["3", "5"]>,
<false, "Vw.16.1.a", ["3"]>,
<true, "Vw.16.1.a", ["2"]>
}
>;

World extractWorld(start[Main] flint, loc sel) {
  objs = ();
  facts = {};
  if (treeFound(Decl d) := treeAt(#Decl, sel, flint)) {
    visit (d) {
      case Object obj: objs["<obj.id>"] = "<obj.class>";
      case Fact f: facts += {<true, "<f.call.name>", [  "<a>" | a <- f.call.args ] >};
    }
    return <objs, facts>;
  }
  return <(), {}>;
}

Relation instantiate(Relation r, Env e) {
  return visit(r) {
     case Id x => parse(#Id, "#<e[x]>")
       when x in e
  }
}

Call instantiateCall(Call c, Env e) {
  return visit(c) {
     case Id x => parse(#Id, "#<e[x]>")
       when x in e
  }
}


set[value] recProd(list[set[value]] l) {
  if (size(l) == 2) {
    return l[0] * l[1];  
  }
  return l[0] * recProd(l[1..]);
}

set[list[&T]] bigprod(list[set[&T]] l) {
  set[list[&T]] result = {};
  for (v <- recProd(l)) {
    t = [];
    visit (v) {
      case &T x: t += [x];
    }
    result += {t};
  }
  return result;
}

set[Env] allBindings({Formal ","}* fs, World world) {
  println("all Bindings: <fs>, world = <world>");
  classes = { "<x>" | (Formal)`<Id _>: <Id x>` <- fs };
  objs = { k | k <- world.objects };
  set[str] typesOf(set[str] objs) = { world.objects[k] | k <- objs }; 

  result = {};
  for (subset <- power(objs), typesOf(subset) == classes) {
    // for now assume that each formal has different class.
    result += ( f: obj | (Formal)`<Id f>: <Id c>` <- fs,
      obj <- subset, typesOf({obj}) == {"<c>"} );
  }
  return result;
}

alias Trace = list[str];

tuple[bool, Trace] eval({Expr ","}+ conds, Env env, World world) {
  trace = [];
  for (c <- conds) {
    <b, t> = eval(c, env, world);
    if (!b) {
      return <false, []>;
    }
    trace += t;
  }
  return <true, trace>; 
} 

tuple[bool, Trace] eval((Expr)`<Id f>(<{Id ","}* args>)`, Env env, World world) {
  println("call <f>(<args>)");
  objs = [ env[a] | a <- args ];
  b = <true, "<f>", objs> in world.facts;
  if (b) {
    call = instantiateCall((Call)`<Id f>(<{Id ","}* args>)`, env);
    return <true, ["<call>"]>;
  }
  return <false, []>;
}

tuple[bool, Trace] eval((Expr)`niet <Id f>(<{Id ","}* args>)`, Env env, World world) {
  println("niet <f>(<args>)");
  objs = [ env[a] | a <- args ];
  b = <true, "<f>", objs> in world.facts;
  if (!b) {
    call = instantiateCall((Call)`<Id f>(<{Id ","}* args>)`, env);
    return <true, ["¬ <call>"]>;
  }
  return <false, []>;
} 

//bool eval((Expr)`onbekend <Id f>(<{Id ","}* args>)`, Env env, World world) {
//  objs = [ env[a] | a <- args ];
//  return !any(<_, "<f>", objs> <- world.facts);
//} 

//bool eval((Expr)`<Expr l> en <Expr r>`, Env env, World world)
//  = eval(l, env, world) && eval(r, env, world);

default tuple[bool, Trace] eval((Expr)`niet <Expr x>`, Env env, World world) {
  println("niet <x>");
  <lb, lt> = eval(x, env, world);
  if (!lb) {
    return <true, lt>;
  }
  return <false, []>;
}

tuple[bool, Trace] eval((Expr)`(<Expr x>)`, Env env, World world) 
  = eval(x, env, world);


tuple[bool, Trace] eval((Expr)`<Expr l> en <Expr r>`, Env env, World world) {
  println("<l> en <r>");
  <lb, lt> = eval(l, env, world);
  if (!lb) {
    return <false, []>;
  }
  <rb, rt> = eval(r, env, world);
  if (!rb) {
    return <false, []>;
  }
  return <true, lt + rt>;
}


tuple[bool, Trace] eval((Expr)`<Expr l> of <Expr r>`, Env env, World world) {
  println("<l> of <r>");
  <lb, lt> = eval(l, env, world);
  if (lb) {
    return <true, lt>;
  }
  <rb, rt> = eval(r, env, world);
  if (rb) {
    return <true, rt>;
  }
  return <false, []>;
}


rel[Relation, Trace] relations(start[Main] flint, World world) {
  result = {};
  
  visit (flint) {
    case (Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr>`:
      result += { <instantiate(rr, env), []> | env <- allBindings(fs, world) }; 
    case (Decl)`relatie <Id r>(<{Formal ","}* fs>) <Relation rr> <Preconditions cc>`: 
      result += { <instantiate(rr, env), t> | env <- allBindings(fs, world),
        <bool b, Trace t> := eval(cc.conditions, env, world), b }; 
  }

  return result;
}

