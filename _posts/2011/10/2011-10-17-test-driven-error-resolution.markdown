--- 
title: Test Driven Error Resolution
date: 2011-10-17
comments: false
post: true
categories: [tdd, bdd, cucumber, ruby on rails, rspec]
---
If you've been developing with [Ruby on Rails](http://rubyonrails.org/) for any length of time, you are no doubt familiar with Test Driven Development (TDD). You can use TDD in other languages - and I would encourage you to do so - but no other community I'm familiar with puts nearly as much emphasis on testing as the Ruby community. If you are unfamiliar with the concept, I invite you to check out the references in the "Further Reading" section below.

Assuming you are familiar, then you know the drill:

1.  Write a test and watch it fail
2.  Write just enough code to make the test pass
3.  Refactor your code
4.  Repeat until your feature is complete

That's a general summary of TDD and it's where most articles end, but that leaves one crucial step out.

The part left out is what happens after you have deployed your product. TDD is a great methodology and it aids us in thinking through the problems we are trying to solve as well as reducing the number of errors in our product, but as they say, there are no silver bullets. We make mistakes, we misunderstand the client's needs, we don't account for how the user will use our application, and sometimes we just miss something. When that happens, errors arise.

When the inevitable error occurs you just tweak the "write a failing test" portion (Step 1) of the TDD cycle. Something is already failing, so you write your test to duplicate that failure. If you receive a notification that logins fail when users have "dash" character in their email address, then write a test which attempts to login in with an email containing a "dash" character.

After that, it's TDD as normal. And so our new process looks like this:

1.  Write a test duplicating an error and watch it fail
2.  Write just enough code to make the test pass
3.  Refactor your code
4.  Deploy your fix

This is no great revelation, but oftentimes in our hurry to solve the immediate problem we forget, or lay aside, best practices. Don't fall into that trap. Squash the bug, but do it with tests.

### Further Reading
* [A Guide to Testing Rails Applications](http://guides.rubyonrails.org/testing.html)
* [Introduction to Test Driven Development (TDD)](http://www.agiledata.org/essays/tdd.html)
* [Test Driven Development](http://c2.com/cgi/wiki?TestDrivenDevelopment)
* [Guidelines for Test Driven Development](http://msdn.microsoft.com/en-us/library/aa730844(v=vs.80\).aspx)
* [Extreme Programming Explained](http://www.amazon.com/gp/product/0321278658/ref=as_li_ss_tl?ie=UTF8&amp;tag=dumpgrou-20&amp;linkCode=as2&amp;camp=217145&amp;creative=399369&amp;creativeASIN=0321278658) (Amazon link)
