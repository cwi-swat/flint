module VisualizeTrace

import Visualize;
import Simulate;
import List;
import Flint;
import vis::Figure;

public FProperty LFONT = font("Times");
public FProperty LFONT_SIZE = fontSize(16);

Figure visObjects(Objects objs) 
  = vcat(
   [box(text("Objects", LFONT, LFONT_SIZE), vresizable(false), valign(0))] 
  + [ text("#<k>: <objs[k]>", LFONT, LFONT_SIZE) | k <- sort([i | i <- objs]) ]);

Figure visFacts(Facts facts) 
  = vcat(
   [box(text("Facts", LFONT, LFONT_SIZE), vresizable(false), valign(0))] 
  + [ text("<n>(<intercalate(", ", [ "#<i>" | i <- args ])>)", LFONT, LFONT_SIZE) | <true, n, args> <- facts ]);
  
Figure visRels(rel[Relation, Trace] rels) =
  vcat( 
     [box(text("Enabled relations", LFONT, LFONT_SIZE), vresizable(false), valign(0))] 
    + [hcat([box(text("<r>", LFONT, LFONT_SIZE), vresizable(false), valign(0), lineWidth(0)),
       box(text(""), width(2), hresizable(false)),
       vcat([ box(text(t, LFONT, LFONT_SIZE), valign(0),lineWidth(0)) | t <- trace], resizable(false))], hgap(10))
   | <r, trace> <- rels ], gap(10));

Figure showSim(start[Main] flint, World world) {
  rels = relations(flint, world);
  fig = vcat([hcat([visObjects(world.objects), visFacts(world.facts)]), visRels(rels)]);
  return hcat([visualize(flint), fig], gap(20));
}