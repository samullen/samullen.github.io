---
title: 'Parallel Programming with Dropbox'
date: 2011-03-10
comments: false
post: true
categories: [dropbox, development, tdd]
---
[Dropbox](http://dropbox.com) is one of the greatest web applications in use today: it;s simple, it;s accessible, it;s ubiquitous, and it has a myriad of uses. I;ve written about using [Dropbox as a remote Git repository](//samuelmullen.com/2009/11/dropbox-an-unexpected-git-hosting-solution/) in the past, and other authors have [compiled lists](http://web.appstorm.net/roundups/data-management-roundups/10-more-killer-dropbox-tips-and-tricks/) of [unique](http://storecrowd.com/blog/dropbox-hacks/) and [interesting ways](http://lifehacker.com/#!5527055/the-cleverest-ways-to-use-dropbox-that-youre-not-using) to get the most out of it. The best explanation for it's popularity and prolific use was probably given on [Quora.com](http://quora.com): [Why is Dropbox more popular than other programs with similar functionality?](http://www.quora.com/Dropbox/Why-is-Dropbox-more-popular-than-other-programs-with-similar-functionality)

At a recent [KC Ruby Meetup](http://www.meetup.com/ruby-113/), in which we were duscussing [code retreats](http://www.coderetreat.com/), I had the idea of using Dropbox as a bridge to enable Test Driven Development between two (or more) developers. Here's how it might work:

* The developers work in a shared dropbox folder
* One developer writes the tests
* The other developer writes code to make the tests pass
* Each developer has some sort of autotesting suite running in order to pick up recent changes.
* As changes are made and as Dropbox syncs the folders, the autotesting suite(s) picks up the changes, runs the tests, and provides success/failure messages to the developers.
* Each developer then responds according to the the test outputs: writing more tests, writing code to make the tests pass, or refactoring.
* The developers can switch roles as needed.

I could see how two developers wouldn't necessarily even need to talk as long as the tests written well enough (but that would kinda suck.) But seriously, as long as the tests tell you what they are expecting, there's no real need to communicate.

This might not be the ideal environment to work in if you were building a serious project, but as a learning tool and as a playground, I think it could be a lot of fun. And honestly, I can imagine an entire site being built around the idea of programmers coming together to mentor each other and learn from one another.

### Further Reading:

* [Dropbox, An Unexpected Git Hosting Solution](//samuelmullen.com/2009/11/dropbox-an-unexpected-git-hosting-solution/) 
* [http://www.quora.com/Dropbox/Why-is-Dropbox-more-popular-than-other-programs-with-similar-functionality](http://www.quora.com/Dropbox/Why-is-Dropbox-more-popular-than-other-programs-with-similar-functionality)
* [http://web.appstorm.net/roundups/data-management-roundups/10-more-killer-dropbox-tips-and-tricks/](http://web.appstorm.net/roundups/data-management-roundups/10-more-killer-dropbox-tips-and-tricks/)
* [http://storecrowd.com/blog/dropbox-hacks/](http://storecrowd.com/blog/dropbox-hacks/)
* [http://lifehacker.com/#!5527055/the-cleverest-ways-to-use-dropbox-that-youre-not-using](http://lifehacker.com/#!5527055/the-cleverest-ways-to-use-dropbox-that-youre-not-using)
* [http://www.coderetreat.com/](http://www.coderetreat.com/)
