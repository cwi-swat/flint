sum([], 0).
sum([X|Xs], N) :- sum(Xs, N0), N is N0 + X.

taxDebt(Payer, Amount) :- salary(Payer, Salary, Trace4), Trace5 = [salary(Payer, Salary, Trace4)|Trace4], findall(N, payment(_, Payer, N, Trace5), Trace6 = [payment(_, Payer, N, Trace5)|Trace5], LIST), sum(LIST, Total), Amount is (Salary * 0.45) - Total.

:- dynamic payment/3.

:- dynamic salary/2.

hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay', TRACE) :-
  classify('taxpayer', ACTOR),
  classify('inspector', RECV),
  classify('taxes', OBJ),
  Trace6 = [],
  taxDebt(ACTOR, Amount, Trace6), Trace7 = [taxDebt(ACTOR, Amount, Trace6)|Trace6], Amount > 0, Trace8 = [Amount > 0|Trace7],
  TRACE = Trace8.

executePower(payTaxes, ACTOR, RECV, 'pay', OBJ, [Amount]) :-
  hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay', _),
  get_time(NOW),
  assert(payment(NOW, ACTOR, Amount)).

salary('tijs', 40000).

salary('robert', 80000).

classify('inspector', 'tom').

classify('taxpayer', 'tijs').

classify('taxpayer', 'robert').

classify('taxes', 'taxes').