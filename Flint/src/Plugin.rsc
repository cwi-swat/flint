module Plugin

import Flint2;
import ParseTree;
import util::IDE;
import Resolve2;
import vis::Render;
import Visualize;
import VisualizeTrace;
import Simulate;
import IO;

anno rel[loc,loc, str] Tree@hyperlinks;


void main() {
  registerLanguage("Flint", "flint", start[Main](str src, loc org) {
    return parse(#start[Main], src, org);
  });
  
  contribs = {
    annotator(Tree(Tree pt) {
      if (start[Main] f := pt) {
        <hlinks, msgs> = resolve(f);
        for (Message m <- msgs, m is error) {
          println("Error: <m.msg>");
        }
        for (Message m <- msgs, m is warning) {
          println("Warning: <m.msg>");
        }
        return pt[@hyperlinks=hlinks][@messages=msgs];
      }
      return pt[@messages={error("BUG: not a spec", pt@\loc)}];
    })
  };
  
  registerContributions("Flint", contribs);
  //  
  //  popup(
  //    menu("Flint",[
  //      action("Visualize", (Tree tree, loc sel) {
  //        if (start[Main] flint := tree) {
  //          render(visualize(flint));
  //        }
  //      }),
  //      action("Run situation", void (Tree tree, loc selection) {
  //        if (start[Main] flint := tree) {
  //          render(showSim(flint, extractWorld(flint, selection)));
  //        }
  //      })
  //    ])
  //  )
  //  
  //};
  //
  
}
