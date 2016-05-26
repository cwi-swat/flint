module Plugin

import Flint2;
import ParseTree;
import util::IDE;
import Resolve2;
import Simulate;
import Outline;
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
  ps = sort([ sourceProposal(x) | x <- names, startsWith(x, prefix) ]);
  if (prefix == "rel") {
    ps = [ sourceProposal("relation x: [role] has the power towards [role] to [action] [object] 
            '  source:
            '  link:
            'when
            '  c
            'action:
            '  + iFact
            '{
            '  Text
            '}", "New generative relation (English)"),
            sourceProposal("relatie x: [role] heeft de bevoegdheid jegens [role] tot het [action] van [object] 
            '  bron:
            '  link:
            'wanneer
            '  c
            'actie:
            '  + iFact
            '{
            '  Tekst
            '}", "New generative relation (Dutch)")] + ps;
  }
  if (prefix == "iFa") {
    ps = [ sourceProposal("iFact x 
            '  source:
            '  link:
            '{
            '  Text
            '}", "New iFact (English)") ] + ps;
   }
   
   if (prefix == "iFe") {
      ps = [ sourceProposal("iFeit x 
            '  bron:
            '  link:
            '{
            '  Tekst
            '}", "New iFact (Dutch)")] + ps;
  }
  return sort(ps);
}


void main() {
  registerLanguage("Flint", "flint", start[Main](str src, loc org) {
    return parse(#start[Main], src, org);
  });
  
  contribs = {
    annotator(Tree(Tree pt) {
      if (start[Main] f := pt) {
        <hlinks, msgs, docs> = resolve(f);
        errs = { m.msg | m <- msgs, m is error };
        for (e <- errs) {
          println("Error: <e>");
        }
        //for (Message m <- msgs, m is warning) {
        //  println("Warning: <m.msg>");
        //}
        return pt[@hyperlinks=hlinks][@messages=msgs][@docs=docs];
      }
      return pt[@messages={error("BUG: not a spec", pt@\loc)}];
    }),
    outliner(flintOutliner), 
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
