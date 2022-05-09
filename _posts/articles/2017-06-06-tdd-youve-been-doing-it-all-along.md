---
title: "TDD: You've Been Doing It All Along"
description: "Lots of developers wrongfully malign TDD, piling on countless arguments against it. What they don't realize is they're doing TDD; they're just not reaping any of the rewards."
author: "Samuel Mullen"
tags: ["tdd","testing","programming"]
date: "2017-06-06T12:24:36-05:00"
---

Most people don't *get* TDD the first (or second, or third, or fourth) time
they're introduced to the concept. It's not a topic that is taught in university
and it's not practiced in most development teams. It's an altogether foreign
idea which goes against our sensibilities, prompting us to ask questions like:

* Why would I want to write twice as much code for the same results?
* Why do I need to write a program to tell me what I can plainly see?
* I'm already behind schedule. Why should I spend time I don't have writing code that's not even part of the project?

Even Kent Beck, TDD's "re-inventor", didn't get it at first:

> [@samullen](https://twitter.com/samullen) First time I heard of it was when I (re-)invented it. I laughed out loud. Seemed absurd but worth a try.
> &mdash;Kent Beck ([@KentBeck](https://twitter.com/KentBeck)) [May 23, 2017](https://twitter.com/KentBeck/status/867023350627008512)

Clearly TDD isn't a concept which seems reasonable to developers at first, nor
is it a technique which comes naturally to us. Or is it?

## TDD Overview

At its simplest, Test Drive Development (TDD) is a technique used to build
software by *first* writing tests describing what the code should do and *then* writing only the code necessary to make the tests pass.

Martin Fowler describes the process like this:

> * Write a test for the next bit of functionality you want to add.
> * Write the functional code until the test passes.
> * Refactor both new and old code to make it well structured.
>
> —Martin Fowler [TestDrivenDevelopment](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

More can be said about the process (and has), but that is the core of TDD.

## Non-TDD Overview

The "Non-TDD" development process is what most of us begin using from day one. There is nothing formal about it and there's definitely nothing automated. There is a problem and we create a solution for that problem according to our understanding at the time. If you were to codify the process, it would look like this:

* Determine the expectations for the next bit of functionality to add
* Write the functional code until it meets your expectations
* Tweak as necessary as you better understand the problem

Maybe we could add more steps to the process, but this is what most developers
begin using in their careers, and what most continue to use.

## You're Already Doing TDD

If you look closely at the two processes—and maybe squint a little—you'll see that they're nearly identical.

<table class="table">
<tr>
  <th>Development Step</th>
  <th>TDD</th>
  <th>Not TDD</th>
</tr>
<tr>
  <th>Determine Results</th>
  <td>Create test to prove results</td>
  <td>Expect specific outcomes</td>
</tr>
<tr>
  <th>Write Code</th>
  <td>Complete when tests pass</td>
  <td>Complete when results meet expectations</td>
</tr>
<tr>
  <th>Cleanup</th>
  <td>Refactor new and existing code</td>
  <td>Refactor new code. Fix any noticed errors in existing code</td>
</tr>
</table>

While each technique goes about the steps differently, they are the same steps.
If there is any hard difference between the two techniques, it's that one stores
the expectations for future use. And it's *that* difference that makes all the
difference.

Just look at the advantages that come with storing your expectations (i.e. tests) for future use:

* **Automation**: By storing a collection of tests, it's a simple matter to
  automate the process of verifying that everything in the code still works.
  Most languages even have a tool that can watch for changes and run the test
  suite automatically.
* **Consistency**: To ensure a block of code meets expectations, every potential
  outcome needs to be tested. You'll inevitably miss a step if you do that
  manually, but keeping a storehouse of tests ensures that code is tested the
  same way every time.
* **Comprehensiveness**: As tests are created and stored, the entire codebase
  will eventually be covered. This allows us to see errors or problems
  *anywhere* in the project resulting from changes *anywhere else* in the
  codebase.
* **Confidence**: When your project is covered by a suite of tests, it gives you
  the confidence to make changes. Because with any change, your tests will tell
  you what broke.

And those are just the advantages that come with storing a collection of tests. Let's look at the benefits that come with the intentional practice of TDD.

## Benefits of TDD

TDD is no silver bullet. Many articles would have you believe that by practicing
TDD, your code will magically become clean, you'll intuitively practice
[SOLID](https://en.wikipedia.org/wiki/SOLID_(object-oriented_design))
principles, and you will work harder. It doesn't work like that. TDD is just a
technique. While adhering to the technique makes some bad practices more
difficult, it doesn't make them impossible, and it certainly won't turn you into
a "rock star" developer.

What you *will* find by practicing TDD is that you are forced to really think
through the API of your code. When you write tests first, you are attempting
to use the code before it's even written, and by doing so you are asking, "How
would the interface work best?" As you answer that question, you'll find it's
easiest to answer with simple methods and functions. Simpler code is easier to
test.

Not only will you find it easier to write simpler code, but you will also write
less code. Too often we, as developers, write code against what *might* be
needed. We're not trying to over-engineer the code, we're just trying to
anticipate. Unfortunately, this often leads to excessive, unused, or even
unnecessary code. Code which must now be maintained.

By first specifying the expectations with tests, we are constrained to code
against those expectations. There is no opportunity to over-engineer the code,
because the expectations—real or imagined—don't exist.

Not only do the tests force you to think through the interface of your API and write code specifically to address those needs, they also document the behavior of the API. Look at this example:

```ruby
describe "User#name" do
  it "returns first and last names joined with a space" do
    contact = Contact.new(first_name: "User", last_name: Example")
    contact.name.must_equal "User Example"
  end

  it "returns the first name if the last name is blank" do
    contact = Contact.new(first_name: "User")
    contact.name.must_equal "User"
  end

  it "returns the last name if the first name is blank" do
    contact = Contact.new(last_name: "Example")
    contact.name.must_equal "Example"
  end
end
```

You don't need to know Ruby to read the code above. The first line tells us that we are looking at the instance method `name`. Each "it" line, tells us what `name` is supposed to do in the given scenarios. We don't have to read the code, we can read the actual requirements in our language of choice.

Developers notoriously hate writing documentation. Even when we do write it,
we usually fail to maintain it. As they say, "Wrong documentation is worse than
no documentation." Writing tests provides an almost effortless way of
documenting our code.

Let's look at some hard numbers. In a Microsoft funded research paper, authors [Nagappan, Maximilien, Bhat, and Williams](https://www.microsoft.com/en-us/research/wp-content/uploads/2009/10/Realizing-Quality-Improvement-Through-Test-Driven-Development-Results-and-Experiences-of-Four-Industrial-Teams-nagappan_tdd.pdf) discovered that TDD resulted in an increase of 15-30% in initial development time, but a 40-90% decrease in defects. As one author noticed:

> It is interesting to note that the figure of 15-30% longer during the coding phase. Then, the testers found 40-90% fewer bugs. That's 40-90% fewer bugs that need fixing. Now, these bugs that need fixing were found in the functional testing phase. Exact figures will vary, but it is frequently observed that bugs found here will take at least 10 times longer to fix than had they been found during development.
>
> ––  John Ferguson Smart [For A Fistful of Dollars](https://dzone.com/articles/fistful-dollars-quantifying)

Furthermore, Matt Hawley collated the benefits and results of several research papers in his article [TDD Research Findings](https://weblogs.asp.net/mhawley/114005) and provided the following list:

* 87.5% of developers reported better requirements understanding.
* 95.8% of developers reported reduced debugging efforts.
* 78% of developers reported TDD improved overall productivity.
* 50% of developers found that it decreased overall development time.
* 92% of developers felt that TDD yielded high-quality code.
* 79% of developers believed TDD promoted simpler design.

These findings are great if you are making a case to management to allow you and your team to start practicing TDD, or even if you're just participating in an internet debate. But the real benefit of TDD is summarized by "Uncle" Bob Martin in his answer to a question on Quora:

> If you follow TDD, and use it to build a test suite that you trust.  And if that test suite executes in seconds (a design goal).  Then you will not be afraid of the code.  You will not be afraid to clean it.  You will not be afraid to fix it.  You won't be afraid to do anything to the code, because your tests will tell you if you've broken it.
>
> —Uncle Bob Martin (https://www.quora.com/What-are-the-benefits-of-TDD)

## Getting Started

For the sake of argument, let's pretend that what I've written has persuaded you to take that first step into Test Driven Development. Where do you begin? And what can you do to make that transition smoother?

### Use Your Language's Built-in Testing Library

Because everyone has their own opinions about how testing *should* be done, multiple testing frameworks—each with their own API—are available for every language. While having this variety is great, most TDD adherents recommend learning the testing library that comes with your language. The reason for this is this are four-fold:

1. That library will always be available to fall back on
2. Most non-standard libraries are built upon those from the standard library
3. Knowing the foundational library allows you to learn the alternatives more easily
4. Most testing suites included in the standard library follow the same patterns across all languages.

### Start By Only Adding Tests to Code You Are Touching

Like most things, when you first start using TDD, you'll be tempted to start using it everywhere, even on code you're not currently working on. Although this isn't necessarily a bad thing, remember that you still have work to perform and the existing code works. Instead, focus on adding tests to the code you're actively working with.

As new features are requested, or as bugs are found, you'll eventually touch more and more of the system. As you do, your test coverage will slowly expand to cover everything.

### Be Prepared to Throw Your First Tests Away

Your first tests are going to be rubbish. They'll tests too many things in one go; You'll tests things that don't need to be tested; You'll touch parts of the system that shouldn't be touched; and you'll just make it harder on yourself than you need to. That's part of the process. You don't know where boundaries are or how to do things the "right" way and your initial tests will be you figuring that out.

That's okay. That's part of learning. Just be prepared to laugh at six-months-ago-you and replace those initial tests with what you've learned.

### Skip the Hard Stuff

Not everything in TDD is as easy as `assert User.name() == "Joe Bagadonuts"`.
Sometimes figuring out how to test something can be really hard, like
interacting with the network or even just `stdio`. Give it a good try to figure
out how to test something, but don't get trapped. You can always come back to
add tests later when you have a better understanding.

### Be Patient

Learning how to test isn't easy. You'll make mistakes, test the wrong things,
make things too complicated, and even question the value of testing in general.
Be patient with yourself and the process. It takes time. Learning always does.
You'll get the hang of it and you'll see the rest of your code improve as you
do.

Eventually, as your test suite grows, one of those tests is going to catch
something and everything's going to click. For me, it was when I came to a dead
end using a particular library. I knew the best choice was to switch
it out for something else, and it's only because I had a suite of tests that I
had the confidence to do so. That's when everything gelled.

## Stop Doing Things the Hard Way

As we saw at the beginning of the article, TDD and the "traditional" development
techniques both follow the same steps to meet their goals, but differ in what
they do with their expectations. With TDD, expectations are stored in the
project and become a suite of tests developers can use and refer to to ensure
the code continues to meet the expectations. With the less structured approach,
however, expectations are ephemeral, being stored in the developer's head, or in
one-off tests, only disappear into the void or be overwritten when the work is
"done".

But the work is never "done", and the customers' hunger for more features is never satisfied. Every developer eventually needs to revisit and make changes to code which was considered "done". Will you be able to confidently make changes to that code, knowing that you have a suite of tests to support you, or will you need to recreate the steps necessary to ensure it works? Will your tests tell you what breaks when you make changes, or will your customers?

At first blush, it may seem like TDD is only piling work onto your plate. After
all, you need to learn a new API, new programming practices, and change your
mindset. But as your test suite expands and more and more bugs are caught you
will find yourself becoming more productive than ever, and you'll come to wonder
how you ever managed to release code to production before.
