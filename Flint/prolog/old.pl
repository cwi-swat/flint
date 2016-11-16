    
salaryOf(tijs, 30000.0).
taxRate(0.45).

taxDebt(Payer, Debt) :-
    salaryOf(Payer, Salary), % get the salary
    findall(X, payed(_, Payer, X), Amounts), % get all payments already done
    write('Amounts: '), writeln(Amounts),
    sum(Amounts, Total), % sum it into total
    taxRate(Rate),
    Debt is (Salary * Rate) - Total,
    write('Debt is now: '), writeln(Debt).

isFiscus(_).
isPayer(_).


has(power(pay, taxes, Payer, Fiscus)) :-
    isPayer(Payer), isFiscus(Fiscus),
    taxDebt(Payer, Debt), Debt > 0.
    
do(power(pay, taxes, Payer, Fiscus), Amount) :-
    has(power(pay, taxes, Payer, Fiscus)),
    get_time(T),
    write('Exercising power: '),
    writeln(payed(T, Payer, Amount)),
    assert(payed(T, Payer, Amount)).
    
        
