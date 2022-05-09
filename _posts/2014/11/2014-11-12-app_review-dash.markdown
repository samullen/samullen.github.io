---
title: "App Review: Dash"
description: "A review of Kapeli's Dash: the API Documentation Browser and Code Snippet Manager. tl;dr: It's brilliant!"
date: 2014-11-12
comments: false
post: true
categories: [reviews]
---

**Developer:** [Bogdan Popescu](http://kapeli.com/dash)  
**Platform:** Mac (iOS coming soon)  
**Price:** [Free ($19.99 - full license)](https://itunes.apple.com/us/app/dash/id458034879)

<img src="//samuelmullen.com/images/app_reviews/dash-icon.png" class="img-thumbnail img-right">

I purchased Dash in mid-2013 in a fit of frustration with Xcode's documentation,
and since then it's become indespensible to my daily workflow. Dash's developer,
Bogdan Popescu, summarizes his application as "... an API documentation browser
and code snippet manager." More fully, Dash allows you to access the documention
from the frameworks, APIs, languages, and libraries you use, through a single
interface, and it does so wickedly fast.

At first, I only used it to reference the Cocoa and Rails documentation, but it
didn't take long before I added docs for jQuery, Vim, tmux, Go, PostgreSQL,
MySQL, man pages, Markdown, and so many more. Now I can't imaging trying to use
any other system or tool for finding and accessing documentation, regardless of
whether that documentation is web-based or native to an IDE. Dash is just too
good.

# Documentation

Let's begin with Dash's most obvious feature: documentation. After installing
Dash, you'll first want to select and download some "docsets" (the Downloads
tab in user preferences). Docsets are just collections of documentation for a
given language, library, or framework. Once you've selected your desired
docsets, Dash downloads the content to your machine and indexes it so it's
always available.

<img src="//samuelmullen.com/images/app_reviews/dash-downloads.png" class="img-thumbnail">

Now that you've downloaded your desired docsets and Dash has had an opportunity
to index them, searching for the right class, method, or command becomes easier
than ever. Dash uses a "fuzzy finder" to search documentation, so when you type
"strng" in the search field, it pulls up every piece of documentation matching
"s", "t", "r", "n", and "g" (in that order) in the documentation headings. If
you've selected docsets similar to mine, you'll see titles like "NSString"
(iOS), "strong" (HTML), "starting.txt" (Vim), and others.

<img src="//samuelmullen.com/images/app_reviews/dash-search.png" class="img-thumbnail">

You can also limit your search to a specific docset by typing its customizable
keyword followed by a colon (:) in the search field. If you're looking for the
docs on Swift's `Array` library, you'd type "swift:array." Dash will then
display the documentation of the first result in the main window as well as its
table of contents in the bottom left frame, breaking it down by class and
instance methods.

<img src="//samuelmullen.com/images/app_reviews/dash-keyword_search.png" class="img-thumbnail">

There are currently more than 150 API docsets, but Dash can also download and
index cheat sheets, 3rd party docs (i.e., libraries), and even user contributed
docsets. If Dash is unable to find results from its local database (i.e., the
docsets you've downloaded) to match your query, it then falls back to searching
[Google](http://google.com) and [StackOverflow](http://stackoverflow.com).

It's rare for developers to reference only a single source of documentation.
Instead, we're much more likely to switch back and forth between a number of
pages and technologies, and Dash allows us to do just that with tabs. Tabs work
similarly to those in web browsers. Unlike web browsers, however, Dash does not
currently support saving tabs between sessions. This means that if you have a
number of tabs open and you close the app, when you restart it, you will be
greeted with a single tab containing the default start screen.

# Snippets

Dash also supports the use of snippets, which I've only recently starting using.
If you're familiar with applications such as
[TextExpander](http://smilesoftware.com/TextExpander/index.html) or
[aText](http://www.trankynam.com/atext/), then snippets will already be familiar
to you. If you're not, snippets allow you to create an alias for a block of code
or text, and whenever you type that alias in an application, Dash replaces the
alias with what it represents.

<img src="//samuelmullen.com/images/app_reviews/dash-snippet.png" class="img-thumbnail">

So, if I type "aeq," I'll be prompted with a screen where I can fill in a
couple variables, and dash will then replace the "aeq" with the block of code.

A word of warning: using snippets will cause the Dash window to disappear. The
app doesn't quit, but you will need to reopen the window. (Cmd-Tab works well.)
Bogdan told me in an email, "It has to be this way otherwise the window is
brought to front sometimes when you expand and it makes the snippet expansion
experience a bit weird."

# Plugins

I use OSX's Spaces feature and keep Dash open in the third space; just a
keyboard shortcut away for me. Of course, this isn't everyone's preference. Many
people want their documentation built into their development environment. Dash
can do this with "plugins." 

<img src="//samuelmullen.com/images/app_reviews/dash-plugins.png" class="img-thumbnail">

At a basic level, you can highlight a snippet of text in any application,
right-click, and select "Services → Look Up in Dash." This will open Dash (if
closed) and perform a search on the selection in the currently open tab. 

Alternatively, you can integrate Dash more fully into your environment by
installing any of the many available plugins. The plugins are created by
third-party developers, so what they each have to offer is going to vary.

If that's still not enough, Dash's plugin system takes advantage of URL
Schemes, so it's a simple matter to write your own. The scheme looks like this:

``` bash
dash://query

dash://keyword:query
```

Using this, we can even access Dash from the command line using the Mac's `open` command:

``` bash
open dash://swift:hashable
```

Dash has made my development process better. It gives me almost instantaneous
results, documentation for an ever increasing collection of technologies, easy
to use code snippets, and it interfaces with my existing workflow and
development environment. I use it almost as much as my text editor, and
far more than Google. It's just that good. I can't wait to [see what Bogdan has
planned for iOS](http://blog.kapeli.com/sneak-peek-dash-for-ios).
