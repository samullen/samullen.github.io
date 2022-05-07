---
title: "Performance Testing in Xcode 6"
description: "An introduction to performance testing in Xcode using swift."
date: 2014-10-20
comments: false
post: true
categories: [testing, swift, ios, benchmarking, performance testing]
---

In [Unit Testing in Swift](//samuelmullen.com/2014/09/unit-testing-in-swift), we saw how
refactoring a method should keep us "green" without changing our API. In that
instance, our focus was to make the code more "swift-like", not more efficient.
For those occasions where increased speed is the goal, we need to have a
benchmark from which to work.

Many languages provide the ability to benchmark code, but in Xcode 6
benchmarking can become part of our test suite. Now when our refactoring
reduces efficiency, we're be notified through a failed test.

> A performance test takes a block of code that you want to evaluate and runs
> it ten times, collecting the average execution time and the standard
> deviation for the runs. These statistics combine to create a baseline for
> comparison, a means to evaluate success or failure.
>  
> -- iOS Developer Library: Writing Performance Tests

## Scenario

Let's use the first problem from [Project Euler](http://projecteuler.net) as an example of how this might work:

> If we list all the natural numbers below 10 that are multiples of 3 or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
> 
> Find the sum of all the multiples of 3 or 5 below 1000.

Calculating the answer will be very quick in Swift (see how deftly I avoided
that pun?); it's so easy we need to slow it down to get a more accurate
baseline and standard deviation. Let's change 1,000 to 1,000,000. (Note: If you
have to do this in an actual project, you *probably* don't need to worry about
performance.)

## Initial Test

In our first iteration, we'll, uh, iterate through all 1,000,000 numbers (well, 999,999, since it says "below") testing each number if it's a multiple of three or five, and then adding it to our total. Here's our initial attempt:

``` swift
class Euler() {
  func euler1() -> Int {
    var sum = 0
    
    for (var i = 1; i < 1000000; i++) {
      if i % 3 == 0 || i % 5 == 0 {
        sum = i + sum
      }
    }
    return sum
  }
}
```

The performance test is simple enough; we just need to instantiate our class and call our `euler` method in the `measureBlock`.

``` swift
func testEuler1Performance() {
  let e = Euler()

  self.measureBlock() {
    e.euler1()
  }
}
```

Running our tests in this, we'll see this flag:

<img src="//samuelmullen.com/images/performance_testing_in_swift/flag.png" class="img-thumbnail">

<img src="//samuelmullen.com/images/performance_testing_in_swift/set_baseline.png" class="img-thumbnail img-right">

Clicking on this "flag" will open up showing our initial stats and allowing us
to set a "baseline". By clicking "Set Baseline", we store the results of this
test. Any future refactorings we do on this method will then have to pass not
only our unit tests, but also must meet or exceed the performance measurements
we set.

## Refactor

We solved our first Euler problem, and that's great, but our solution's probably
not as performant as it could be. Let's take another crack at it.

Since we're only looking for multiples of three and five, there's really no need
to to test against any other number, so let's change our code to reflect that
understanding.

``` swift
func euler1() -> Int {
  var sum = 0

  for (var i = 3; i < 1000000; i += 3) {
    sum += i
  }

  for (var i = 5; i < 1000000; i += 5) {
    if i % 3 == 0 {
      continue
    }
    sum += i
  }

  return sum
}
```

Running our tests again, we see the results are markedly improved.

<img src="//samuelmullen.com/images/performance_testing_in_swift/new_flag.png" class="img-thumbnail">

<img src="//samuelmullen.com/images/performance_testing_in_swift/edit_baseline.png" class="img-thumbnail img-right">

We definitely want to save that and use it for our new baseline. Click on the
flag and then click "Edit". You'll see the this screen:

We just need to "Accept" to set the new baseline value, and then click "Save".
All future tests will be run against this value. If the method is refactored
again and produces worse results, the test will fail.

How many times have we heard other developers - because we would never do
somethign like this - justify a change because it "felt faster"? Just because a
refactoring "feels" faster doesn't necessarily mean it is. In order to truly
determine if our changes improve our code's efficiency we need to test it and
Xcode 6 provides the necessary tools to do just that. Now we can justify our
changes with facts, not feelings.
