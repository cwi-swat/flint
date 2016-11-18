

//relation sendInvoice: monthly [landlord] has the power towards [tenant] to [send] [invoice]
// when
//   lease(actor, receiver, amount)
//   and 
//   (not(sent(_, _, _) or
//   (sent(t, actor, receiver)
//   and isNotSamePeriod(t, x))))
// action():
//   + sent(now, actor, receiver, amount)
// {}

- time varying facts and querying over it (e.g., payments)
- bot: virtual power exerciser/button pressor
- separating concerns: policy/workflow (immediate exercise/periodical/...), 
  calculation language, API/database mapping, etc., data schema/ontology (check rules against data)
  why: isolate the aspect that would compromise reasoning (what-if/scenario exploration etc.)
- time related validity/applicability
- "macros" for defining "abstract"/composite duties/powers (part of)
- module system (versioning/copy-on-write)

 
Solvable
- execute
- explain: why do I have this power
- tracing

Todo:
- backwards reasoning: what do I need to do to achieve X


  
  
  
  
