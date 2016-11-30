sum([], 0).
sum([X|Xs], N) :- sum(Xs, N0), N is N0 + X.

taxDebt(Payer, Amount) :- salary(Payer, Salary, Trace28), Trace29 = [salary(Payer, Salary, Trace28)|Trace28], Total is 'UNSUPPORTED: sum(n | payment(_, payer, n))', Amount is (Salary * 0.45) - Total.

:- dynamic payment/3.

:- dynamic salary/2.

hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay', TRACE) :-
  classify('taxpayer', ACTOR),
  classify('inspector', RECV),
  classify('taxes', OBJ),
  Trace29 = [],
  taxDebt(ACTOR, Amount, Trace29), Trace30 = [taxDebt(ACTOR, Amount, Trace29)|Trace29], Amount > 0, Trace31 = [Amount > 0|Trace30],
  TRACE = Trace31.

executePower(payTaxes, ACTOR, RECV, 'pay', OBJ, [Amount]) :-
  hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay', _),
  get_time(NOW),
  assert(payment(NOW, ACTOR, Amount)).

VerschuldigdeBedragIsBepaald(Amount) :- belastingEindheffingsbestanddelen(X, Trace31), Trace32 = [belastingEindheffingsbestanddelen(X, Trace31)|Trace31], belastingVergoedingenEnVerstrekkingen(Y, Trace32), Trace33 = [belastingVergoedingenEnVerstrekkingen(Y, Trace32)|Trace32], belastingToeslagen(Z, Trace33), Trace34 = [belastingToeslagen(Z, Trace33)|Trace33], Amount is (X + Y) - Z.

CorrectAangifteGedaan() :- VerschuldigdeBedragIsBepaald(Trace34), Trace35 = [VerschuldigdeBedragIsBepaald(Trace34)|Trace34].

salary('tijs', 40000).

salary('robert', 80000).

classify('inspector', 'tom').

classify('taxpayer', 'tijs').

classify('taxpayer', 'robert').

classify('taxes', 'taxes').