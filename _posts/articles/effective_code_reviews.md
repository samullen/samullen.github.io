---
title: Effective Code Reviews
date: 2018-10-31T12:50:58-05:00
draft: false
description: "Code reviews are the most important activity a development team can incorporate to drive down bugs, share knowledge, and increase development speed."
comments: false
post: true
categories: ["programming"]
---

Code reviews are a little like eating your vegetables: You know your supposed to
eat them and that they're good for you, but unless there's a parental unit
watching over you, it ain't gonna happen. The same is true for code reviews. We
know they'll help us improve the quality of our code and the overall system,
but unless they're part of the project's culture we're probably not going to
ask others to reviews our code.

Why another article about code reviews? Because code reviews work, and I
want to see more organizations adopt the practice. The complexity of our
applications and the demands placed on our software engineers is increasing
every day, and unless we incorporate tested and proven practices we will only
meet with failure.

## What is a Code Review?

Just to make sure we're on the same page, let's start with a formal definition
of what a code review is and then work from there.

> The activity of systematically examining computer source code with the intent
> of finding mistakes created or overlooked in the development process, and thus
> improving the overall quality of the software.

The idea is that a developers working on a project submit the work they've
performed to be reviewed by other developers on the project or within the
organization. The reviewers then look over the code for any flaws (logical,
syntax, complexity, etc.) or design issues and return their findings to the
submitting developer. The purpose is fourfold:

1. To ensure the work performed matches the work requested
2. To catch as many bugs as possible before they get to production
3. To keep the complexity of the system low
4. To ensure best practices are followed

In times gone by, these submissions (i.e. patches) would be often be provided
through email, but with the advent of modern source code management software
such as [Git](https://git-scm.org), code reviews have never been easier to
perform.

<img src="//samuelmullen.com/images/effective_code_reviews/git_diff.png" class="img-thumbnail img-responsive img-right" alt="Git diff" title="Git diff">

## Why Do We Need Code Reviews?

While the four reasons above provide the technical purpose of code reviews,
they're only the beginning of the benefits to be had from incorporating a formal
code review process into your organization.

### Code Reviews Reduce Bugs/Defects

It should come as no surprise from what we've discussed so far that code reviews
reduce the number of defects which are introduced into a software system, but
what kind of numbers are we talking about?

According to Steve McConnell, author of [Code Complete 2](https://www.goodreads.com/book/show/4845.Code_Complete),
"the average effectiveness of design and code inspections are 55 and 60 percent"
effective at detecting defects. That's between 10-35% more effective than
automated tests (which [you should also be doing](//samuelmullen.com/articles/tdd-youve-been-doing-it-all-along/)).

Furthermore, several case studies cited in the book showed that code reviews cut
errors by 82% at Aetna Insurance, 99% in IBM's Orbit project, 90% from an AT&T
project with more than 200 people. Finally, NASA's Jet Propulsion Laboratories
estimated it "saves about $25,000 per **inspection** by finding and
fixing defects at an early stage".

### Code Reviews Improve the Speed of Development

At first glance, the idea that code reviews speed up the development process
seems like nonsense. After all, with a recommended speed of
[no more than 500 lines of code an hour](https://smartbear.com/learn/code-review/best-practices-for-peer-code-review/), reviewing code can take a long time.
That's time the reviewer isn't working on adding features or fixing bugs. That's
time the submitter may be blocked from moving forward. Plus, if there are
questions about the patch or discussions which arise through the patch, that is
still more time not being put toward completing features.

But the point of software development isn't produce code or even features. It's
to create a functioning product.

As we've already seen, code reviews can reduce defects by an average of 60%.
That's 60% fewer bugs making it to your customers, but it also means 60% fewer
bugs that developers have to deal with in the future. It's been found that
developers spend an average of ["80% of development costs on identifying and correcting defects"](http://abeacha.com/NIST_press_release_bugs_cost.htm). How
much of that 80% could be reduced by creating 60% fewer defects to begin with?
What could your team do with that extra time?

If reduced defects where the only thing code reviews offered to increasing
development their value would still be justified. But code reviews do more than
reduce defects: they improve the overall quality of the codebase.

How so?

To begin, knowing your code will be reviewed motivates developers to take more
care towards producing the best code possible. This isn't limited to the raw
logic of a codebase, but also to the organization and architecture as well.
No one wants to get called out for writing shoddy code. Furthermore, when other
team members review code they bring their own perspective, knowledge, and
experience to bear on the changes, providing more opportunities to perfect the
logic, reduce complexity, and improve the overall quality of the code.

So what? What does code quality have to do with development time?

It's self-evident that logic takes more effort and time to think through and
reason about as complexity increases. The same is true in programming. When
a code base is saddled with high amounts of
[technical debt](//samuelmullen.com/articles/what-is-technical-debt/),
isn't well organized, or has portions the team is afraid to change, it's
necessarily going to take longer to make changes. On the other hand, when the
code is well maintained and organized it's much easier to reason about and make
changes. Even the largest codebases can keep complexity to a minimum.

> If you can get today’s work done today, but you do it in such a way that you
> can’t possibly get tomorrow’s work done tomorrow, then you lose.

> – Martin Fowler, [Refactoring: Improving the Design of Existing Code](https://www.goodreads.com/book/show/44936.Refactoring)

### Code Reviews Encourage a Healthy Engineering Culture

Before we go into *how* code reviews encourage a healthy engineering culture,
it's important to understand *why* a healthy engineerine culture is important.
There are two primary reasons.

First, a healthy engineering culture is one which is concerned about following
best practices, building well crafted products, and is much more productive.
All of this results in lower costs for the organization. Developers
in this kind of environment are more engaged with the projects and organization,
care more about the quality of their work, and consistently look for ways of
improving their craft.

Second, this type of culture attracts higher caliber engineers. It's difficult
to [Attract Good Developers](//samuelmullen.com/2012/02/advice-on-attracting-good-developers/),
but a strong culture eases this pain. The best developers want to be where they
will be pushed and have opportunities to excel.

> ...one of the most important factors for success of a company is the quality
> of its engineers. The best way to lower development costs is to hire great
> engineers: they don't cust much more than mediocre engineers but have
> tremendously higher productivity...If you code base is a wreck, word will get
> out, and this will make it hard for you to recruit. As a result, you are
> likely to end up with mediocre engineers.
>
> – John Ousterhout, [A Philosophy of Software Design](https://www.goodreads.com/book/show/39996759-a-philosophy-of-software-design)

Part of having a healthy culture is ensuring it can adapt to change. By
incorporating code reviews into your development process, your team has the
opportunity to become familiar with areas they might not otherwise have
encounter; be it the same project or others. This increased breadth of knowledge
creates a flexibility in the team, allowing members to stand in for others in
the case of sickness or other reasons. This shared knowledge also allows
multiple people to understand and solve problems.

As Martin Fowler notes:

> Code reviews help spread knowledge through a development team. Reviews help
> more experienced developers pass knowledge to less experienced people. They
> help more people understand more aspects of a large software system. They are
> also very important in writing clear code. My code may look clear to me, but
> not to my team. That's inevitable–it's very hard for people to put themselves
> in the shoes of someone unfamiliar with the things they are working on.

> – Martin Fowler, [Refactoring: Improving the Design of Existing Code](https://www.goodreads.com/book/show/44936.Refactoring)

Not only do code reviews widen the team's knowledge of the projects they
support, but being exposed to the code other people write also deepens their
knowledge of what a technology has to offer. Today's languages and frameworks
can be immense and no one gets to know it all, but by reading code we get to to
see how other developers solve problems, what API components they use, and what
patterns they lean on. There's always something to learn from code.

There is one final point I want to make before we move on to the process of code
reviews: a team that has a healthy practice of reviewing code is a team that has
a strong sense of ownership over a product. When you feel a sense of ownership
over something, you want to see it flourish and succeed. This sense of ownership
translates into engagement and purpose which then translates into increased
productivity.

There are two reasons for this. On one hand, knowing that others will be looking
over your work tends to motivate you to work a little harder. On the other,
code reviews require trust: trust from the submitter that the reviewer won't be
overly harsh in the response, and trust from the reviewer that his or her
comments will be listened to. Trust builds relationships and is at the core of
the best teams.

## Process

Now that we've looked at the "what" and the "why", let's look at "how" to go
about performing code reviews.

### 4 Rules

It is my opinion that above all else, four rules must be followed without
exception to successfully integrate code reviews into a team:

1. **Everyone gets code reviewed**: If you write code, whether it's x86
   assembler or HTML, or whether you're an intern or the CEO, every one of your
   commits needs to be reviewed.
2. **Everyone reviews code**: We can all learn from code and we all have
   something to teach. Making sure everyone on the team participates in reviews
   ensures that teaching and learning happens.
3. **Every PR gets reviewed**: To say that some PRs don't need to be reviewed is
   to say that you know which PRs will have defects. Every PR should be
   reviewed, so flip the switch in your SCM tool of choice and require every PR
   entering the project to be code reviewed.
4. **Every change gets reviewed**: Similar to the previous, but at a lower
   level and just as important. Every change made within a PR needs a review. Be
   it code or comment, it all needs a once-over.

### Submitting a Pull Request

All code reviews start with a pull request (PR). Every tool handles them a
little differently, so you'll want to check the documentation for the specifics
for your tool. When submitting a PR, there are three guidelines you need to
follow:

1. **Review your changes**: Do this to avoid unnecessary followup commits.  Here
   you should doublecheck to make sure everything is included in the PR; all
   caveman debugging code is removed (i.e. `Logger.info "got here"`); and all
   the tests pass.
2. **Describe your changes**: There was a reason for the changes you made, those
   need to be provided in the subject and description of the PR. Oftentimes it
   makes sense to reference the "ticket" associated with the changes. Also, if
   there are areas you believe warrant greater attention or require
   clarification, note them in the description.
3. **Request the right reviewers**: It seems obvious, but you want the right
   people reviewing your code; people who will have a background in the PR. It
   probably wouldn't make sense for an iPhone developer to request an Android
   developer to review his or her code.

### Reviewing a Pull Request

Once a pull request has been submitted it's time to review it. To do that,
you'll want to first be mindful off these four things:

1. **Know what the problem is**: It's hard to tell if a solution will solve
   the problem if you don't know what the problem is. To that end, read the
   description provided in the PR and any associated documentation provided in
   the ticket.
2. **Complete the review within 24 hours**: This means exactly what it says.
   A short feedback loop allows developers to keep focused on the issue at hand.
   There's nothing worse than submitting a PR, starting a new feature, and then
   finally getting feedback a week later.
3. **Take your time**: Reading code is mentally demanding and there's ony so
   much you can do before you focus begins to deteriorate. Try not to exceed 500
   lines an hour, and if you have to, break up the review into multiple
   sessions. Your brain will thank you, and so will your teammate.
4. **You're accountable**: When you click the "Approve" button, you're saying
   that you not only reviewed the code, but that it solves the problem and it
   is good enough to be included in the code base. You are also taking
   partial responsibility for problems that arise from it.

#### What to Look For

When your receive a request for review and you begin looking through the code,
what should you look for? Rather than providing you with a list of a hundred
code smells, potential problems, or gotchas you might see, I think it
makes sense to provide a high-level view of what to look for:

* **Does the code do what it's supposed to do?** This doesn't mean you need to
  start the app and enter into a full QA cycle. You should be able to tell from
  the code if it is likely to solve the problem or not.
* **Are there tests?** If so, that's great? Do they pass? Do they make sense? If
  tests aren't provided for the code, reject it and explain why.
* **Has the documentation been updated to reflect the changes?** If you project
  has documentation, make sure the changes in the PR are reflected in it. The
  only thing worse than no documentation is wrong documentation.
* **Are things named well?** Naming is one of the hardest things about
  programming, do the names used in the PR accurately describe what they
  represent or what they do?
* **Is there duplicate code?** As you are reviewing the code, do you see blocks
  which are duplicated? Would it make sense to extract them into their own
  class, module, or function?
* **Are there potential security issues?** If you see them, call them out.
* **Are there potential performance issues?** If so, explain what they are and
  provide a solution.
* **YAGNI (You Ain't Gonna Need It)** Has code been added which isn't needed yet
  and isn't part of the solution? Comment on it. If it isn't needed yet, it
  shouldn't be there.
* **The Boy Scout rule** If there is one of the guideslines you should remember,
  it's this: "Has the code been left in a better state than what the developer
  found it?"

### Giving Feedback

If you're performing a code review, you're going to have to give feedback. It
may be as simple as "Looks good!", "ship it!", or even just a "👍", but more
often than not you'll need to critique the code, point out issues, and ask
questions. As developers, we have a tendency to rush through the communication
related tasks to get back to what we're most comfortable with. In our haste, we
become more terse and direct resulting in unnecessary problems. To avoid any
potential problems, try following these guidelines:

#### Let Tools Be the Pedants

Code reviews require too much effort and are too important to allow reviewers to
waste their time commenting about coding style. Instead, reviewers should spend
their time thinking through the logic and design of the pull request, and
automated tools should be used to either point out style issues or better yet,
automatically format them for you.

#### Ask Questions

Just because someone's asked you to review their PR doesn't mean your initial
response must be either "Approve" or "Reject". Instead, think of it as the
beginning of a conversation. Like any conversation, there will be points you
will need clarification on in order to keep moving forward.  The same is true
for PRs. If there is logic or design choices you don't understand, ask the
author to clarify those choices. It may be that he or she doesn't fully
understand it either. If you don't understand it now, what's the likelihood
you'll understand it the next time you encounter it?

#### Be Articulate

Text is a horrible medium for communication. It doesn't convey facial
expressions, tone of voice, or any sort of body language. It's just text.  The
meaning of a sentence can vary just by where we as the reader put emphasis.  For
example, read the sentence "Why did you write it this way?" in the following
ways:

- Why did you _write it_ this way?
- _Why_ did you write it this way?
- _Why_ did you write it _this_ way?
- Why did _you_ write it this way?
- _Why_ did you write it _this way_?

Do you hear the difference? It's the same text, just read with different
emphasis.  As much as we hate to admit it, we're emotional creatures, and as
such we bring our emotions with us into whatever activities we do,
including reading.  If we've had a bad day or didn't sleep well, it's easy to
read feedback in a more negative light than what was intended. It's therefore
incumbent upon the reviewer to take extra care when writing comments.

By taking more time to clearly communicate what's good or bad about the code,
ask clear questions, and provide potential solutions, it reduces potential
back-and-forths between you and the submitter. This leads to faster development
times. Furthermore, adding clear explanations gives the submitter context and
insight into what you were thinking at the time of the review, reducing the
likelihood of them taking things the wrong way.

#### Critique the Code, Not the Coder

I've never seen this played out within an organization, but I've heard stories
and I've seen it in open source projects. I hate that I even have to mention it,
but reviewing code is not a time for the reviewer to play a game of "Gotcha".
Nor should it be used as an opportunity to belittle the submitter.

We all make mistakes and there isn't a single individual that gets to know the
right way to do everything. When a developer submits their code for review,
they're trusting the reviewer to be fair and provide honest and helpful
feedback. Don't betray that trust.

#### Compliment Good Code

The last thing to remember to do as a reviewer is compliment good work when you
see it. Simple comments like "That's cool!", "I didn't know you could do that!",
or even just, "Good job" can be great encouragements to the submitter. It
doesn't have to be done in every code review, but when you see something good,
call it out.

As my mom likes to say, "A candle loses nothing by lighting another candle."

### Receiving Feedback

> Choose not to be harmed — and you won’t feel harmed.</br>
> Don’t feel harmed — and you haven’t been.
>
> – Marcus Aurelius

The piece of the code review process is the hardest: it's how to receive
feedback. It's the hardest because it involves our emotions and our ego. Unlike
other creative endeavors which are subjective in their nature, programming has a
strong objective element to it. When an art critic gives a negative review of a
piece of work, the artist can always respond with, "The critic failed to see
my vision." With programming, on the other hand, a code reviewer can say a piece
of code is wrong and then provide evidence to support the argument. There isn't
a comeback for facts.

On a personal level, receiving code reviews is the most important part of the
code review process. It's at this point that you have the opportunity to grow.
Will you listen to the suggestions offered or disregard them? Listening will
require humility, you might have to admit that you're wrong about some piece of
your work. You might have to change how you've "always done it". But it's the
only way to grow.

In most cases, the feedback we receive is done with the best intent. Most of the
time we review code, we're just looking for potential problems – it's rare that
someone has a personal grudge against the submitter – so try to see it in that
light. Furthermore, both submitter and reviewer want the same thing: high
quality functioning software.

## In Closing

Code reviews are the most effective activity development teams can adopt to
drive down defects. Perhaps more importantly, they're the best activity your
team can engage in to transfer knowledge, increase overall development speed,
promote a healthy engineering culture, and build a sense of ownership within the
team. None of this should be underestimated, healthy engineering cultures
are far more effective at attracting and keeping the best developers.

When incorporating code reviews into your organization, remember these four
rules:

1. Everyone gets code reviewed
2. Everyone reviews code
3. Every PR gets reviewed
4. Every change gets reviewed

Whether your submitted code to be reviewed or have been asked to do the review,
remember foremost that your teammates all have the same goal: doing good work
and creating a great product. You're on the same team. Encourage one another,
hold each other accountable, and regardless of whether you're the submitter or
reviewer you have the opportunity to learn and grow from each PR. You just have
to be humble enough to do so.

## References

- [How to Perform a Good Code Review](https://blog.alphasmanifesto.com/2016/11/17/how-to-perform-a-good-code-review/)
- [Effective Code Review](https://alexgaynor.net/2013/sep/26/effective-code-review/)
- [Code Reviews: Just Do It](https://blog.codinghorror.com/code-reviews-just-do-it/)
- [The Unexpected outcomes of Code Reviews](https://codeclimate.com/blog/unexpected-outcomes-of-code-reviews/)
- [How to Conduct Effective Code Reviews](https://blog.digitalocean.com/how-to-conduct-effective-code-reviews/)
- [Thoughtbot Code Review README](https://github.com/thoughtbot/guides/blob/master/code-review/README.md)
