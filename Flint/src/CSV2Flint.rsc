module CSV2Flint

import lang::csv::IO;
import String;
import List;
import IO;
import FlintCSVModel;

str csvs2flint(bool english) {
  rels = readCSV(#GenNormRel, |project://Flint/IND%20-%20Generatieve%20Normative%20Relaties.csv|, separator=";");
  ifacts = readCSV(#IFactRel, |project://Flint/IND%20-%20iFEITen.csv|, separator=";");
  factSrc = ifacts2flint(ifacts, english=english);
  relSrc = genRel2flint((), rels, english=english);
  return "<factSrc>\n\n<relSrc>";
}


GenNormRel readGenNormRel() {
  return readCSV(#GenNormRel, |project://Flint/IND%20-%20Generatieve%20Normative%20Relaties.csv|, separator=";");
}


str genRel2flint(FactEnv env, GenNormRel genRel, bool english = false) {
  if (english) {
    return genRel2flintGen(env, genRel<14, 15, 2, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26>, genRel2flintEnglish);
  }
  return genRel2flintGen(env, genRel<0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13>, genRel2flintDutch);
}

str genRel2flintGen(FactEnv env, GenNormRelCore r, str(FactEnv, GenNorm) f) 
  = intercalate("\n\n", [ f(env, x) | x <- r ]);

str genRel2flintEnglish(FactEnv env, GenNorm r) {

  assert r.\type == "POWER-LIABILITY";
  
  //pre = ( r.pre | replaceAll(it, k, makeId(env[k])) | k <- env, bprintln("k = <k>") ); 
  
  return 
   "relation <r.code>: 
   '  <r.actor> has the power towards <r.recipient> to <r.iAct> <r.object>
   'when 
   '  <replaceAll(r.pre, "\r", "")>
   'action:<for (pc <- posts(r.postCreate), trim(pc) != "") {>
   '  + <pc><}><for (pd <- posts(r.postDelete), trim(pd) != "") {>
   '  - <pd><}>
   '";
}


list[str] posts(str posts) = [ replaceAll(p2, "\r", "") | p <- split("; ", posts), p2 <- split(" EN ", p) ];

str genRel2flintDutch(FactEnv env, GenNorm r) {

  assert r.\type == "BEVOEGD-GEHOUDEN";
  
  //pre = ( r.pre | replaceAll(it, k, makeId(env[k])) | k <- env ); 
  
  
  return 
   "relatie <r.code> :
   '  <r.actor> heeft de bevoegdheid jegens <r.recipient> tot het <r.iAct> van <r.object>
   'wanneer
   '  <replaceAll(r.pre, "\r", "")>
   'actie:<for (pc <- posts(r.postCreate), trim(pc) != "") {>
   '  + <pc><}><for (pd <- posts(r.postDelete), trim(pd) != "") {>
   '  - <pd><}>
   '";
}

SitNormRel readSitNormRel() {
  return readCSV(#SitNormRel, |project://Flint/IND%20-%20Situational%20Normative%20Relaties.csv|, separator=";");
}



FactEnv factEnvEnglish() = ( obj: x | <_,  _, _, _, _, _, str obj, str x, _, _,  _, _, _, _, _, _, _, _>  <- readIFactRel(), x != "" );
FactEnv factEnvDutch() = ( obj: x | < str obj, str x, _, _, _, _, _, _, _, _,  _, _, _, _, _, _, _, _>  <- readIFactRel(), x != "" );

IFactRel readIFactRel() {
  return readCSV(#IFactRel, |project://Flint/IND%20-%20iFEITen.csv|, separator=";");
}


str ifacts2flint(IFactRel ifacts, bool english = false) {
  if (english) {
    return ifacts2flintGen(ifacts<6, 7, 8, 3, 9, 10>, ifact2flintEnglish);
  }
  return ifacts2flintGen(ifacts<0, 1, 2, 3, 4, 5>, ifact2flintDutch);
}

str ifacts2flintGen(IFactRelCore ifacts, str(IFact) gen) 
  = intercalate("\n\n", [ gen(f) | f <- ifacts ]);
   
str ifact2flintDutch(<str obj, str name, str def, str juri, str src, str comments>)
  = "iFeit <obj>
    '  bron: <src>
    '  link: <juri><if (trim(name) != ""){>
    '  alias: <name><}>
    '{
    '  <wrap(def, 60)>
    '}";

str ifact2flintEnglish(<str obj, str name, str def, str juri, str src, str comments>)
  = "iFact <obj>
    '  source: <src>
    '  link: <juri><if (trim(name) != ""){>
    '  alias: <name><}>
    '{
    '  <wrap(def, 60)>
    '}";
    
str makeId(str x) = intercalate("", [elts[0]] + [ capitalize(e) | e <- elts[1..] ])
  when 
    list[str] elts := split(" ", x);
