module Plugin

import Flint;
import ParseTree;
import util::IDE;
import Resolve;

anno rel[loc,loc, str] Tree@hyperlinks;


void main() {
  registerLanguage("Flint", "flint", start[Main](str src, loc org) {
    return parse(#start[Main], src, org);
  });
  
  contribs = {
    // outliner(node(Tree pt) {
    //  if (Form f := pt.args[1]) {
    //    return outline(f);
    //  }
    //  throw "Error: not a form";
    //}),
    
//    annotator(start[Form](start[Form] pt) {
    annotator(Tree(Tree pt) {
      if (start[Main] f := pt) {
        return pt[@hyperlinks=resolve(f)];
      }
      return pt[@messages={error("BUG: not a form", pt@\loc)}];
    })
    
  };
  
  registerContributions("Flint", contribs);
}
