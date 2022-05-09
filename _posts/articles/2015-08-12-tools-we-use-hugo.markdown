---
title: "Tools We Use: Hugo"
author: "Samuel Mullen"
date: "2015-08-12T06:41:20-05:00"
description: "Hugo is the tool I use to build the SamuelMullen site."
tags: ["tools"]
---

Unlike many brochure sites on the web, this site is a static HTML site.
This means all the pages are created once, prior to deployment. It also means
my site loads in web browsers super fast.

There are some trade-offs, of course: WYSIWYG editors aren't built into the
tool we use to generate the site, we have to write content in a markup language
called [markdown](http://daringfireball.net/projects/markdown/), and each time a
change is made, every page affected has to be re-deployed.

Two of the three "trade-offs" are positives in my mind: I get to use the
same text editor I use for development ([vim](http://vim.org)); and markdown is
a very minimal markup language allowing me to keep my writing as close to pure
text as possible.

<img src="//samuelmullen.com/images/hugo-logo.png" class="img-thumbnail img-responsive center-block">

There's one more trade-off: as mentioned earlier, the site has to be
generated prior to deployment. Until recently, I've tried a couple ruby-based
solutions, but their sluggishness became more and more apparent on sites which
had numerous posts. I eventually settled on the [Hugo](http://gohugo.io/)
static site generator. It's stupidly fast, taking less than 700 milliseconds
to generator this site.

This solution is right for me, because it fits within my existing workflow
without disruption, but I would never recommend it to any of my existing or
previous clients; it's not the right solution for them.
