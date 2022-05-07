---
title: The Google Fast
date: 2019-05-08T21:36:40-05:00
draft: false
description: "Is there anything to be gained by not using search engines? Do we rely on them too much and think too little?"
comments: false
post: true
categories: [productivity]
---

I'm amazed at how frequently I still tell people to "Google it," "ask Alexa," or
just "look it up." Just today my son told us his teacher asked the class what
"Yeet!" meant. Meanwhile I'm thinking, "Why didn't she just type 'define yeet'
into a search engine." If it wasn't for [DuckDuckGo](http://duckduckgo.com/),
[UrbanDictionary](https://www.urbandictionary.com/), and having a clue about
video games, I'm not sure I'd even be able to hold a conversation with him.

After 20+ years of having the answers to all our questions immediately at our
fingertips, you'd think we'd be quicker to search than we are. This got me
thinking, "Maybe I'm _too_ quick to search. Maybe I'm searching too much and
_thinking_ too little."

Early in my software development career, [Google](https://google.com) didn't
exist. We had [Yahoo!](https://yahoo.com), but the internet was young enough
that there wasn't much useful content. Blogs hadn't yet become a thing, and so
you were left to search through newsgroups, or even worse, ask a question on
one. Instead, I owned a lot of books, read a lot of documentation and man pages,
and basically muddled through as best as I could.

This isn't an article romanticising the "good ol' days". They were good, but
being a programmer today is better. A lot better. Still, I began to wonder
what it would be like to take one day a week and go without all the search
amenities of the modern programmer. What if I couldn't "google" a question,
search [StackOverflow](https://stackoverflow.com/), or even search through
issues on [GitHub](https://github.com)? Could I do it? What would I discover in
the process?

## What I Wanted to Learn

It wouldn't be much of an experiment if I didn't have some theories I wanted to
test. These are the questions I wanted to answer:

### How will this affect my thinking?

I believe that above every other reason, the challenge of solving problems is
what draws people to programming. It's certainly what I enjoy the most, but what
if I was robbing myself of the joy of solving problems by seeking out answers
from others instead of attempting to solve them myself?

This isn't a "not invented here" issue, it's more of a mental fitness issue.
What effect, if any, will a day of fasting have on my ability to reason and
problem solve? Will this weekly exercise strengthen my thinking? Will I find
greater enjoyment in tackling problems which might otherwise already be solved?

### How will this affect my learning?

I read a lot, and while I learn a lot from what I read, I don't retain most of
it, because I don't always put what I learn into practice. It's the "practice"
which translates the theoretical into the practical. Unless I take the time to
understand what I find from the search results I miss out on not only how to
solve the problem, but possibly the steps the author used to reach his or her
conclusion. Unfortunately, I usually don't take the time; I don't think I'm
alone in that.

By taking a fast from these instant answers, I'm hoping the required extra
effort will not only improve my thinking, but also force me to learn about my
chosen technologies more deeply.

### How much will it slow me down?

This is the big issue. I'm a firm believer that the [three virtues of a
programmer](http://threevirtues.com/) are **laziness**, **impatience**, and
**hubris**. I pride myself on getting work done quickly and correctly, and
slowing down because I've arbitrarily limited myself might drive me mad. More
worrisome, it might drive [my employer](https://spartan.com) mad.

Will fasting from prepackaged solutions actually slow me down? Oftentimes what
I search for are answers I already know, I just don't remember the specifics off
the top of my head, or I'm looking for an alternative approach. So will fasting
hinder my productivity?

### How will it affect decision making?

As I've thought about this experiment it occurred to me that sometimes I
perform a search not because I don't know the answer, but because I'm hesitant
to decide on the answer and I'm looking for confirmation. Worse still – if I'm
honest with myself – I'm often looking for someone else to make the call; to
take responsibility.

This experiment is about uncovering and working on weaknesses. Not making
decisions and not taking responsibility is a weakness. I'm going to use this
experiment to highlight those times I'm vacillating between options and use it
as an opportunity to strength my decision making skills.

## Rules

For an experiment to be successful there needs to be some constraints. These
are the rules I'll be following:

### One Day a Week

I still have a job to perform, so I've decided to take one day a week to fast.
I've chosen Wednesday, because I'm able to be heads down all day and
rarely experience interruptions.

If you're playing along with the home version, I'd suggest avoiding fasting on
days which are high intensity: meetings, deployments, interviews, etc.

### What's Allowed

I'm allowing myself the following resources:

- **Documentation:** This includes man pages, language and framework
  documentation, and other technology documentation.
- **Books:** Books are very similar to documentation in that they explain how to
  use a technology, but rarely provide the perfect answer for a problem you are
  looking for. They also require some amount of research to be able to form your
  own conclusion.
- **Source code:** Is there a better way to understand your technology of choice
  than to see exactly how it's built?
- **DuckDuckGo bangs:** This sounds weird, I know, but I use DDG's "bangs" to
  access [GitHub](https://github.com) and documentation sites.
  - Examples:
    - `!hexpm timex`
    - `!gh phoenix`
    - `!gem rails`
- **Non-work related searches:** This experiment is about focusing on solving
  work related problems. Searches for places to eat, movies, stupid trivia
  questions, or images for a presentation are allowed.

### What's Not Allowed

The following resources are not allowed:

- **Personal blogs:** Often when we search for answers we wind up on the
  personal blog of someone who's solved the problem. No personal blogs are
  allowed during the fast. The point is to figure out problems yourself.
- **Search engines:** Yes, I'm calling this a "Google Fast", but that's for
  marketing. I'm also including [DuckDuckGo](https://duckduckgo.com) and the
  other ones as well.
- **Answer sites:** [StackOverflow](https://stackoverflow.com),
  [Quora](https://quora.com), and the like are off limits. No easy answers!
- **Forums:** Like answer sites, forums offer an easy way to get answers instead
  of researching and discovering them yourself. I'm including things like GitHub
  issues in this as well.

### No Cheating!

The number one rule is **No Cheating!** I started my career without an infinite
array of easy answers, I can survive one day today without them too.

## The Results

### Week 1

It figures. The first day I run my experiment, and there was literally nothing I
needed to search for. There was one thing I briefly thought about looking
up, but as soon as the thought occurred I remembered the fast and quickly
realized I could solve the problem with a little Unix-fu.

I did search for a Paul Graham quote for a non-work related conversation. I also
searched for images to use in a presentation, but both items are out of scope
for the experiment.

### Week 2

The second Wednesday was a complete bust. It was February and I got hit with a
2-day flu. I was out cold. There was no searching, only fever dreams and
Netflix.

### Week 3

Like week 1, I literally had no need to search. I don't know if this speaks more
to my competence or the simplicity of the problems I was working on.

### Week 4

I cheated. I think.

I was writing tests for an API client and I needed to know how to mock out the
the HTTP library. I knew Elixir could do it with behaviors, but I wasn't finding
what I was looking for in the documentation. However, I knew Elixir's creator,
José Valim, had an article detailing exactly how to do it.

I had the article bookmarked and I used it for reference. I may have been able
to figure it out if I spent more time on it. I let myself get fixated on an
imaginary deadline.

### Week 5

I was having trouble creating records through an association using
[Ecto](https://github.com/elixir-ecto/ecto), Elixir's data mapping library. For
the life of me, I couldn't figure out why it kept erroring on the `inserted_at`
date. I was really tempted to do a search, but I resisted.

I don't think I would have found the answer with a search. It turns out that I
forgot to add the `timestamps/1` function in the schema. I only discovered that
by paying closer attention to the error message. Duh.

### Week 6

Again, it's another day without a need to search, but I've noticed that even on
non-fasting days I'm now slower to look for the easy answers. Was it really a
day I didn't need to search, or am I building a habit of choosing alternatives?

### Week 7

Today was a turning point. In the past when I would see an error message I was
unfamiliar with, I'd use a key phrase from the error message to perform a
search. Today, instead of searching the internet, I opted to search for the
string in the library's code.  I found the answer in a test and also learned
several other features on the library in the process. Had I searched as normal,
I may have found a fix for my problem, but I definitely would have missed out on
what I learned.

### Week 8

I was working with [Looker](https://looker.com) today, and even thought it's not
really coding, I continued to follow my rules for the fast. I don't remember the
specific problem I was facing, but forced myself to stick to the documentation
rather than look through the forums. Wasn't a hard call, most SaaS forums are
rubbish.

## Conclusions

I went into this experiment wanting to know how limiting myself from easy
answers would affect my thinking, learning, productivity, and decision making.
While eight days isn't enough time to gather conclusive evidence for any
experiment, it was enough to see patterns emerge.

Because I began paying attention to my search habits and which sites were
restricted, I found myself less likely to follow easy links even outside of the
days of fasting. More than that, I also noticed a change of attitude in myself
toward sites like StackOverflow, Quora, and forums. I began to see using them as
a weakness. Mind you, I'm not saying using these tools are a weakness, per se,
but rather I perceived them as hindering me on my journey to improve.

Although my thinking was affected in a rather unexpected way, I can happily say
that as I had hoped, the fast encouraged learning. By relying more on
searching through source code I was 1) always able to find the solution to my
answer; and 2) discovered new techniques and parts of Elixir I didn't even know
to ask about. This is to say nothing of what I learned merely from thinking
through problems and reading the documentation more thoroughly.

Here's the big question: did the fast hinder my productivity? I don't think so,
but that's not a question that can easily be measured. Part of why I don't
believe it slowed me down is that both Elixir and Phoenix are relatively young
technologies; more than that, however, is that they are used by a small
percentage of developers. I mention this, because older, more widely used
technologies have more written about them and so finding answers is easier. If
there are fewer questions/answers available then it might be faster to start off
with the documentation and source code rather than trying to phrase your
question just so to find the perfect link.

The last question I wanted to answer was "how will the fast affect my decision
making?" I can't say I was able to tell a difference, nor did I experience a
moment which stood out in that regard.

## What Now?

Now that the fast is over, what happens? Will I continue limiting myself to
source code and docs, or will I slide back into the path of least resistance?
It's hard to say for certain: old habits die hard. I like what I discovered
about myself, and I liked the confidence that came from searching through the
source to answer my questions and uncover hidden gems. Now that I see more of
what my own capabilities are and the joy of uncovering knowledge, it's difficult
to imagine taking the same old path.
