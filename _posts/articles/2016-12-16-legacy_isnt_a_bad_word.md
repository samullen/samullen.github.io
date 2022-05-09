---
title: "\"Legacy\" isn't a Bad Word"
description: "There's a lot to hate about legacy code, but is it possible it's more good than bad? Find out what it is, why it's so hated, and how you can benefit from it."
author: "Samuel Mullen"
tags: [ "legacy", "programming" ]
date: "2016-12-16T20:03:26-06:00"
---

Legacy Code. If you're a programmer, you'll eventually have to deal with it. While a few who delight in immersing themselves in an unknown codebase, most approach legacy code in the same way we approach doctor visits: we put it off until the pain becomes unbearable.

In fact, your first thought about "legacy code" might be something like Michael Feathers' description of the phrase.

> The phrase strikes disgust in the hearts of programmers. It conjures images of slogging through a murky swamp of tangled undergrowth with leaches beneath and stinging flies above. It conjures odors of murk, slime, stagnancy, and offal. Although our first joy of programming may have been intense, the misery of dealing with legacy code is often sufficient to extinguish that flame.
> ― Michael C. Feathers, *Working Effectively with Legacy Code*

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/why_snakes.jpg" class="img-thumbnail img-responsive img-right" alt="Why did it have to be Legacy Code" title="Why did it have to be legacy code">

Maybe it's because as technologists our focus is always on what's next. New features allow us to experiment with new technologies and ideas. Maybe it's because working with legacy code doesn't feel like we're actively contributing to the project and our team. We're just minding the store. Or maybe the real problem is we're arrogant, thinking we've been sidelined with legacy work because our "idiot boss" doesn't recognize our true potential and ability.

You may have already guessed it, but I have a different perspective about legacy code. I think you should too.

What is Legacy Code?
==================

There are two primary definitions for legacy code: a literal definition and a more practical one.

The literal definition describes legacy code as code which is no longer supported,  either because the language itself or the technology it runs on are obsolete.

> Legacy code is source code that relates to a no-longer supported or manufactured operating system or other computer technology. The term was first used by Computer Scientist George Olivetti to describe code maintained by an administrator that did not develop the code.
> [Wikipedia - Legacy Code](https://en.wikipedia.org/wiki/Legacy_code)

While this is an accurate definition, it's not the on that immediately comes to mind. Michael Feathers provides a more practical definition:

> Code without tests is bad code. It doesn’t matter how well written it is; it doesn’t matter how pretty or object-oriented or well-encapsulated it is. With tests, we can change the behavior of our code quickly and verifiably. Without them, we really don’t know if our code is getting better or worse.
> ― Michael C. Feathers, *Working Effectively with Legacy Code*

Or more simply:

> Legacy code is simply code without tests.
> ― Michael C. Feathers, *Working Effectively with Legacy Code*

You may disagree with his definition, but consider the following: when code is covered by a suite of tests, it allows us to modify the code and easily determine what in our project is affected (i.e., what breaks). Without comprehensive testing, making changes can produce unexpected results in the code you're working with. It can also produce unexpected results in code elsewhere in the project.

Furthermore, poorly written code is not legacy code. If the code is easy enough to understand and modify, and if it has supporting tests, it's not legacy code. It just may not match your idea of what good code is.

Why is Legacy Code Bad?
===================

There is a lot of good that comes from legacy code. But before we can look at the good, we need to address the very real problems that come with along with it.

It's Complicated
--------------------

The first problem is also likely the most obvious: legacy code is complicated. It's complicated partly because we have no way of knowing – short of manual investigation – how the different pieces interact with one another, but it's also complicated because there is nothing standing in the way of logic creep.

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/warehouse.jpg" class="img-thumbnail img-responsive img-right" alt="inside a large warehouse" title="Where'd I put my GPS?">

Automated tests keep logic from growing out of control because the pain of writing the tests for such logic strongly encourages programmers to write smaller, more manageable and testable blocks of code. When there are no tests, however, it doesn't take much for a once simple method to balloon into several hundred lines of nested logic, guard clauses, and checks.

While computers have no difficulty navigating complex logic, humans are notoriously bad at it and even worse at keeping it all in their heads. It requires intense concentration and focus; unless the code is refactored as part of working with it, the human will likely fix it by adding yet another layer of logic. There's nothing stopping them.

It's Brittle
------------

As complexity grows and complications arise, we as programmers are forced to make provisions to ensure all the necessary dependencies are met. But with each new provision and dependency, the logic continues to grow and expand. It becomes increasingly more difficult to satisfy. Each change we make threatens to disrupt every piece of code that depends on that original logic. The result is very delicate and brittle software.

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/cavein.jpg" class="img-thumbnail img-responsive img-right" alt="cave in" title="See? Cuz' the ceiling was 'brittle'">

If the project had a comprehensive suite of tests, breaking changes would show up immediately. Without such coverage, however, errors from these changes may go unnoticed until they are discovered in production, with potentially disastrous effects. In many ways, determining how changes to the code base affect the entire system is like trying to determine if you are injured or sick without a sense of pain or discomfort. Automated tests act as a sort of nervous system for software.

It Slows Development
--------------------------

As you can imagine, working with overly complex code which is tightly coupled across the system slows development. It takes time to understand the code, to make the necessary changes, to ensure the changes work, and finally to ensure the changes don't break existing work.

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/tied_up.png" class="img-thumbnail img-responsive img-right" alt="indiana jones and dad tied up" title="Legacy code ties you up">

But the time it takes to make changes in the here and now is only a piece of the whole picture. It doesn't consider how those changes affect future development. Each new layer of complexity added now, only adds to the difficulty of making changes later.

<div class="clearfix"></div>

It's Demoralizing
-------------------

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/demoralizing.jpg" class="img-thumbnail img-responsive img-right" alt="corpse caught by trap" title="Doesn't he look demoralized?">

The final result is a demoralized development team. When you're faced with the daily challenge of only being able to make incremental changes through large amounts of effort, it wears you down. We need that virtuous cycle of successes – to see that progress is being made – in order to keep up morale. Andy Hunt and David Thomas described it like this:

> One broken window—a badly designed piece of code, a poor management decision that the team must live with for the duration of the project—is all it takes to start the decline. If you find yourself working on a project with quite a few broken windows, it’s all too easy to slip into the mindset of “All the rest of this code is crap, I’ll just follow suit.” It doesn’t matter if the project has been fine up to this point.
> — Andy Hunt and David Thomas, *The Pragmatic Programmer*

It's this final result that drags us down: that the changes and improvements we make don't matter.

The Truth About Legacy Code
=======================

Love it or hate it, the reality is legacy code isn't going anywhere. The truth is that for many companies, that legacy code is not only what got them where they are now, but what continues to bring in revenue and pay the bills. While we may turn up our nose at the pile of spaghetti code sitting in front of us, it's that spaghetti which feeds the business.

The Opportunity of Legacy Code
========================

The problem with legacy code is that it's complicated, brittle, demotivating, and it makes everything harder to do. But problems have solutions. Problems present opportunities.

The Opportunity to Add Value
----------------------------------

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/treasure_room.jpg" class="img-thumbnail img-responsive img-right" alt="Treasure room from National Treasure" title="Shhh. This is really the treasure room from National Treasure">

The first opportunity presented by legacy code is one immediately understood by management: improving legacy code adds value. Management doesn't always take developers at their word, but they're more likely to listen when it's combined with a  cost-benefit analysis. Show them how improving the existing code base can reduce hardware expenditures or mitigate the need for a new hire and you'll find them in your corner.

* **Improved Efficiency:** Improvements to speed are always a good thing. Faster page loads, data processing, batch processing, and other types of processing all lead to being able to do more with less. The key is to quantify the costs of the existing system (i.e., time/processing unit) against those of the proposed solution.
* **Reduced Development Costs:** The greatest expense in any IT department is
its staff. Reducing the complexity of the code base allows for greater
productivity from the development and operational staff – code complexity and
development productivity are inversely proportional. Maybe there isn't a need
for that new hire after all.
* **Improved Product Quality:** How expensive are errors? Can they affect
customer churn? Do they require staff to be on call? Do they slow progress? Do
they increase the need for support staff? How expensive are errors? How much more valuable are their absence?
* **Lowered Barrier to Entry:** How much time does it take to ramp up new hires?
How valuable would it be if they could hit the ground running because the
code base was readable and approachable? Instead, we often see new hires
sidelined for days or weeks trying to understand the tangled mess on their own
as they wait for someone to get free of a fire long enough to provide them
direction.

These are only four possible ways fixing legacy code adds values, but there are
many others. The great thing about fixing legacy code is that doing so usually
affects more than just one area.

The Opportunity to Learn
-----------------------------

At first glance, legacy code may appear to offer you nothing of value, but when
you dig deeper you will find that's simply not the case. Reading code, even bad
code, is one of the best ways to make huge strides in your progress as a
developer.

> ...we're fortunate to be in a profession where the knowledge and skill of all the masters is right there for us to absorb, embedded in the code they have written. All you have to do is read it...
> -- Alan Skorkin, *[Why I Love Reading Other People’s Code And You Should Too](http://www.skorks.com/2010/05/why-i-love-reading-other-peoples-code-and-you-should-too/)*

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/professor.jpg" class="img-thumbnail img-responsive img-right" alt="Indiana jones teaching" title="Someone should make a meme of Indiana Jones hitchhiking">

While the code base you're looking at may not place you at the "foot of the
masters", you are absolutely guaranteed to grow as you struggle to understand
it. Here is just a sampling of what is in store for you:

<div class="clearfix"></div>

* **Insider information:** The better you understand the code base you work
with, the better you will understand the system and business it supports. Not
only will this provide insight into why the business makes the decisions it
does, but it will allow you to provide greater value through deeper
understanding of the business.
* **New tricks from old code:** Sometimes it's a new method or library, or maybe
it's a programming technique you've never seen or used before. Whatever the
case, you'll always find something new in old code.
* **You're better than that:** Maybe the greatest advantage of fixing legacy
code is that it forces you to become better than the code you're fixing. First,
you must understand what it is you're fixing. Then, you must surpass it in skill
and creativity in order to improve it.

Learning requires humility. If you believe you have nothing to gain from the
code you are working on, I guarantee you'll prove yourself correct. I've done it
myself. I once inherited a code base from someone I thought to be inferior
in skill to myself. While there were many times I was able to improve upon his
code, there were an equal number of times when I tried to fix and replace the
code only to be met with failure and falling back to the original developer's
solution. It was a long and painful lesson, but I eventually learned from it and
am better for it.

If, like those with the growth mindset, you believe you can develop yourself, then you’re open to accurate information about your current abilities, even if it’s unflattering.
― Carol S. Dweck, Mindset: The New Psychology of Success

The Opportunity to Do What We Love
----------------------------------------

Why did you become a programmer? I doubt it was for the fame, and while we make
good money, only the mad would pursue this path for riches. So why did you?

<img src="//samuelmullen.com/images/legacy_isnt_a_bad_word/idol_swap.jpg" class="img-thumbnail img-responsive img-right" alt="Indiana jones swapping idol" title="Now I'll just swap out this piece of code for the new one...">

What drives us more than anything else is the need to solve problems,
and each problem we solve only feeds the desire to solve more. Who among us has
not felt the satisfaction of mastering a new language or framework. And who has
not felt the elation of conquering a problem which has plagued us for days or
weeks? Do we not also delight in seeing the complex replaced with the simple?

But these are not the daily experiences for most of us. In truth, the
programmer's day is spent completing work we're all too familiar with doing,
with skills and solutions we've used before. For most of us, it's only
occasionally that we are faced with interesting challenges.

Legacy code isn't like that. In legacy code, problems abound and many, while
already solved, need to be re-solved. It offers opportunities to solve problems,
but also challenges us to figure out how "this damned piece of code" works in
the first place. And when we do, it then opens the door allowing us to create.

Few areas in computer science offer us this much challenge and reward.

I don't want to mislead you; I don't approach every new day of working with
legacy code with excitement and anticipation. I don't always approach these
projects with humility and understanding for the previous team. Sometimes I even
dread it.

While I do not approach every day of working with legacy code with the same
level of enjoyment, I still recognize and give thanks for the part it's played
in my career. There's been no better guide or teacher.

> The passion for stretching yourself and sticking to it, even (or especially) when it’s not going well, is the hallmark of the growth mindset. This is the mindset that allows people to thrive during some of the most challenging times in their lives.
> ― Carol S. Dweck, *Mindset: The New Psychology Of Success*

