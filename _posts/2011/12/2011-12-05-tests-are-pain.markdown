--- 
title: Tests are Pain
date: 2011-12-05
comments: false
post: true
categories: [testing, development, tdd]
---
Pain, really, is a wonderful thing. It's a protective mechanism in the body which alerts us to something going wrong. It may be as trivial as a paper cut or intense as a broken bone, but regardless, pain lets us know that all systems are not "go". Without pain, how would we know we had been injured or were sick? What kind of infections would we get because of unnoticed injuries? What risks might we take for lack of the fear of pain?

A computer program is kind of like a body which feels no pain. It doesn't notice when something hurts, it just doesn't work or it dies uttering some cryptic last words. If we're lucky we can do an autopsy on the results, fix the problem, and bring our creation back to life. If we're not, well, it may be a long night.

But what if there was a way to provide a sort of nervous system for your programs? A means of determining if a method would provide the correct results, and a way to know if your latest change affected something in another part of the program's body? What could you do with that knowledge? Would you feel more confident in the code you released, knowing that your program had no hidden injury? Would you be more comfortable making sweeping changes to refactor a major class or database schema knowing that your program would tell you if something was wrong? And wouldn't it be great to know about problems prior to pushing the "ship it" button?

What you want is a little pain. Tests are pain. That is, tests provide the same sort of mechanism in a program that pain provides in the body. If you couldn't feel pain, you might have to do a regular visual check over your body to make sure there were no new injuries. Without a suite of tests, you have to do that same sort of visual check over your application....your entire application...not just the happy path....every time you change something.

When I first heard about Test Driven Development (TDD), it offended my sensibilities: Why would you write twice as much code? Why run a test knowing it was going to fail and then write code to make it pass, that's backwards. It's going to slow down the development process soooo much.

I've been developing applications using TDD for about a year and a half now, and I can honestly say my sensibilities were just flat out wrong. Here's what I've found:

* There was quite a bit of pain to ramp up, but not the pain of something going wrong, it was the pain of growth.
* The initial development process has slowed down a bit because I'm writing tests, but the bugs have been drastically reduced, which means I'm spending more time developing and less time maintaining.
* I think about the actual problem more, because I'm defining the behavior I'm expecting before I do anything else.
* My code has become more modular, because its easier to test. This has the side effect of making better code.
* I'm only coding as much as is necessary, which means my programs aren't bloated unnecessarily.
* Lastly, I've performed major refactors on current code bases with full confidence that my changes were going to work. I've even refactored a user table from one database into another. Could you do the same without tests?

No one likes pain, but it does serve a purpose in our body. When we feel pain, we know that something is going wrong and we need to take care of it. Computer programs don't feel pain, but we can mimic the effects of pain with tests, and in doing so provide ourselves with greater confidence in our code.

As I alluded to, pain doesn't always involve injury, sometimes it's the result of growth. If you've not yet begun test driving your development, embrace a little pain and grow as a developer. Sometimes, "Pain is just weakness leaving the body."
