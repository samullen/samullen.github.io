---
title: The Team Refactor Meeting
date: 2022-04-11T06:10:30-05:00
draft: false
description: "With everything we have to do, is another meeting necessary? It is if you want to engage your engineering staff and taking ownership over the product they work on."
comments: false
post: true
categories: [management, teams, meetings]
---

Few engineers are immune to the siren's song to refactor a piece of code. The
idea of taking a block of crufty, unreadable, inefficient code and improving it
is too strong of an allure for most of us to resist. But what starts as a
refactor, more often  than not, results in a restructuring of the code. What's
the difference? As Martin Fowler is often quoted:

> Refactoring is the process of changing a software system in such a way that it
> does not alter the external behavior of the code yet improves its internal
> structure.
>
> -- Martin Fowler

Restructuring differs from refactoring in that it alters the external behavior.
Argument types and arity, function names, classes, and modules can all be
dramatically changed with a restructure. So can the return value.

I'm managing teams now, and aside from code reviews and the occasional one or
two point story, I rarely get a chance to write code, let alone refactor
anything. Nonetheless, I'm still captivated by refactoring; for the chance to
improve processes and code.

I first stumbled on the idea of the team refactor meeting–as I most often
do–after meeting with one of my team. In that meeting he made an offhanded
remark about getting together with the team to consider which areas of the
project needed the most work. Something about the way he said it gave me the
idea for an ongoing meeting to make everything about the way we work better.

## What is the Team Refactor?

Unlike refactoring code, the team refactor is a meeting used to review and
rethink the way your team and project operates. It's a time to address the pain
points we experience–but often ignore–in our project, processes, and the code
base. It gives us the chance to ask questions such as:

- Where are the problem areas in our code base?
- Where are the bottlenecks in the system?
- Which processes are we struggling with the most?
- What can we do to improve our communication?
- What would make the development experience better?
- Which process is the most difficult to understand?

It's tempting to confuse this with a retrospective, but the two are altogether
different. A retrospective focuses on the successes, failures, and lessons drawn
from a sprint or feature release, whereas the team refactor takes a step back to
look at the bigger picture, concentrating more on what can be done to make the
team more effective.

## How Does it Work?

The team refactor is a meeting, and should be held no more than once a month,
and no less than once a quarter (we hold ours on the last Friday of every
month). If it's held weekly or bi-weekly, it's difficult to see progress and you
risk it devolving into a gripe session. Anything less than once a quarter and
you'll lose engagement. I recommend basing the frequency of the meeting on the
amount of the team's technical or organizational debt.

To make certain there are topics to discuss, regularly remind the team about it
leading up to the meeting (such as in daily standups). It keeps the meeting "top
of mind", giving everyone time to watch for areas to improve. Make sure to keep
a list of your own topics in case things stall out.

You can run the meeting any way you prefer. What I've done so far is break it
up into three parts: Review, Propose, and Prioritize.

### Review

During the "review" section of the meeting, your job is to remind the team what
was covered in the last team refactor, highlighting which items the team
completed. If no progress was made, own up to it; it's better for morale if you
don't hide from it.

This part usually takes less than a third of the meeting.

**Note:** The "review" only works if you keep notes from one session to another.

### Propose

The bulk of the meeting should be dedicated to sharing and talking about new
ideas and topics. During this time, each team member should have something
they'd like to see improved, with the team lead or manager offering ideas after
everyone else or if no one is willing to open up.

### Prioritize

Use the last segment of the meeting to prioritize what the team plans to do.
Which of the ideas discussed this time and in prior meetings should be
tackled, and in what order? This part of the meeting should take the least
amount of time.

## What Now?

Once the meeting concludes, it's imperative you create stories to address the
problems the team brought up. There's no point in holding a team refactor unless
the team can execute on those items. If the team isn't allowed to
act, you'll deliver a gut punch to their morale. Don't do that. Instead, make
sure to schedule one or two items for work before the next team refactor. The
stories don't have to be completed, but they should at least be started.

## So What?

Refactoring attracts developers, because it's an opportunity to improve a
piece of code; a way of proving we can solve the problem better. It's the same
thing for the team refactor. It's coming together as a group, recognizing we can
improve every area of our project, and then setting out to do it.

For the engineers, this means making the work environment–be it the system,
processes, or codebase–more enjoyable to work in. They get to focus on solving
problems instead of fighting the system or struggling to untangle spaghetti.

For the manager or the lead, it means seeing the team more engaged by proving
that things _can_ get better and _are_ getting better. It also shows that you
hear and understand them.

I've run team refactors on two different teams for a year, and I can honestly
say it works. There may be griping in the first meeting or two about "yet
another meeting," but it settles down once everyone sees things improve.  Once
they see they're the ones responsible for that change–that they're the ones
driving it–they only want more. That's a good thing.
