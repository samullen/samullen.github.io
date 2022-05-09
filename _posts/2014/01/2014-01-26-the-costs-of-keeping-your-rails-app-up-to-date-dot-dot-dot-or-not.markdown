---
title: "The Costs of Keeping Your Rails App Up to Date...Or Not"
description: "A look into the three main reasons you need to keep you rails app up to date, and the costs therein"
date: 2014-01-26
comments: false
post: true
categories: [rails, upgrades, business]
---

Clients are always asking interesting questions. They're interesting, not always
because of the depth of the question, but because sometimes they force us to reevaluate our assumptions.

Recently I had a call with a company seeking a new maintainer for an existing
(i.e. legacy) Rails application. As I spoke with them and looked over the
application, it became evident that it was several versions out of date. As part
of the work they wanted, I recommended they also upgrade the application to a
more current version of Rails, to which they asked, "Why do we need to
upgrade?".

"Why do we need to upgrade?" is an interesting question. As a developer, I take
for granted the need to keep applications current, but for business people,
especially less technical ones, the need is less apparent. "After all", they
argue, "the application still works and does what we need it to do."

There are three big reasons to upgrade: security, performance, and
maintainability. Let's address these reasons and also look at the potential
costs of upgrading.

## Security

<img src="//samuelmullen.com/images/candace_in_panic_room.jpg" class="img-right img-thumbnail" title="I'm in my happy place">

The number one reason - and this is a **big** number one - you need to keep
your web application up to date is for security. There are a lot of very clever,
but malicious, people out there looking for new and interesting ways to
take advantage of even the smallest chink in a system's armor. If your
application isn't kept up to date, it's vulnerable to their attacks.

"But my site's small, no one even knows about us." This would be a great
argument if the bad guys cared about what site they hit, but they don't. They
have programs which scan the Internet looking for any site which might be vulnerable. When they find one, like a tick, they dig in. Things can get really bad at
this point.

If this happens to you, these are a just a few things you can look forward to:

* Compromised data: You won't have any idea what from your database or files
  have been modified, maybe nothing, maybe lots of things, but you can be sure
  it's all been copied.
* Control: Your system is under their control. This means they can be using
  your system to crack other systems. 
* Lawsuits: You may be on the receiving end of lawsuits for endangering your
  customer's data.
* Insurance: Chances are, your insurance policy doesn't cover "cyber" crimes.

The cheapest solution is to be proactive and make sure your application is kept
up to date with all the latest patches. If it's not, the bad guys'll use the
vulnerabilities you leave open. As they say, "It's not a matter of 'if', it's a
matter of 'when'."

Most security patches are super easy to install and may take as little as
15 minutes to download, install, and deploy. There's absolutely no reason not to
do this.

## Performance

If "security" is the number one reason to upgrade, then the second big reason is
"performance". Of course, this is a little tough to argue since there is
[evidence](http://www.codinginthecrease.com/news_article/show/86942) to show
upgrading from Rails 2.x to 3.0 incurred a significant performance hit. Since
then, however, effort has been put forth to improve performance, and we've seen
that with the Asset Pipeline, the Arel SQL engine, "Russian Doll" caching, and
more.

<img src="//samuelmullen.com/images/squirrel_power.png" class="img-right img-thumbnail" title="Squirrel power!">

But performance isn't merely limited to the applicaiton. As improvements are
made to the framework , developers reap the rewards with expanded and improved
features; features which reduce our development time (I can't even guess how
much time I've saved by using Arel, CoffeeScript, SASS, and the Asset Pipeline),
expand what we can do, and simplify our workflow.

Some time ago, Google showed us that [speed matters](http://googleresearch.blogspot.com/2009/06/speed-matters.html) and [directly affects your bottom line](http://blog.kissmetrics.com/loading-time/). It also been shown that a site's performance [directly affects its SEO](http://moz.com/blog/how-website-speed-actually-impacts-search-ranking). If that's not compelling enough, then what about the savings you'll reap in increased developer productivity? Is getting a few more hours of development time a month worth it?

## Maintainability

When looking for reasons why you should upgrade, it is sometimes argued that you
should upgrade your application so that it's easier to upgrade later. While this
argument isn't wrong, it is a tautology.

Unfortunately, the simple truth is that as an app's Rails version gets further
away from what is current, there are fewer and fewer developers who are able or
even interested in maintaining it. Furthermore, libraries and plugins used by an
application and which add functionality and features to the application also
fall out of maintenance - and do so much faster - as the creators focus instead
on newer versions of the framework.

By keeping your application up to date, you ensure that you'll have a larger
pool of developers who can maintenance your application. You also reduce the
numbef of hurdles needed keep the site running.

## Cost to Upgrade

So here's the big question: How much is this going to cost?

The cost to upgrading your application from its current state to the current
stable release depends on a number of factors:

* *Current version:* If your application has not been kept up to date, then it
  stands to reason that it's going to take more time than one which has.
* *Application size:* In the same way that a larger building or vehicle requires
  more maintenance than a smaller version of the same, so too a larger, more
  complex application is going to require more effort to maintain.
* *Usage of external libraries:* Most Rails applications use external libraries
  to simplify the addition of features. As an application is upgraded, the
  libraries it utilizes must also be upgraded. Many libraries fall by the
  wayside and so alternative methods of duplicating functionality must be
  sought out.
* *Test coverage:* This may be the biggest factor in determining the level of
  effort required to update a Rails application. Tests in an application serve
  a similar function to a body's nervous system; they help identify areas which
  aren't working correctly. When there is a comprehensive test suite, it is much
  easier to find what breaks with each incremental upgrade. If you don't have 
  that "nervous system" in place, finding what breaks becomes a much longer and
  arduous process.

<img src="//samuelmullen.com/images/entire_tristate_area.jpg" class="img-right img-thumbnail" title="This really has nothing to do with the post">

Most upgrades I've run across average between 6 and 10 hours of effort per
"minor" version jump. Of course, that time is affected by the factors mentioned
above, but these are general numbers.

With the added security, improved performance and faster development times, and
simplified maintenance, the real cost is not in the upgrade, but in remaining
with the status quo. 

By putting off upgrades you run the risk of a security breach, you allow your
application to be less performant, you hinder the ability of your developers to
work quickly and effectively, and you add to your application's future
maintenance cost.

So how much does an upgrade cost? Not nearly as much as not upgrading.
