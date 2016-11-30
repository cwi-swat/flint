sum([], 0).
sum([X|Xs], N) :- sum(Xs, N0), N is N0 + X.

taxDebt(Payer, Amount) :- salary(Payer, Salary, Trace21), Trace22 = [salary(Payer, Salary, Trace21)|Trace21], Total is 'UNSUPPORTED: sum(n | payment(_, payer, n))', Amount is (Salary * 0.45) - Total.

:- dynamic payment/3.

:- dynamic salary/2.

hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay', TRACE) :-
  classify('taxpayer', ACTOR),
  classify('inspector', RECV),
  classify('taxes', OBJ),
  Trace22 = [],
  taxDebt(ACTOR, Amount, Trace22), Trace23 = [taxDebt(ACTOR, Amount, Trace22)|Trace22], Amount > 0, Trace24 = [Amount > 0|Trace23],
  TRACE = Trace24.

executePower(payTaxes, ACTOR, RECV, 'pay', OBJ, [Amount]) :-
  hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay', _),
  get_time(NOW),
  assert(payment(NOW, ACTOR, Amount)).

VerschuldigdeBedragIsBepaald(Amount) :- belastingEindheffingsbestanddelen(X, Trace24), Trace25 = [belastingEindheffingsbestanddelen(X, Trace24)|Trace24], belastingVergoedingenEnVerstrekkingen(Y, Trace25), Trace26 = [belastingVergoedingenEnVerstrekkingen(Y, Trace25)|Trace25], belastingToeslagen(Z, Trace26), Trace27 = [belastingToeslagen(Z, Trace26)|Trace26], Amount is X + Y - Z.

CorrectAangifteGedaan() :- VerschuldigdeBedragIsBepaald(Trace27), Trace28 = [VerschuldigdeBedragIsBepaald(Trace27)|Trace27].

salary('tijs', 40000).

salary('robert', 80000).

classify('inspector', 'tom').

classify('taxpayer', 'tijs').

classify('taxpayer', 'robert').

classify('taxes', 'taxes').