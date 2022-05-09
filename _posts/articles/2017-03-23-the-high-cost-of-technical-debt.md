---
title: "The High Cost of Technical Debt"
description: "Technical debt is costing your projects and company more than you realize. Like fiscal debt, technical debt can be paid down, and it's imperative that you do.  There's more at stake than a little bit of low quality code."
date: "2017-03-23T13:12:32-05:00"
author: "Samuel Mullen"
tags: ["legacy code","technical debt"]
---

Being in debt is a horrible feeling, and the deeper the debt you're in, the worse that feeling gets. It's suffocating and many, refusing to acknowledge they're gasping for air, allow themselves to become more and more constricted.

<img src="//samuelmullen.com/images/high_cost_of_technical_debt/trapped.jpg" class="img-thumbnail img-responsive img-right" alt="trapped and suffocating" title="trapped and suffocating">

But have you ever talked with someone who's managed to dig their way out from their mountain of debt? They describe the sensation with words like "lighter," "unburdened," and "finally," but the word that speaks the loudest is "freedom."

When you are no longer burdened by debt, you are free to do what you want with your money. You can buy nice things, travel, give to charity, or invest in your future. Because the money is yours, you get to choose what you do with it.

## Technical Debt

Legacy technologies are a lot like debt. In fact it's so much like debt we call it exactly that: "technical debt." Ward Cunningham was the first to draw the comparison [when he wrote](http://c2.com/doc/oopsla92.html):

> The danger occurs when the debt is not repaid. Every minute spent on not-quite-right code counts as interest on that debt. Entire engineering organizations can be brought to a stand-still under the debt load of an unconsolidated implementation, object-oriented or otherwise.

Just like monetary debt, technical debt incurs interest which must be paid. This interest reveals itself in increases to different types of costs: maintenance, support, legal, opportunity, and talent. The longer it takes you to pay down your debt, the more interest you'll accrue in the process.

### Maintenance Costs

In 2002, the National Institute of Standards and Technology (NIST) estimated that [software bugs cost](abeacha.com/NIST_press_release_bugs_cost.htm) the U.S. economy nearly $60 billion dollars, or 0.6% of the GDP (approximately $109 billion in 2017). In this same study, they also found that "[s]oftware developers ... spend approximately 80% of development costs on identifying and correcting defects..." How much money is 80% of your IT budget?

While 80% sounds like a lot–and it is–understand that it results from the complexity of the code. The greater the complexity, the higher that percentage will be. Complexity takes into account both the size of the project and the quality of the code. Large projects with high-quality code can have much smaller maintenance costs than smaller projects with low-quality code.

> Software is error-ridden in part because of its growing complexity. The size of software products is no longer measured in thousands of lines of code, but in millions. Software developers already spend approximately 80% of development costs on identifying and correcting defects and yet few products of any type other than software are shipped with such high levels of errors.
> – [Software Errors Cost U.S. Economy $59.5 Billion Annually](http://abeacha.com/NIST_press_release_bugs_cost.htm)

### Support Costs

Software bugs are a little bit like real bugs: Sometimes you know the bugs are there because of the evidence they leave behind (termites are a great example), and other times, like walking through a swarm of gnats, they're impossible to miss. It would be wonderful if your development or QA staff were able to catch errors before the users noticed, but more often than not, it's your customers who notice the majority of bugs after a product or feature is shipped.

<img src="//samuelmullen.com/images/high_cost_of_technical_debt/call_center.jpg" class="img-thumbnail img-responsive img-right" alt="call center" title="call center">

Your support costs will increase by several factors:

* **Customer base**: the number of customers who use your product
* **Code quality**: how error-free the product is
* **Product usefulness**: how frequently your product is used

Of these three, the quality of your product is the only thing your team can have a direct impact upon, and the one area which is guaranteed to affect support costs.

### Legal Costs

Costs directly related to the upkeep and support of an application are to be expected, but depending on the software, technical debt can also result in legal costs. These costs usually come in one of three forms: fines, compliance penalties, or class-action lawsuits. Not every software project runs the risk of lawsuit–most won't–but for those that do, the results can be devastating.

Unfortunately, when software is burdened with large amounts of technical debt, it takes increasingly longer to make changes. The longer it takes to make changes, the greater the fines for being non-compliant.

Failing to comply with the requirements set out by [HIPAA](https://kb.iu.edu/d/ayzf) and [PCI](http://www.focusonpci.com/site/index.php/PCI-101/pci-noncompliant-consequences.html) can result in costs from $100-$1,500,000. Many of these costs are time-based, so the longer it takes to get in compliance, the higher those costs will run.

Compliance isn't the only concern. Lawsuits can arise from bugs such as Apple's ["data-gobbling bug"](https://www.engadget.com/2015/12/18/apple-is-being-sued-over-another-data-gobbling-bug/) or security breaches such as what happened to [Sony Pictures in 2016](http://deadline.com/2016/04/sony-hack-lawsuit-settlement-approved-class-action-1201732882/). No amount of effort will eliminate every chance of litigation, but ensuring your software remains up-to-date and quickly debuggable will greatly reduce the risk and the penalties.

### Opportunity Costs

The way we were taught about opportunity costs in school went something like this: You have $100. There are two items you want to purchase with that $100, but you can't afford both at once. The one you *don't* buy is the opportunity cost. Now that we're out of school we see that, well, opportunity costs still work the same way.

In software, you have a certain amount of resources (e.g. staff, money, and processing power) to work with, and a certain number of options to apply those resources toward (e.g. new features, maintenance, infrastructure improvements, etc.) In a perfect world, the opportunity cost would merely be the activities you've opted not to work on. If you choose to add a new feature, then maintenance, infrastructure, and other activities would wait.

But technical debt changes all that. When a project has a large amount of technical debt, every choice will be framed by that debt. Regardless of the decision, the debt must either be paid down or somehow put off. The time it takes to do that only adds to the opportunity cost. If you choose to continue to put off paying down you debt, you will see more and more opportunities slip by.

> If you can get today’s work done today, but you do it in such a way that you can’t possibly get tomorrow’s work done tomorrow, then you lose.
> – Martin Fowler, [Refactoring: Improving the Design of Existing Code](https://www.amazon.com/Refactoring-Improving-Design-Existing-Code/dp/0201485672)

### Talent Costs

In the late 1990s, every media outlet was transfixed by the [Y2K bug](https://en.wikipedia.org/wiki/Year_2000_problem). Stories published in that time either spoke about the impending doom of the crisis or the exorbitant amount of money consultants were charging to fix the problem. Of course, not every consultant was able to charge enormous amounts of money, just those who specialized in legacy technologies such as COBOL.

<img src="//samuelmullen.com/images/high_cost_of_technical_debt/rubymidwest.jpg" class="img-thumbnail img-responsive img-center" alt="call center" title="call center">

The Y2K bug came and went without much excitement, but it taught us a couple lessons in its passing: 1) It's hard to find programmers for outdated technologies; and 2) Outdated technologies cost increasingly more to maintain.

Universities don't teach COBOL anymore–they rarely even teach C or C++–and good developers focus on keeping their skills up-to-date. As your technology infrastructure ages, it becomes increasingly difficult to find workers for the job. Younger developers have only been exposed to newer languages, while older, more experienced developers who've kept their skills up-to-date, have no interest in moving backward. Who does that leave you with? Older developers who've had no interest in improving. And you'll pay a premium for them.

## Start Investing

Prior to getting married, my wife (then fiancé) and I racked up around $10,000 in credit card debt in order to pay for our wedding and move to Kansas City. Even though we did it intentionally, it put us in a bad spot and took over a year to pay off the debt. Over this period, time we began looking forward to each month's credit card statement, because each payment brought us closer to freedom. We not only saw each payment as buying back freedoms, but also as an investment. The more we paid each month, the less we would have to pay in total.

<img src="//samuelmullen.com/images/high_cost_of_technical_debt/investing.jpg" class="img-thumbnail img-responsive img-right" alt="plant growing in coins" title="plant growing in coins">

The same is true for technical debt. As you start paying it down, you'll begin to see how your investment opens up new opportunities. One of the first things you'll see is a change in you and your team's attitude about the project. This change in attitude alone is like getting an influx of cash.

To start paying off your technical debt, you need to start investing in two places: your culture and your code base

### Investing in Your Culture

The [average American credit card debt is $16,748](https://www.nerdwallet.com/blog/average-credit-card-debt-household/), and most people do not intentionally put themselves in that position. They get there a little bit at a time, not through one clearly bad decision, but through many smaller bad *and* good decisions.

Software projects are the same way. Technical debt doesn't accrue because of one bad decision or even through an intentional decision to make a system worse. It happens a little bit at a time through short-sighted decisions, external pressures, inexperience, apathy, and a host of other reasons.

The problem is once technical debt is there and it's perceived to be allowed, it seeps into the culture. It's like a broken window in a neighborhood.

> One broken window—a badly designed piece of code, a poor management decision that the team must live with for the duration of the project—is all it takes to start the decline. If you find yourself working on a project with quite a few broken windows, it’s all too easy to slip into the mindset of “All the rest of this code is crap, I’ll just follow suit.” It doesn’t matter if the project has been fine up to this point.
> — Andy Hunt and David Thomas, “The Pragmatic Programmer”

The line must be drawn: No longer will we allow low-quality software to be shipped. No longer will we accept garbage code into our project.

It may take pushing back on management (read: It *will* take pushing back on management), and it's going to take an investment into your code base and coding practices.

### Investing in Your Code Base

But changing your team's culture and attitude is only half the battle, it must be matched by action. The actions we recommend are implementing automated testing, a practice of regular refactoring, and performing code reviews. While there are more practices teams can use to invest in their code base, we've found that these three are the most effective for stopping the bleeding and moving a project in the right direction.

#### Automated Testing

Automated testing is exactly what it sounds like. It's getting the computer to do the heavy lifting of testing your software. I often liken it to adding a nervous system to the software: It alerts the developer to damage in the code.

<img src="//samuelmullen.com/images/high_cost_of_technical_debt/tdd_cycle.png" class="img-thumbnail img-responsive img-right" alt="tdd cycle" title="tdd cycle">

When a QA team puts a piece of software through a series of tests, they often focus on testing the story in question and maybe testing other parts of the product at a surface level. If bugs or problems are found, the changes are rejected and sent back to the development team to fix. This may occur multiple times resulting in lost time and money as the features pin-pong back and forth between the departments.

With automated tests, developers can see tests pass or fail *as* they are developing, greatly shrinking the feedback cycle and reducing the amount of time the story will eventually reside with QA.

In the previously mentioned NIST study, they "[...found that, although all errors cannot be removed, more than a third of these costs, or an estimated $22.2 billion, could be eliminated by an improved testing infrastructure that enables earlier and more effective identification and removal of software defects."

How much money would your project save if you were able to reduce support and maintenance costs by a third?

#### Refactoring

According to Martin Fowler in "[Refactoring: Improving the Design of Existing Code](https://www.amazon.com/Refactoring-Improving-Design-Existing-Code/dp/0201485672)", Refactoring is the process of making a change "...to the internal structure of software to make it easier to understand and cheaper to modify without changing its observable behavior."

While the changes made may have no perceivable external benefits, the benefits you gain internally are immeasurable. Martin Fowler wrote, "I’ve found that refactoring helps me write fast software. It slows the software in the short term while I’m refactoring, but it makes the software easier to tune during optimization. I end up well ahead."

Furthermore, in [An Empirical Study of Refactoring Challenges and Benefits at Microsoft](https://www.microsoft.com/en-us/research/publication/an-empirical-study-of-refactoring-challenges-and-benefits-at-microsoft/), developers reported similar findings to those of Martin Fowler with the following results:

* Improved maintainability (30%)
* Improved readability (43%)
* Fewer bugs (27%)
* Improved performance (12%)
* Reduction of code size (12%)
* Reduction of duplicate code (18%)
* Improved testability (12%)
* Improved extensibility & easier to add new feature (27%)
* Improved modularity (19%)
* Reduced time to market (5%)

Wouldn't you want to see these same benefits in your own projects? Doesn't it appear that the benefits would more than pay for themselves?

#### Code Reviews

<img src="//samuelmullen.com/images/high_cost_of_technical_debt/code_reviews.jpg" class="img-thumbnail img-responsive img-right" alt="Code reviews are my favorite" title="Code reviews are my favorite">

I wrote more thoroughly about code reviews in my my article, "[Your App Has Cancer"](https://blog.codinghorror.com/code-reviews-just-do-it/), but if I may quote the quote which was quoted there...

> … software testing alone has limited effectiveness – the average defect detection rate is only 25 percent for unit testing, 35 percent for function testing, and 45 percent for integration testing. In contrast, the average effectiveness of design and code inspections are 55 and 60 percent. Case studies of review results have been impressive:
>
> * In a software-maintenance organization, 55 percent of one-line maintenance changes were in error before code reviews were introduced. After reviews were introduced, only 2 percent of the changes were in error. When all changes were considered, 95 percent were correct the first time after reviews were introduced. Before reviews were introduced, under 20 percent were correct the first time.
> * In a group of 11 programs developed by the same group of people, the first 5 were developed without reviews. The remaining 6 were developed with reviews. After all the programs were released to production, the first 5 had an average of 4.5 errors per 100 lines of code. The 6 that had been inspected had an average of only 0.82 errors per 100. Reviews cut the errors by over 80 percent.
> * The Aetna Insurance Company found 82 percent of the errors in a program by using inspections and was able to decrease its development resources by 20 percent.
> * IBM’s 500,000 line Orbit project used 11 levels of inspections. It was delivered early and had only about 1 percent of the errors that would normally be expected.
> * A study of an organization at AT&T with more than 200 people reported a 14 percent increase in productivity and a 90 percent decrease in defects after the organization introduced reviews.
> * Jet Propulsion Laboratories estimates that it saves about $25,000 per inspection by finding and fixing defects at an early stage.
> –Jeff Atwood quoting [Code Complete](https://www.amazon.com/Code-Complete-Practical-Handbook-Construction/dp/0735619670) - [Code Reviews: Just Do It](https://blog.codinghorror.com/code-reviews-just-do-it/)

Code reviews are just another way you will not only bring quality to your project but reduce the technical debt and the costs it incurs.

## The Cost of Choice

Throughout this article, I've referred to the lack of freedom brought about by debt, technical or otherwise. I've even pointed out a number of means by which those freedoms are impinged upon in the form of costs: maintenance, support, legal, talent, and opportunity. The end result of these costs is the cost of choice. Technical debt steals your freedom to choose what you do with your budget of resources. Technical debt decides that for you.

But facing a mountain of technical debt isn't the end of the story. The mountain can be scaled and conquered, you just have to make the decision to start. The first hurdle is making the decision; it's deciding that you and your team are better than that and that your project deserves better than that too. Once the decision has been made, your must implement the first practices necessary to scale the mountain: namely automated testing, regular refactoring, and code reviews.

Your project got into it's current predicament over the course of its lifetime, fixing that won't take nearly that long, but you have to start now. The longer you wait, the longer it will take, and the more interest you'll pay.
