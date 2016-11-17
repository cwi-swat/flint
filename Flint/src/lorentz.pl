sum([], 0).
sum([X|Xs], N) :- sum(Xs, N0), N is N0 + X.

taxDebt(Payer, Amount) :- 
  salary(Payer, Salary), 
  findall(N, payment(_, Payer, N), LIST), sum(LIST, Total), 
  Amount is (Salary * 0.45) - Total.

:- dynamic payment/3.

:- dynamic salary/2.

hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay') :-
  classify('taxpayer', ACTOR),
  classify('fiscus', RECV),
  classify('taxes', OBJ),
  taxDebt(ACTOR, Amount), Amount > 0.

executePower(payTaxes, ACTOR, RECV, 'pay', OBJ, [Amount]) :-
  hasPower(payTaxes, ACTOR, RECV, OBJ, 'pay'),
  get_time(NOW),
  assert(payment(NOW, ACTOR, Amount)).

salary('tijs', 40000).

salary('markus', 80000).

classify('fiscus', 'fiscus').

classify('fiscus', 'fiscus2').

classify('taxpayer', 'tijs').

classify('taxpayer', 'markus').

classify('taxes', 'taxes').