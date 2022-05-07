+++
title = "What is Technical Debt?"
author = "Samuel Mullen"
tags = ["technical debt","clean code"]
date = "2017-05-04T09:39:48-05:00"
description = "'Technical Debt' is a metaphor we use in the tech industry to describe the deficiencies in our code base. Did you know there are different types of technical debt and that not all debt is a bad thing?"
+++

Every industry has terms and phrases it uses to help describe complex concepts and practices. Some are intended for use within the industry, while others are used to help convey industry-specific concepts to those outside the industry. One such term we use in software engineering is "technical debt".

Even though the term is used to help "non-developers" more easily understand the state of a code base, I've recently had several conversations with startup founders who've admitted they didn't understand what technical debt is or why it's a problem.

In programming, there is always more than one way to do something, and it's a regular struggle for developers to determine which solutions are "best". Factors such as the experience of the developer, familiarity with the technology, time constraints, and the state of the project all affect which solution the developer will choose. What solution the developer settles on today may not be what he or she would choose in the future or even the past.

For example, let's say you have an e-commerce site. To get it launched on time, your programmer, while being experienced and disciplined, had to use some shortcuts for the checkout process to meet the launch date. After a year of your site being in service, business is booming. But in that time, the original checkout code has been tweaked and patched far beyond its original design. In fact, it's to a point where no new features can be added without rewriting the whole thing.

That's technical debt. The first "loan" was taken out when your developer took a shortcut to get your product out the door. Instead of going back and cleaning up the code for the checkout process (i.e. paying off the loan), your team went further into debt by patching the code and making it more complicated. In the end, the checkout process was in so much debt that the only way to get out from under it was to declare bankruptcy and rewrite it.

## Types of Technical Debt

You can see from the example that there are two kinds of debt in play: One which was taken on at the beginning in order to launch the product, and another which wasn't even noticed until it was too late.

Martin Fowler recognized the distinctions in technical debt and broke it up into quadrants. The quadrants provide a distinction between prudent and reckless actions, and those which are either intentional or inadvertent: 

<img src="//samuelmullen.com/images/what_is_technical_debt/quadrants.png" class="img-thumbnail img-responsive center-block" alt="technical debt quadrants" title="Technical debt quadrants">

By combining the two groups, we end up with four possible types of technical debt.

### Reckless-Deliberate

This type of debt is taken on when your development staff "may know about good design practices, even be capable of practicing them, but decide to go "quick and dirty" because they think they can't afford the time required to write clean code" (https://martinfowler.com/bliki/TechnicalDebtQuadrant.html). This may happen when a team has a low morale or if there is a culture of producing half-baked products, but it can also occur when management applies pressures to continually push out products. In almost every case, both the development staff and management are to blame.

### Reckless-Inadvertent

This sort of technical debt is traditionally acquired by a combination of both inexperienced developers and management. The team as a whole just doesn't have the experience necessary to know what they're doing right or wrong, and instead are just blindly plowing forward.

### Prudent-Deliberate

In this instance both management and the development staff agree that the value of shipping a “quick and dirty solution” now is worth the incurred debt. They know what they're getting into and have a plan for addressing the debt as soon as possible.

### Prudent-Inadvertent

You are never more ignorant about how things should be done than when you first do them. Prudent-Inadvertent debt is incurred when a team realizes how a solution should have been implemented after the fact.

## Why Technical Debt is Bad

The problem with technical debt is that any time you want to make new investments in your product (new features, bug fixes, performance improvements, etc.,) you must first pay the accumulated interest. However, if all you do is pay the minimum, you will only add to your debt burden with every change you make. 

>Shipping first time code is like going into debt. A little debt speeds development so long as it is paid back promptly with a rewrite... The danger occurs when the debt is not repaid. Every minute spent on not-quite-right code counts as interest on that debt. Entire engineering organizations can be brought to a stand-still under the debt load of an unconsolidated implementation, object-oriented or otherwise. 
>
>*Ward Cunningham*

Technical debt always adds complexity, even when that complexity isn't felt immediately. But as a project continues, those complexities become more and more apparent, revealing themselves in many ways:

* **Reduced performance**: Frequently used processes and functions and those which are most central to your application will feel the drag on efficiency most acutely.
* **Increased resource requirements**: When processes are hindered by complexity, it takes more processing power to handle the load. The drag caused by technical debt on efficiency may demand extra hardware–and possibly developers–to counteract the effect.
* **Bugs/Errors**: Although there is not a 1:1 ratio of debt to bugs and errors, the added debt makes the code more difficult to work with and increases the likelihood of introducing bugs.
* **Increased development times**: Complexity always takes longer to work with, and thus requires more effort and time by your development staff to work around.

As Martin Fowler recognized, the most destructive result of technical debt is the opportunity cost:

>One thing that is easily missed is that you only make money on your loan by delivering. The biggest cost of technical debt is the fact that it slows your ability to deliver future features, thus handing you an opportunity cost for lost revenue.
>
>*Martin Fowler*

## Why Technical Debt is Good

Eventually you need to ship your product or feature. You have two choices: you can ship it when it's perfect, or you can ship it when it's done. But as the old saying goes, "perfect is the enemy of done."

Intentionally adding technical debt to a project can greatly speed up development efforts and help get your product or feature out the door. It's not ideal, but some situations demand it. And even if your team had the time to actually perfect the code for a feature or product, how can you be sure that code would remain perfect once it was released to the customers? As Steve Blank wrote, "No business plan survives first contact with the customer." That goes double for the product.

Technical debt is part of every project and intentional debt is a sign of productivity. Monitor the state of your debt and keep track of what concessions you were forced to make, but don't be ruled by the fear that all debt is created equal or that all debt is bad.

>At the end of the day, ship the fucking thing! It’s great to rewrite your code and make it cleaner and by the third time it’ll actually be pretty. But that’s not the point—you’re not here to write code; you’re here to ship products.”
>
>*Jamie Zawinski*

## Limiting Technical Debt

As you may have already guessed, it's impossible to avoid technical debt completely. To do so would require you to have a perfect understanding of your customer and the ability to see into the future. The only thing we can do is try to limit how much debt we take on.

### Understand the Problem

Much of why unused features, bugs, and technical debt exists in so many applications is because the teams developing them didn't fully understand the problem(s) they were trying to solve. This can be the result of not having product/market fit (i.e. lots of pivots), a lack of a clear vision, management just chasing squirrels, or any number of other things. 

Regardless of the reason, the results are the same, leaving your product with inefficient and overly complex code, unused code from developers being sent down blind alleys, and features no one uses.

Limiting this requires you to truly understand the problem and communicating it to your team. 

### Accelerate Iterations

"Build. Measure. Learn." It's the mantra of "The Lean Startup" movement, and the guiding principle of the fastest and most agile companies. The idea behind it is to discover problems in your theories as quickly as possible and make adjustments, because changing direction is much cheaper early on than later in a product or feature's lifecycle.

When it comes to development, this also keeps the programming staff from going down blind alleys too far. The more frequently iterations and releases occur, the easier it is for the team to adjust direction. Also, reducing the amount of work which is thrown away is highly motivational. Nothing is worse than working for months on a feature that is never used.

### Anticipate Deadlines

Another reason technical debt creeps into projects is because the development staff doesn't believe there's enough time to do things right. Instead, they'll just "git'r done". In some organizations, this is uncommon and the code will be fixed later. But if an organization has a culture of short deadlines, producing lower quality code will also become part of that culture.

>One broken window—a badly designed piece of code, a poor management decision that the team must live with for the duration of the project—is all it takes to start the decline. If you find yourself working on a project with quite a few broken windows, it’s all too easy to slip into the mindset of “All the rest of this code is crap, I’ll just follow suit.” It doesn’t matter if the project has been fine up to this point.
>
>*Andy Hunt and David Thomas, “The Pragmatic Programmer”*

The solution to this is to limit unanticipated deadlines and scale back requirements to fit those deadlines. Requirements can always be scaled back.

### Allow for Refactoring

You're busy. It doesn't matter if you work for a startup or a multinational conglomerate, if you're a line worker or the CEO. You have deadlines, pressures, and goals. The last thing you want to hear is that your team wants to slow down and go back to clean up the codebase.

The problem with being busy is it's not always productive. Just because you're marking things off your todo list, doesn't mean you're moving the needle.

The same goes for programming. Programmers can work hard, but not get a lot of work accomplished. This can happen when they're saddled with an inordinate amount of technical debt. The complexity added by that debt slows the development process. It takes longer to reason through, to make changes, and to test. Even worse, it increases the likelihood of introducing bugs.

By allowing your team the time necessary to clean up the code base, even small parts of it, it can dramatically improve their productivity. When developers work with "clean code", they don't have to fight the code to add new features; the code almost invites them to do so. On top of that, it helps with motivation. Developers are craftsmen and craftswomen at heart. Give them permission to care about their work.

### Going Forward

The term "technical debt" was introduced as a metaphor to help us communicate some very involved concepts more easily. As we've unpacked the term, we see that not all debt is created equal and debt in and of itself is neither good nor bad; it's just debt. We've also seen that there is no way to avoid it, only ways to limit it.

As a metaphor, "debt" is the perfect word to use. When a person or a business is starting out, going into a little bit of debt can improve a situation and reduce the time needed to get established. But unless that debt is paid off, it will eventually transform from a tailwind propelling your business forward, to a sea anchor slowing your forward progress.

Eliminate technical debt when you can, take advantage of it when you must, and avoid it as long as possible.
