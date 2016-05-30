module FizzBuzz


import IO;

/*
 * Exercise 0 (warm-up): FizzBuzz 
 * (see http://c2.com/cgi/wiki?FizzBuzzTest)
 *
 * "Write a program that prints the numbers from 1 to 100. 
 * But for multiples of three print “Fizz” instead of the 
 * number and for the multiples of five print “Buzz”. For 
 * numbers which are multiples of both three and five print
 * “FizzBuzz”."
 *
 * Tip: [1..101] gives the list [1,2,3,...,100]
 * Tip: use println from IO to print.
 */
 
 
void fizzbuzz() 
  = println(( "" | it + (i%3==0 ? "Fizz" + (i%5==0 ? "Buzz\n" : "\n") : (i%5==0 ? "Buzz\n" : "<i>\n" )) | i <- [1..101] )); 
