---
title: The SQ3R Method and Reading Code
description: "Wherein I try to provide a more structured method for reading code in order to get the most out of it."
date: 2010-10-16
comments: true
post: true
categories: [methodologies, code, development]
---

Recently, John Nunemaker, authored a post about reading code, titled, "[Stop Googling](http://railstips.org/blog/archives/2010/10/14/stop-googling/)." His argument in the post - and one could hardly disagree with him - is that too often, we as programmers turn first to Google to answer our programming questions rather than turning to the code itself. By relying only on Google rather than doing the legwork ourselves we weaken our programming skill. You just can't become a better programmer unless you are actively and deliberately flexing your coding muscles. Reading code is one of the best ways to do this.

Nunemaker linked to Alan Skorkin's excellent post on reading code, titled "[Why I Love Reading Other People's Code and You Should Too](http://www.skorks.com/2010/05/why-i-love-reading-other-peoples-code-and-you-should-too/)". It's a worthwhile read. In it, Skorkin offers up a little bit of the "Why" and the "How" with regard to reading other people's code. Both of these posts got me thinking about how to go about systematically reading other people's code. That's when I remembered [SQ3R](http://www.studygs.net/texred2.htm). SQ3R is a study method for reading and stands for "Survey. Question. Read. Recite. Review."

Before I go further, let me state the obvious: reading other people's code isn't always easy. You will have to think; you will have to meditate; you will have to research; you will have to dig. It gets easier, but it will never be easy; few things worth doing are.

Here then is my adaptation of the SQ3R technique for reading code: Survey. Question. Research. Respond. wRite.

### Survey

The first thing you will want to do is get an overview of the body of code you are studying. The idea is to get a general feel for the layout and purpose of the code you are looking at. Here are some suggestions for how to survey code:

* Read all the comments
* Read all the code (it doesn't matter if you don't understand it)
* Write down functions and methods which are called, libraries, and anything else you are unfamiliar with
* Diagram the structure of a library, or in the case of an application the flow of information
* Write down any and all questions which pop into your head during this stage.

### Question

In the second stage, you will diving back into the code, this time to assault it with all manner of questions (see Rudyard Kipling's [Six Honest Working Men](http://www.kipling.org.uk/poems_serving.htm)). The questions you should be asking and writing down at this point are those which are trying to pull information out, (e.g. what is this function doing?) not putting information in, (e.g. how would I do this better?). Here are some questions to get you started:

* What problems is the code trying to solve (as a whole, as methods, as classes, etc.)
* What is this code doing?
* Why is the author doing *x* like that?
* Why might the author have chosen to do things this way?
* Where is the author's thought process leading?

### Research

At this point, it's time to interact more with the code. Remember all those questions you've been asking and writing down? This is where you start answering them. As you answer your questions, continue to ask more and answer them. Track down libraries and methods you aren't familiar with. Read up on them, and if they look interesting, make a note of them in order to study the code later.

By the end of this stage, you should really have a good idea of how the code flows, works, and what it's for. If you don't have a grasp on the code, keep researching - start over at "Survey" if you need to.

### Respond

The purpose of reading code is not to reach some level of technology enlightenment. Reading code isn't just an intellectual pursuit. If you're not applying what you're learning, you're wasting your time and you're depriving the community of another resource. The purpose of studying code, as with all studies, is to apply what you've learned.

Here's some ways you can respond to what you've learned in your research:<

* Refactor - find ways of improving the code and give it back to the author(s).
* Get involved - Don't stop at just fixing one bug or refactoring one method, start contributing regularly to the project.
* Answer questions - Mailing lists get a lot of questions and there are a lot of beginners who could use a hand (remember, you were there once too). Free up the core contributors' time by fielding a few of those questions.
* Fix bugs
* Document - You know the code, document what you've learned.

### write

You've now become very knowledgeable about the code you've been studying, it's time&nbsp;to share your experience. One way is to blog about what you've learned. But isn't that just enabling people who are using Google as a crutch? Yep, but it also helps those people who are using Google responsibly (that's you, right?)

But don't just write words, write some code. You've learned something new, you've grown as a programmer, it's time to write something new. Scratch your itch and inspire someone else.

If I may offer one last piece of advice: take your time. You don't have to sequester yourself away for weeks on end to read code. Just start by spending thirty minutes a day researching. You'll be surprised at how quickly you start picking up new techniques and new insights. And don't worry about reaching some sort of deadline, just focus on the doing. Pretty soon, it'll be a habit and you'll be a better programmer.
