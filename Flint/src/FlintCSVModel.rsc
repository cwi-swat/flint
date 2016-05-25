module FlintCSVModel

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

alias SitNormRel = rel[
str \type, // 0
str code, // 1
str juriconnect, //2
str source, // 3
str text, // 4
str dutyOwner, //5
str claimrightOwner, //6
str libertyOwner, // 7
str noRightOwner, // 8
str object, // 9
str dutyClaimRight,// 10
str libertyNoRight, // 11
str refs, // 12
str comments, // 13
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


alias SitNorm = tuple[
str \type,
str code,
str juriconnect,
str source,
str text,
str dutyOwner,
str claimrightOwner,
str libertyOwner,
str noRightOwner,
str object,
str dutyClaimRight,
str libertyNoRight,
str refs,
str comments
];


alias SitNormRelCore = set[SitNorm];

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

alias FactEnv = map[str code, str name];



