---
title: "Unit Testing in Swift"
description: "An introduction to testing in Xcode using swift and focusing on unit tests"
date: 2014-09-23
comments: false
post: true
categories: [testing, swift, ios]
---

## Introduction

With the advent of the [Extreme Programming movement](http://www.extremeprogramming.org), Test Driven Development (TDD)
has become more commonplace in development shops. Some development communities
place a higher value on TDD than others, and it's heartening to see a greater
emphasis beginning to be placed on it in the Mac and iOS communities.

Apple has apparently taken notice of this as well and in Xcode 6, tests are
included in every project by default, rather than as an afterthought or as
something you need to explicitly add. The assumption being is that you *will* be
testing.

## Why Should You Test?

I usually answer this question by using the metaphor of the human nervous system
- the part that detects pain. In the same way that our nervous system lets us
know when we get injured, tests, once written, can inform us when something
within our application breaks. (Read more: [Tests are Pain](//samuelmullen.com/2011/12/tests-are-pain/))

Although practicing good TDD helps us write better code, its primary purpose is
to allow us to refactor with confidence later on in a project's life. When we
break something during that process, our tests let us know.

Of course there are many other reasons to test first, but the other big reason
is that it forces us to really think about what actually needs to be done and
break it down into as simple of pieces as possible.

## Types of Tests

There are arguably (and I mean that quite literally) three types of tests you
can write: 

* **Unit tests:** What we're dealing with in the remainder of this article.
  These tests evaluate a "unit" of code (usually a method or function) in
  isolation from the rest of the application. Interaction with external classes,
  methods, etc. "should" be stubbed out.
* **Integration tests:** Whereas unit tests are written in isolation,
  integration tests test how those units interact with one another and within
  the project.
* **Acceptance tests:** These test have historically been performed by an end
  user, but they can (and should) be automated as much as possible. The purpose
  for acceptance tests is to ensure the end-to-end functionality of an
  application; from interface to persistence.

If you are new to testing, you will find the lines between the types of tests -
particularly between unit and integration tests - are easily blurred. Don't
worry about getting things perfect in the beginning, go ahead and [write crummy code](//samuelmullen.com/2012/05/why-its-okay-to-write-crummy-code/).

## Your First Test

Let's look at an example of writing tests, watching them fail, and then making
them pass. Then, once everything works we can refactor and make the code better.
We'll use the "FizzBuzz!" game as our example. If you're not familiar with this
"game", the rules are simple: 

> Write a program that prints the numbers from 1 to 100. But for multiples of
> three print “Fizz” instead of the number and for the multiples of five print
> “Buzz”. For numbers which are multiples of both three and five print
> “FizzBuzz”.

### Step 1: Create a new project

To begin, let's create the project "FizzBuzz" from the "Single View
Application" template. Once created, open the `FizzBuzzTests.swift` file in your
editor. It should look like this:

``` swift
import UIKit
import XCTest

class FizzBuzzTests: XCTestCase {

  override func setUp() {
    super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testExample() {
    // This is an example of a functional test case.
    XCTAssert(true, "Pass")
  }

  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock() {
      // Put the code you want to measure the time of here.
    }
  }

}
```

All newly created test cases have the same boilerplate. The `setUp` function is
run before every test you create. Likewise, the `tearDown` function is run after
every test. These two methods are useful to set up the environment needed by your
tests and clean up after the tests have run.

Next we see the `testExample`, a template for a standard test. Note that all
tests you write must begin with "test" and return an empty tuple (the default
return value in Swift).

The last function is a performance test. "A performance test takes a block of
code that you want to evaluate and runs it ten times, collecting the average
execution time and the standard deviation for the runs." We'll look more at
performance tests in a later post.

Let's write out first tests.

### Step 2: Write the tests (Red)

Go ahead and delete the boilerplate code and replace it with the following:

``` swift
import UIKit
import XCTest

class FizzBuzzTests: XCTestCase {
  var fizzbuzz: FizzBuzz!
  
  override func setUp() {
    super.setUp()
    
    self.fizzbuzz = FizzBuzz()
  }
  
  func testCheck_returnsFizzBuzz() {
    XCTAssertEqual(self.fizzbuzz.check(15), "FizzBuzz!")
  }
  
  func testCheck_returnsFizz() {
    XCTAssertEqual(self.fizzbuzz.check(9), "Fizz!")
  }
  
  func testCheck_returnsBuzz() {
    XCTAssertEqual(self.fizzbuzz.check(10), "Buzz!")
  }
  
  func testCheck_returnsNumber() {
    XCTAssertEqual(self.fizzbuzz.check(11), "11")
  }
}
```

Here, we're using the `setUp` method (purely for example), and have four tests
for the possible outputs. 

All tests must begin with the word "test", but how you name the remainder of it
is up to you. I currently name tests by the method I'm testing, if it's testing
success or failure (optional), and the expected return value.  In the above
tests, you could read it as, "test the check method that it returns 'FizzBuzz'".

Go ahead and run the test using Product -> Test (&#8984;U) in Xcode. It should
fail on every test with errors (not failures).

### Step 3: Make the tests pass (Green)

No one likes a failure, so let's start making our tests pass.

We can fix the first two errors (not failures) just by creating the `FizzBuzz`
class: File -> New -> File... (&#8984;N). From "iOS", select "Source", and then
select "Swift File" and click "Next". 

<img src="//samuelmullen.com/images/unit_testing_in_swift/new_swift_file.png" class="img-thumbnail img-left">

When given the dialog to save the file, choose "FizzBuzz" and select
"FizzBuzzTests" as an additional target, and click "Create".

<div class="clearfix"></div>

<img src="//samuelmullen.com/images/unit_testing_in_swift/save_as.png" class="img-thumbnail img-left">

<div class="clearfix"></div>

Now we can create the class.

``` swift
import Foundation

class FizzBuzz {
}
```

&#8984;U and we're two errors down.

We can eliminate the rest of the errors by adding the `check` method.

Our tests are expecting a `String` return value, so we'll return the number
which is passed in; this has the added benefit of making at least one test pass.

``` swift
func check(number: Int) -> String {
  return "\(number)"
}
```

Now we just need to make the remaining tests pass. Here's our initial product:

``` swift
import Foundation

class FizzBuzz {
  func check(number: Int) -> String {
    if number % 3 == 0 && number % 5 == 0 {
      return "FizzBuzz!"
    }
    else if number % 3 == 0 {
      return "Fizz!"
    }
    else if number % 5 == 0 {
      return "Buzz!"
    }
    else {
      return "\(number)"
    }
  }
}
```

Hit (&#8984;U) again, and all the tests should pass. 

It's a good first attempt.  All of the tests are green, but we're still not done.

### Step 4: Make the code better (Refactor)

Although the code works well enough, it feels very "C-like". We can make it more
"Swift-like" by plugging in the FizzBuzz code from the [Patterns Playground](https://developer.apple.com/swift/blog/?id=13):

``` swift
class FizzBuzz {
  func check(number: Int) -> String {
    switch (number % 3, number % 5) {
    case (0, 0):
      return "FizzBuzz!"
    case (0, _):
      return "Fizz!"
    case (_, 0):
      return "Buzz!"
    case (_, _):
      return "\(number)"
    }
  }
}
```

Run the tests again, and we're still green. We *refactored* the code, so only the
internals of the function changed, not the interface. Remember, "refactoring
is a disciplined technique for restructuring an existing body of code, altering
its internal structure without changing its external behavior." (Martin Fowler)

This is the general pattern of TDD: Red, Green, Refactor. If you're new to TDD,
writing code in this manner (i.e. tests first) will seem more than a little
awkward. There will be times you get stuck trying to figure out how to write
tests for the code you've already figured out, and other times when you're just
not in the right frame of mind to mess with it. My advice is to skip testing for
a little while to get over the roadblock, but continue to come back to it.
You'll find TDD becomes easier and more intuitive with practice.

## Troubleshooting

### Where's the XCTest API Documentation?

Great question. I've not been able to find the XCTest API in Xcode's
documentation, and neither has [Dash](http://kapeli.com/dash). The best I've
been able to do is find the [complete list of XCTest assertions](https://developer.apple.com/Library/ios/documentation/DeveloperTools/Conceptual/testing_with_xcode/testing_3_writing_test_classes/testing_3_writing_test_classes.html#//apple_ref/doc/uid/TP40014132-CH4-SW35)

### Missing Target

If you see errors stating that the `FizzBuzzTest` failed with the use of an
undeclared type 'FizzBuzz', chances are you don't have the `FizzBuzz` class set
up with `FizzBuzzTests` as a Target. This is an easy fix.

First, select `FizzBuzz` from the project Navigator:

<img src="//samuelmullen.com/images/unit_testing_in_swift/project_navigator.png" class="img-thumbnail img-left">

<div class="clearfix"></div>

Next, make sure `FizzBuzzTests` is checked under "Target Membership".

<img src="//samuelmullen.com/images/unit_testing_in_swift/target.png" class="img-thumbnail img-left">

Run the tests again, and you should at least get some new errors.

<div class="clearfix"></div>

### Destroying the Environment

One of the "gotchas" I've run across using TDD with Xcode is the lack of
distinct environments. When you run your tests, they run against the same
environment you develop in, and so any persisted data you're using for
development may get mangled when you run your tests. It's not ideal, but you can
move the files around in your test's setups and teardowns.
