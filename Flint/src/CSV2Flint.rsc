module CSV2Flint

import lang::csv::IO;
import String;
import List;
import IO;


str csvs2flint(bool english) {
  rels = readCSV(#GenNormRel, |project://Flint/IND%20-%20Generatieve%20Normative%20Relaties.csv|, separator=";");
  ifacts = readCSV(#IFactRel, |project://Flint/IND%20-%20iFEITen.csv|, separator=";");
  factSrc = ifacts2flint(ifacts, english=english);
  relSrc = genRel2flint((), rels, english=english);
  return "<factSrc>\n\n<relSrc>";
}

alias GenNormRel = rel[
str \type, // 0
str code, // 1
str juriconnect , //2
str source, //3
str text,//4
str actor,//5
str recipient, //6
str iAct, //7
str object, // 8
str pre, // 9
str postCreate, // 10
str postDelete, // 11
str refs, // 12
str comments, // 13
str typeEn,
str codeEn,
str sourceEn,
str textEn,
str actorEn,
str recipientEn,
str iActEn,
str objectEn,
str preEn,
str postCreateEn,
str postDeleteEn,
str refsEn,
str commentsEn
];


alias GenNorm = tuple[
str \type,
str code,
str juriconnect,
str source,
str text,
str actor,
str recipient,
str iAct,
str object,
str pre,
str postCreate,
str postDelete,
str refs,
str comments
];

alias GenNormRelCore = set[GenNorm];


alias FactEnv = map[str code, str name];

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


alias SitNormRel = rel [
str \type,
str code,
str juriconnect,
str source,
str text,
str dutyOwner,
str claimrightOwner,
str liberyOwner,
str noRightOwner,
str object,
str dutyClaimRight,
str liberyNoRight,
str refs,
str comments,
str typeEn,
str codeEn,
str sourceEn,
str textEn,
str dutyOwnerEn,
str claimrightOwnerEn,
str liberyOwnerEn,
str noRightOwnerEn,
str objectEn,
str dutyClaimRightEn,
str liberyNoRightEn,
str refsEn,
str commentsEn
];

alias IFactRel = rel[
str object,
str name,
str definition,
str juriconnect,
str source, 
str comments,
str objectEn,
str nameEn,
str definitionEn,
str sourceEn, 
str commentsEn,
str extra1,
str extra2,
str extra3,
str extra4,
str extra5,
str extra6,
str extra7
];


alias IFact = tuple[str object,
str name,
str definition,
str juriconnect,
str source, 
str comments
];

alias IFactRelCore = set[IFact];


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
