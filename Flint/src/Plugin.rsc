module Plugin

import Flint2;
import ParseTree;
import util::IDE;
import Resolve2;
import Simulate;
import IO;
import String;
import List;

anno rel[loc,loc, str] Tree@hyperlinks;

data CompletionProposal 
  = sourceProposal(str newText) /*1*/
  | sourceProposal(str newText, str proposal) /*2*/
  | errorProposal(str errorText) /*3*/
  ;
list[CompletionProposal] flintProposer(start[Main] input, str prefix, int requestOffset) {
  println(prefix);
  println(requestOffset);
  names = {};
  visit (input) {
    case (Decl)`iFeit <Id x> <MetaData* _> <Text _>`:
      names += {"<x>"}; 
    case (Decl)`iFact <Id x> <MetaData* _> <Text _>`:
      names += {"<x>"}; 
    case (Decl)`relatie <Id x>: <Relation _> <MetaData* _> <Text _>`:
      names += {"<x>"}; 
    case (Decl)`relation <Id x>: <Relation _> <MetaData* _> <Text _>`:
      names += {"<x>"}; 
  }
  return sort([ sourceProposal(x) | x <- names, startsWith(x, prefix) ]);
}


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
    }),
    
    proposer(flintProposer, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWZ0123456789.:")
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
