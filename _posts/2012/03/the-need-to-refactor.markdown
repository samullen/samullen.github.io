---
title: "The Need to Refactor"
description: "A plea to companies to allow their development staff the opportunity and the time to refactor regularly."
date: 2012-03-19
comments: true
post: true
categories: [refactoring, technical debt, business, development, best practices]
---

When people hear the words "ceremony" and "tradition", their first thoughts usually involve religion. Of course it makes sense, all religions have some sort of tradition and ceremony, but while some of the traditions are prescribed, many have come about from some need or requirement. Those which have come about often continue on long after the requirement no longer exists. For example, the communion plates in most Christian churches are stacked and covered to keep the flies out. Flies have ceased to be a problem in our air conditioned mega-churches of the 21st century, but we continue to protect our crackers and grape juice from them nonetheless.

Businesses have ceremonies and traditions as well, only we call them "processes" and "systems". In the world of programming we call it "technical debt". Regardless of the name used, the only way to reduce what is unnecessary is by refactoring. [The best definition of refactoring](http://martinfowler.com/refactoring/) that I am aware of was provided by Martin Fowler:

> Refactoring is a disciplined technique for restructuring an existing body of code, altering its internal structure without changing its external behavior. Its heart is a series of small behavior preserving transformations. Each transformation (called a 'refactoring') does little, but a sequence of transformations can produce a significant restructuring. Since each refactoring is small, it's less likely to go wrong. The system is also kept fully working after each small refactoring, reducing the chances that a system can get seriously broken during the restructuring.

Businesses refactor all the time, but again the terms are different: "streamlining processes", "downsizing", "pivoting", and "reorg" are only a few examples. But in the world of programming, we don't always have the luxury of refactoring like we want, and we really want to.

When you refactor in business, there is usually some sort of immediate, "tangible" result: Suzy, Johnny, and Sally were axed so now our expenses are _x_ amount less. In programming, if I refactor a library of code, the end result may only be that I increase its readability. How do you quantify that? When it can't be quantified, refactoring is only seen as an expense and something to be avoided, and so the technical debt grows.

As alluded, the results of a refactoring are not always measurable. There are certainly instances which result in measurable improvements, but improvements such as increased performance are not always important. So why allow your development staff time to refactor?

Although "increased performance [is] not _always_ important", it oftentimes is. With increased performance and efficiency come reduced hardware requirements, translating into either lower expenses or greater output. If you have a website, it means a better user experience, greater retention, and increased revenues. Look at some of these [stats provided from Velocity 2009](http://radar.oreilly.com/2009/07/velocity-making-your-site-fast.html):

* [Bing](http://bing.com) - Bing found that a 2 second slowdown changed queries/user by -1.8% and revenue/user by -4.3%. Google Search found that a 400 millisecond delay resulted in a -0.59% change in searches/user
* [Google](http://google.com) - One experiment increased the number of search results per page from 10 to 30, with a corresponding increase in page load times from 400 milliseconds to 900 milliseconds. This resulted in a 25% drop-off in first result page searches.
* [Shopzilla](http://shopzilla.com) - A year-long performance redesign resulted in a 5 second speed up (from ~7 seconds to ~2 seconds). This resulted in a 25% increase in page views, a 7-12% increase in revenue, and a 50% reduction in hardware.

But application performance is only part of the picture, if your application or system has customers - and it does - then those customers are going to want the occasional change made or problems addressed. The time it takes to accommodate the request is proportional to the complexity of the system (i.e. the more complex the code, the longer it's going to take).

By providing your development staff time to refactor, you not only shore up an application's foundation, you reduce the cost of future development. In other words, decreased complexity equates to increased productivity, resulting in happier customers.

There is one more consideration with regard to encouraging regular refactoring, and if the truth were to be told, it's my whole motive for writing this post: working with code that has a high technical debt is miserable and it's a morale killer. When you know that each new feature request or bug fix that comes in will require sifting through years of spaghetti code, the sense of dread becomes palpable. Who wants to work in a system where any change, any minor tweak, could result in hours of bug hunts, shoring up crumbling foundations, and frustration? So developers avoid and procrastinate, and sometimes we start looking for a new job and a new system. 

I've worked in shops where management allowed the development staff to either completely rewrite or perform a massive overhaul on a system, and the immediate improvement in developer morale was dramatic. We began talking about work again, how to do things right, how to make it faster, we began caring about what the customer wanted again, and we weren't dreading coming to work each day.

Of course, I've also worked in shops where refactoring was too "expensive" for the company. It's one thing to "overhaul" a project which has been neglected for too long, it's quite another to have to build upon what is already there. It's like the difference between cleaning a house owned by a "hoarder", and being forced to live in one.

Technical debt creeps in to every project, and that's okay. The point is to manage it, and the only way to manage it is by regularly refactoring your code and your design. If allowances are made for refactoring with each bug fix or new feature, keeping the technical debt low is a small investment. If allowances are not made, well, it's kinda like the differences between patching a house's foundation and mudjacking it. Either address the problems in the foundation as they arise or watch the house it's supporting slowly come crashing down.

## Further Reading
* You can't refactor without tests. Find out why [Tests are Pain](//samuelmullen.com/2011/12/tests-are-pain/)
* You should be reading [Martin Fowler](http://martinfowler.com/)
* You should [Refactor Mercilessly](http://www.extremeprogramming.org/rules/refactor.html)
* More than you really wanted to know on [Technical Debt](http://www.martinfowler.com/bliki/TechnicalDebt.html) and [Paying Down Technical Debt](http://www.codinghorror.com/blog/2009/02/paying-down-your-technical-debt.html)
