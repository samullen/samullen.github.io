---
layout: post
title: Test Driven Development and the Lowest Common Denominator
date: 2009-12-31
post: true
categories: [development, ruby, tdd]
---

I am, admittedly, new to testing my code. Let me clarify that: I am, admittedly, new to using a formal method of testing of my code. Every programmer tests their code in some manner or other, but it seems only recently that test driven development (TDD) has become popular. Personally, I blame Kent Beck and the whole "[Extreme Programming](http://en.wikipedia.org/wiki/Extreme_programming)" movement brought about by his book, [Extreme Programming Explained](http://www.amazon.com/gp/product/0321278658?ie=UTF8&tag=dumpgrou-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321278658). I've begun using a testing suite not because I've drunk the TDD kool-aid, but rather because I have begun to see it as a formalized methodology of what I have always done.

Let me explain what I mean: Because no one is perfect, we are all forced to test our work in some manner. For the longest time, I would perform a number of actions to test whatever it is I'm working on. I often cut and paste a snippet of code into a script or an interactive shell; I might use a foo.rb script to source libraries and call methods or print variables which I would later overwrite, comment out, or whatever as need be; oftentimes I'll just try running the application and seeing if it works; you can check logs and core dumps; and of course, there is the ubiquitous 'print', 'printf', 'puts', 'alert', etc.

The main problem I've found with the various means I've used to test in the past is the temporal nature of the tests - I always delete the files or code bits when I'm through with them - which I inevitably want back once I've deleted them. And so I've come to the point where I'm desirous of a formalized (and permanent) method of testing. It's not because I've read a book, heard a compelling argument, or even because everyone in the land of Ruby is doing it. I'm taking this path because it's the most practical choice. TDD is really just the natural progression of what we've always done.

When I first came to this conclusion (using TDD), and after reading several articles on the matter, I decided to use [RSpec](http://rspec.info) for my testing framework. However, I have since rethought that decision and have decided to stay with Test::Unit. Don't get me wrong, I think RSpec is really a brilliant framework. I know there are people out there that can't stand it, but for being one of the first DSLs ([Domain Specific Language](http://en.wikipedia.org/wiki/Domain_specific_language)) for testing, they really nailed it and its developers should be applauded rather than criticized for the work (it's just that the latter is so much easier).

I've settled on Test::Unit simply because it's the lowest common denominator. Regardless of who installs my projects on what platform or for what version I can be confident knowing that Test::Unit is there because it's part of the standard library. I can't be sure that RSpec, [Cucumber](http://cukes.info/), [shoulda](http://github.com/thoughtbot/shoulda), or any of the others will be, and I don't feel right asking that they be installed just to run my tests. Furthermore, Test::Unit is compatible with all of the testing DSLs just mentioned (it ought to be, they're built off of it).

* "lt's fully compatible with your existing tests, and requires no retooling to use" -- thoughtbot (shoulda)
* "You can use the familiar Test::Unit assert methods..." -- Aslak Hellesøy (cucumber)
* "Did you know that rspec is interoperable with test/unit?" -- David Chelimsky (RSpec)

Am I being a little extreme in this? Probably. Did this really deserve a blog post about it? Probably not. Is this a permanent choice? Until another library is standardized upon. Do I think you should choose Test::Unit too? No, I really don't care; I want people to use what makes them the most productive. This was really just an exercise in understanding why I've made the choice I have.

**Update 20120404**: Mmm, no. For Rails I now use Rspec and Cucumber. If I'm
building gems, I use Minitest. Not sure what I was smoking when I wrote this
post.
