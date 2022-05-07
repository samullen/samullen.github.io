+++
title = "Your App Has Cancer"
description = "Cancer in software has many of the same characteristics as those in the human body: it steals resources from the body, grows at an alarming rate, and spreads. Know what symptoms to look for in your software, what damage in can lead to in your project and busienss, and learn how to fight it."
author = "Samuel Mullen"
date = "2016-12-04T12:25:16-06:00"
tags = [ "business", "software", "development", "management" ]
+++

<img src="//samuelmullen.com/images/cancer/cancer_cell_comparison.png" class="img-thumbnail img-responsive img-right" alt="Comparison of health and cancer cells" title="Comparison of healthy and cancer cells">

The truth has been staring you in the face. You’ve put off dealing with it for too long, afraid of what you’ll discover. All the symptoms are there: the continued unexplainable problems, the mood swings, the fatigue, the headaches, and the exhaustion when faced with simple tasks.

It’s time to face the facts: your app has cancer.

It didn’t start this way, of course. When the project began your team was moving swiftly and silently. Morale was high and so was the velocity. But, over time, things started to change: more and more bugs crept in and remained, velocity slowed, and developer morale tanked. To make matters worse, your team spends more time fixing old features than adding new ones.

It could be that this scenario doesn't describe your project and your situation.
Or maybe it just doesn't describe it yet.  Wherever you are in your project’s
lifecycle, you need to be aware of the symptoms, causes, and dangers of cancer
in you software.

## Symptoms

Unlike real life cancer, there isn't a blood test or biopsy which can be
performed to easily diagnose cancer in an application. You can't put your code
under a microscope to see what ails it. It’s only by paying attention to the
symptoms that you will ever know how sick your software is.

### Code Smells

Coined by Kent Beck while helping Martin Fowler write "[Refactoring](http://martinfowler.com/books/refactoring.html)," the term “code smell” refers to certain identifiable patterns in code which are “…a surface indication that usually corresponds to a deeper problem in the system” ([CodeSmell](http://martinfowler.com/bliki/CodeSmell.html)). 

Patterns such as duplicated code, comments, conditional complexity, and
uncommunicative names are all examples of code smells. Individually, code smells
don’t guarantee a deeper underlying problem, but collectively code smell
indicates something rotten in the product’s development.

### Increased Number of Bugs and Defects

One of the most obvious symptoms of software cancer is an increasing number of
bugs. Not just an increase, but a persistence of bugs. These persistent bugs
can’t be squashed and more bugs arise in their place just as soon as others are
put down. 

<img src="//samuelmullen.com/images/cancer/99_bugs_on_the_wall.jpg" class="img-thumbnail img-responsive" alt="99 Little Bugs on the wall" title="99 Little Bugs on the wall">

The primary cause of these types of bugs are classes, methods, and functions
which try to take on too much responsibility. These blocks of code are easy to
spot: they take up more than one screen and are filled with indented code inside
indented code. The scary thing is a lot of this code probably started off tight.
But, as changes in requirements came in and deadlines loomed shortcuts were
taken and pretty soon everything was a right mess.

Now, because the code is responsible for so much, any change, any flaw, affects
every other piece of code that’s dependent on it. This is why bugs seem to
appear out of completely unrelated blocks of code. What once should have taken
hours to build or fix now takes days or weeks.

### Decreased Developer Productivity

Computers are amazing at following deeply nested logic structures, but humans
aren’t. In fact, we kinda suck at it. For a programmer to debug a deeply nested
conditional like what was mentioned previously, and which can receive any number
of inputs, he or she will likely fall back to drawing out the flow on paper,
trying to trace the route of the logic. It takes a lot of time and mental energy
to not only trace the logic, but keep as much of it in your head as possible.

The result? Instead of adding new features or improving efficiency of the application, developers burn hours just trying to understand the code and keeping the system running.

### Decreased Developer Morale

As you can imagine, the previous scenario isn’t a lot of fun. In fact, unless
you’re one of the rare developers who actively enjoys working with legacy code,
you’ll probably be miserable.

Decreased morale means decreased productivity followed shortly by a decrease in
staff. The best developers will leave first, followed by everyone
else. This leaves the developers who either can’t find another job or don’t care
enough to. These will be the ones maintaining the system. 

## Causes

Why does cancer grow in a healthy app? As with cancer in the human body, there
is rarely one single cause. For humans, it may be a combination of environmental
factors, stress, and what we put into our bodies. For software, however, the
reasons are quite different. 

### Deviation From Best Practices

<img src="//samuelmullen.com/images/cancer/best_practices.jpg" class="img-thumbnail img-responsive img-right" alt="I need you to follow best practices" title="I need you to follow best practices">

Much like craftsmen in other creative fields, programmers have developed collections of best practices for programming in specific languages, their use of specific tools, deployment, source code management, and more. 

Best practices are “procedures which have been shown by research and experience to produce optimal results”. Test Driven Development (TDD), Continuous Integration (CI), rigorous refactoring, and code reviews are just a handful of practices which enable the production of superior software.

As with other creative fields, when programmers stray from best practices the resulting code and project will contain the artifacts of that deviation. These artifacts, while not visible to anyone other than developers, are “felt” by the users of the software in application errors, slow application performance, and longer release cycles.

For more on these symptoms, visit: [The Pragmatic Programmer](https://www.amazon.com/Pragmatic-Programmer-Journeyman-Master/dp/020161622X), [Extreme Programming Explained](https://www.amazon.com/Extreme-Programming-Explained-Embrace-Change-ebook/dp/B00N1ZN6C0/ref=sr_1_1), and [Code Complete](https://www.amazon.com/Code-Complete-Developer-Best-Practices-ebook/dp/B00JDMPOSY/ref=sr_1_1).

### Inexperience 

Another cause of cancerous software is often due to nothing more than inexperience. Junior developers, even those who are exceptionally skilled, lack the necessary experience which guides more seasoned developers. This experience is knowledge only attainable through doing the work and choosing to learn from it.

Unfortunately, unless there are senior developers on a team who can provide some level of mentoring, the inexperienced developer will primarily learn through mistakes and at the expense of the project.

While inexperienced developers can wreak their own level of havoc on a project, potentially more damaging to a project is the influence of inexperienced management. Inexperienced managers and project managers can seriously reduce the effectiveness of even the most seasoned developer by involving them in too many unnecessary meetings, not providing enough of a buffer between development and the business, not providing clear direction, and being indecisive in the decisions.

### Apathy

<img src="//samuelmullen.com/images/cancer/apathy.jpg" class="img-thumbnail img-responsive img-right" alt="Nuclear explosion - Apathy" title="Nuclear explosion - Apathy">

Whereas inexperience leads developers to make poor decisions out of ignorance,
an apathetic developer makes poor programming decisions because he or she
stopped caring. There are a number of reasons which can lead to this: 

* Culture - Some companies just don’t care about excellence. To these organizations, it’s just about doing the least amount of work in order to get the job done.
* Management - When managers are apathetic about their job, those who report to them may see it as a sign that they shouldn’t care either.
* Team - A team can survive with one or two members who don’t care, but this can quickly spread to other members if it goes unchecked.
* Burnout - Working teams too hard for too long can result in apathy. This is especially true if there is no end in sight or there there is a sense that the work won't matter in the end.

Apathy fuels the cancer so it affects not only software and development staff, but every area of your business. It should dealt with as soon as it’s discovered.

### External Pressures

Deadlines and budget constraints are very real factors facing any organization. The have an especially strong impact on software development. As pressures mount, different organizations respond differently: some respond by increasing efforts and hours worked, while others seek to take shortcuts. The software produced in either case is usually saddled with technical debt.

> Like a financial debt, the technical debt incurs interest payments, which come in the form of the extra effort that we have to do in future development because of the quick and dirty design choice - [Martin Fowler](http://martinfowler.com/bliki/TechnicalDebt.html)

As with financial debt, there is interest associated with technical debt
revealing itself as reduced team productivity and lower software performance.
Technical debt is a byproduct of software cancer. Continuing to incur technical
debt only exacerbates these issues and feeds the cancer. Eventually like
financial debt, the debt must either be paid or the project liquidated.

### Communication

In 1967, Melvin Conway submitted a paper, "How Do Committees Invent?” to the [Harvard Business Review](http://hbr.org). His thesis was, “Any organization that designs a system (defined broadly) will produce a design whose structure is a copy of the organization's communication structure.”

This can be applied to many types of systems and processes within a company, but
software, more than anything else, is the most susceptible to an organization’s
communication structure. Organizations with very siloed groups tend to have
software which doesn’t interact well with other systems. Those which tend only
to make decisions in meetings have software which is bloated and overly complex.
Companies with a very top-down communication structure tend to have very
tightly-coupled, inflexible code bases.

Many of the projects I've been called in to rescue were in the state they were
in because of how those organizations communicated. Discovering these issues not
only allowed me to rescue the projects, but also showed my customers how they could correct other, more foundational issues, by changing how they communicated. 

## Dangers

In 1982, a criminological theory dubbed the “broken windows theory” was
introduced. The authors of the theory concluded that when communities are
maintained and cared for, crime can’t gain a foothold. Their example: even the
simple act of not repairing a broken window can lead to an increase in vandalism
and crime.

The theory is not without its detractors, but in the software industry it’s recognized as an inevitability:

> One broken window—a badly designed piece of code, a poor management decision that the team must live with for the duration of the project—is all it takes to start the decline. If you find yourself working on a project with quite a few broken windows, it’s all too easy to slip into the mindset of “All the rest of this code is crap, I’ll just follow suit.” It doesn’t matter if the project has been fine up to this point. — Andy Hunt and David Thomas, "The Pragmatic Programmer"

Bad code is exactly like a malignant tumor: it grows and spreads. And while bad code spreads, it becomes increasingly more complex and can couple itself to areas outside its purview.

Complexity in a software project is par for the course. Every new feature means
the business logic must necessarily get more complicated, but that doesn’t mean
the underlying code has to be harder to understand. You can have very
complicated business logic described by easy to understand programming.

When we allow bad code to gain a foothold, the added complexity only makes understanding it more difficult. The computer doesn’t have a problem with it – although it may perform slower – but people aren’t designed to keep large amounts of complicated logic in their head at one time. We perform much better with smaller, simpler instruction sets.

The primary danger of complex code then, isn’t the code itself, but the
programmer’s ability to correctly understand all the necessary logic. The more
logic that needs to to be understood, the greater likelihood that defects and
increased complexities are introduced. This results in even greater complexity,
further increasing the difficulty of understanding the logic, and further
increasing the likelihood of introducing more errors.

The cure many companies take to combat the ever-increasing number of bugs and decreasing productivity of the programmers is to throw more programmers – or worse, managers – at the problem. Too bad that’s the wrong solution.

## Treatment

Different methods are employed to treat cancer in people. Sometimes a single
type of therapy is required, but oftentimes multiple methods are used together to put cancer into remission. Medical treatments are not the only weapons used to
combat cancer. Patients also need support from friends and family, maintain
a healthy lifestyle, and keep a positive attitude. Cancer patients have the
most success when they combat their disease holistically.

Treating cancer in software is no different. To effectively treat cancer in your
software, a holistic approach must be taken. Correcting the most troubling areas
in the code can provide temporary relief. Unless the problems which led to
the issues are addressed, it’s only a matter of time before the cancer begins to
grow and spread again.

### Support the Process

If you’re serious about tackling the issues plaguing your software projects, the
most important thing you can do is support your development staff. You must
trust them to not only perform their job to the best of their ability, but also trust
their recommendations.

To non-programmers, programming can seem very intimidating. There are funny looking characters, weird terminology, an endless number of abbreviations, and it just _looks_ hard. This fear of the unknown has led to some seriously wrong conclusions about programming:

* Source code is all the same
* The only difference between programmers is how hard they work
* To get more done, just add more programmers

<aside>
These beliefs have led to so many older, more experienced programmers to lose their jobs to younger, less competent ones.
</aside>

Programmers are not the 21st century’s line workers. They can’t be swapped in
and out as if they are all capable of stamping out the same code. Just as in
other fields such as law, art, medicine, and management, there are different
levels of skill and ability among programmers. That ability level makes an
*enormous* difference in the quality of software produced.

When your development staff pushes to rework a section of an app, to add
automated tests, or stop development for a period of time to upgrade libraries,
it is not out of a desire to slack off, to navel-gaze, or be a burden to the
budget. Programmers want to produce an exceptional product for the
organization. They need your permission and support to do what they need to
do.

> Men and months are interchangeable commodities only when a task can be partitioned among many workers with no communication among them. This is true of reaping wheat or picking cotton; it is not even approximately true of systems programming. — Frederick P. Brooks "The Mythical Man-Month"

### Refactoring

<img src="//samuelmullen.com/images/cancer/what_if_I_told_you.png" class="img-thumbnail img-responsive img-right" alt="What if I told you refactoring adds value" title="What if I told you refactoring adds value">

Trusting your development staff that they know how to solve the problem is like
admitting you’re sick in the first place: it doesn’t cure the disease, but it
allows treatment to begin. To address a cancerous project, the problematic
code needs to be refactored.

> Refactoring (noun): a change made to the internal structure of software to make it easier to understand and cheaper to modify without changing its observable behavior. — Martin Fowler, "Refactoring"

When many people hear this, they balk, asking, “What’s the point of changing the underlying code if the app’s behavior doesn’t change?” These people see refactoring only as an expense, but during a field study performed at Microsoft on the benefits of refactoring, one developer asked in response:

> The value of refactoring is difficult to measure. How do you measure the value of a bug that never existed, or the time saved on a later undetermined feature? How does this value bubble up to management? Because there’s no way to place immediate value on the practice of refactoring, it makes it difficult to justify to management. — "A Field Study of Refactoring Challenges and Benefits"

In this study, developers reported the following results:

- Improved maintainability (30%)
- Improved readability (43%)
- Fewer bugs (27%)
- Improved performance (12%)
- Reduction of code size (12%)
- Reduction of duplicate code (18%)
- Improved testability (12%)
- Improved extensibility & easier to add new feature (27%)
- Improved modularity (19%)
- Reduced time to market (5%)

On the surface, refactoring appears to be an expense, but based on these results, it’s easy to see that it’s an expense providing a major return (and healing).

A further benefit provided by refactoring, and one which is even more difficult
to measure, is improved developer morale. Developers don’t enjoy writing poor
code, but when deadlines are moved up, and new features are added to the project
list, it’s the hidden mandate. Giving developers time to go back and fix the
shortcuts, workarounds, and hacks is immeasurably satisfying to a programmer.
It’s giving them permission to do things the right way.

### Automated Testing

It is uncommon for a person to discover they have cancer without any warning
signs. There are usually symptoms which precede the eventual diagnosis.  A
person can tell when something’s wrong with their body, because their nervous
system informs them of the pain or discomfort. Without a nervous system, we
would never know we are sick or injured without seeing it or being told by
someone else.

Automated tests perform the same role for software as the nervous system
performs in a person; they alert the programmer to problems in the code.

It’s not uncommon for development shops to include a testing department to
ensure new features perform correctly and don’t break existing functionality.
However, it is exceedingly difficult for those departments to systematically
test every aspect of an app every time a change is made to the underlying code.
Automated testing can do that.

An automated test is code written to ensure its product code counterpart always
behaves the same way. When it doesn’t, the test suite alerts the programmer of
the error. Unlike manual testing, automated testing can perform thousands of
tests in seconds allowing the development staff to know immediately if any
change or refactor affects any other part of the product. It really is like
giving your application a nervous system.

### Rewriting the Application

<img src="//samuelmullen.com/images/cancer/rewrite_software.png" class="img-thumbnail img-responsive img-right" alt="one does not simply rewrite software" title="One does not simply rewrite software">

The idea of rewriting an application is popular among programmers, especially
those who’ve never done it before. The idea is to take all good business logic
from the old application and create a new application from it. The new version
can be architected better so that all the technical debt, bugs, deprecated
functionality, and outdated thinking is left behind. That’s the idea.
Unfortunately, the idea usually falls far short of reality.

Joel Spolsky gave [four reasons](http://www.joelonsoftware.com/articles/fog0000000069.html) why you should never rewrite software from scratch:

1. It automatically puts you behind (e.g. your competitors, schedule, etc.)
2. The code probably isn't as bad as the programmers believe (anything someone else wrote is always a mess, although some are bigger messes than others - and even then)
3. It's probably easier/quicker/cheaper to fix what's truly wrong with it than to rewrite from scratch.
4. In rewriting from scratch, you are probably going to re-introduce bugs that were fixed in previous versions the original code.

I am not a proponent of rewriting applications. There are exceptions, of course
(we’ll get to those later), but in my twenty years of programming, I’ve never
seen a major rewrite keep the promises which were made about it. 

With that said, here are my recommendations for when to rewrite a piece of
software:

1. The technology the application is built upon is no longer supported
2. The technology the application is built upon is only supported by dinosaurs (Hello, Cobol)
3. It is no longer possible to add new features
4. The application no longer functions

Software rewrites almost never address the real issues. It's like giving a chain
smoker a lung transplant to cure his cancer.

## Remission

For cancer survivors, being in remission "means that tests, physical exams, and scans show that all signs of your cancer are gone." It's different from being cured, because there is a possibility that the patient can experience a recurrence (i.e., the cancer comes back).

Even after cancer has been purged from an application, it too can experience a recurrence. Unlike real cancer, however, there are steps both management and developers can take to ensure the cancer stays cured.

### Training

If you’re concerned about increasing the quality of your software, the simplest solution is to improve the quality of your development staff. The simplest way to do that is training.

Training has changed a lot over the past couple of decades. There was a time when you’d have to actually leave the office and attend a class in person. Today, most training can be accomplished through webinars, screencasts, e-learning, and web-based training. Some prefer to learn through reading and experimentation; that should be encouraged as well.

The advantages of training developers extend beyond the benefits seen in the quality of the work they produce. When they know there is an actual interest in their growth, it can spur them on to excel.

> Our chief want is someone who will inspire us to be what we know we could be. – Ralph Waldo Emerson

The following is just a sample of the benefits experienced through an intentional training program for your programming staff:

* Increased job satisfaction and morale
* Increased motivation
* Increased ability to adopt and adapt to new technologies
* Increased innovation in strategies and techniques
* Reduced turnover
* Enhanced company image

Yes, increased ability and skill matter, but not nearly as much as having motivated and driven employees who want to be working on your project, and who want to produce their best work.

### Code Reviews

<img src="//samuelmullen.com/images/cancer/code_reviews.jpg" class="img-thumbnail img-responsive img-right" alt="Code reviews are my favorite" title="Code reviews are my favorite">

Another solution to slowing the recurrence of cancer is performing regular
code reviews. Code reviews are very much like peer reviews in the scientific
community. There are a number of different times when they can be performed, but
in general, a code review should be performed before any branch or feature is
allowed to be merged into the master branch. During the process the reviewer
looks for logic errors and simple improvements; ensures the code matches the
organization's style and meets the expected level of quality; and, of course,
ensures the code actually works. 

In his book, "Code Complete," Steve McConnell provides the results from numerous
case studies highlighting the effectiveness of code reviews.

> … software testing alone has limited effectiveness – the average defect detection rate is only 25 percent for unit testing, 35 percent for function testing, and 45 percent for integration testing. In contrast, the average effectiveness of design and code inspections are 55 and 60 percent. Case studies of review results have been impressive:

> * In a software-maintenance organization, 55 percent of one-line maintenance changes were in error before code reviews were introduced. After reviews were introduced, only 2 percent of the changes were in error. When all changes were considered, 95 percent were correct the first time after reviews were introduced. Before reviews were introduced, under 20 percent were correct the first time.
> * In a group of 11 programs developed by the same group of people, the first 5 were developed without reviews. The remaining 6 were developed with reviews. After all the programs were released to production, the first 5 had an average of 4.5 errors per 100 lines of code. The 6 that had been inspected had an average of only 0.82 errors per 100. Reviews cut the errors by over 80 percent.
> * The Aetna Insurance Company found 82 percent of the errors in a program by using inspections and was able to decrease its development resources by 20 percent.
> * IBM's 500,000 line Orbit project used 11 levels of inspections. It was delivered early and had only about 1 percent of the errors that would normally be expected.
> * A study of an organization at AT&T with more than 200 people reported a 14 percent increase in productivity and a 90 percent decrease in defects after the organization introduced reviews.
> * Jet Propulsion Laboratories estimates that it saves about $25,000 per inspection by finding and fixing defects at an early stage.

*h/t: Jeff Atwood - [Code Reviews: Just Do It](https://blog.codinghorror.com/code-reviews-just-do-it/)*

But beyond mere financial and quality gains, consider these other important
benefits to code reviews:

* **It encourages a culture of quality**: Programmers have a certain amount of
  insecurity in their ability. They, like all of us, want to be seen as both
  capable and intelligent. When they make mistakes, it's often taken as a mark
  against both of those traits. When they know their code is going to be
  reviewed, it's extra motivation to produce high quality code.
* **It improves overall understanding of the system**: There is a tendency to
  allow programmers to become the primary developer over specific areas of an
  application or system. This can create silos of information. These silos
  result in ignorance of other areas as well as a potential  "us vs. them"
  mentality. Code reviews force developers to look at areas of the system 
  outside of their purview and gain a greater understanding of the project as a 
  whole.
* **It improves programming knowledge**: One of the best ways to improve
  programming ability is to read code. Reading code exposes the developer to 
  new ideas and new ways of doing things. It also encourages the thought process
  of "how would I do things differently?". Code reviews provide this 
  opportunity. It also allows the opportunity for more senior developers to 
  mentor less experienced developers.
* **It promotes team comraderie**: When the team has a familiarity with the
  whole project on which they all collaborate, it results in a greater sense of 
  ownership and trust in one another. It's the natural outcome of accepting a
  critique of one's creation and providing guidance to others.

### Vigilance

In the end, ensuring cancer remains in remission requires vigilance, a
willingness to change, and commitment. It's not a war to be won, but one which
is continually fought. Cancer can grow in an app regardless of how old it is.
I've rescued apps which began life diseased, but I've also seen ancient software
(i.e., more than three years old) which was the picture of health. This all
depends on the team developing the app, and their commitment to making great
software.

Be alert for symptoms when they arise: code smells, increasing numbers of
defects, and decreased productivity and morale among your staff. These are all
signs that your software may no longer be in remission.

Remember to adhere to best practices such as Test Driven Development (TDD) and
code reviews. Be sure to practice refactorings as a part of your process.
These three practices, more than anything, will act as antibodies to any cancer
which could start to grow in your app.

Finally, trust your developers to do what is right for the success and longevity
of the product. Encourage their ownership of the software by supporting code
reviews and considering their recommendations. No programmer wants to work in
convoluted and confusing code, and unless they've been regularly shut down in
the past, will seek solutions to make the code base something they're proud of.

Not every organization has the resources to properly fight the cancer which
exists in their software. In those cases, it makes sense to 
[hire outside consultants](//samuelmullen.com/contact) who specialize in
repairing legacy software. I pride myself on rehabilitating diseased and
ailing software, and bringing new life and value to dying projects.

## Support the fight

"Cancer" is an ugly word and it's an even uglier disease. In software, cancer
results in bugs, slower development times, reduced performance, and lower
profits. It can spread throughout a system, causing major delays, low morale,
and even result in employee turnover. In people, cancer is even worse.

Every day, more than 1,500 people die of cancer in the US alone. That's 1,500
sons, daughters, mothers, fathers, friends, and family. It's 1,500 what might
have beens, and 1,500 lives which will never shine their light again. 

It happens every day.

If this article's been a help for you, do me a favor and support the [American
Cancer Society's](http://www.cancer.org/) fight against cancer. Be a part
of ensuring those 1,500 lives have more time to shine. [Donate today](https://donate.cancer.org/index)
