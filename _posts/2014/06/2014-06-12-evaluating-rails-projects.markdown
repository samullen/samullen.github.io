---
title: "Evaluating Rails Projects"
description: "How to go about evaluating Rails projects starting from a high level perspective and then getting more specific."
date: 2014-06-12
comments: false
post: true
categories: [rails]
---

Ruby on Rails will be ten years old in December 2015, and a lot of things have
changed since that initial release. Although I'm sure there are some applications
which have been around since the initial release (anyone else besides
[Basecamp](http://basecamp.com)?), most "old" applications I run across as an
independent are 2.x or higher.

As these opportunities have come my way, I've found I need to know how to 
evaluate the projects to make the best choice for myself and my clients. You may
not be a freelancer, but you may still find this article useful if you are
considering working on an open source Rails project or taking a full time Rails
position and have an opportunity to look at the code base.

As you would evaluate anything, I start out looking at surface details and
slowly work my way in to analyzing the logic of the application. I take notes
along the way to aid me when I write up the formal evaluation I provide my
customers.

## High Level View

<img src="//samuelmullen.com/images/evaluating_rails_projects/worldview.png" class="img-right img-thumbnail">

Before getting yourself in too deep, rummaging around in files, looking at code,
and breaking things (intentionally!), I've found one is better served by getting
a feel for the application as a whole. You want to know the answers to the
following questions: 

* What versions of Ruby and Rails is the application running?
* What libraries are used?
* When was the last commit?
* Are there tests?
* Where is the logic?

### Finding the Versions

Answering the first question is easy enough: if there's a Gemfile, look for the
`rails` gem and what version it's set to. If there isn't a Gemfile, you can find
the version number by looking for the constant `RAILS_GEM_VERSION` in
`config/environment.rb`.

To find the version of Ruby the application runs, you can sometimes find it in
the Gemfile, but you'll usually find it in the `.rvmrc` or `.ruby-version`. If
you can't find the Ruby version, that should also tell you something.

### What Libraries are Used?

While you're in the Gemfile, it's always a good idea to find out exactly what
libraries are used by the application. Are they up to date? Is there a Gem for
everything under the sun? Are there competing gems?

<img src="//samuelmullen.com/images/evaluating_rails_projects/library.jpg" class="img-left img-thumbnail">

If a `Gemfile` hasn't been created for the application, you'll need to look in
`config/environment.rb` again. Be warned, just because a gem isn't listed in the
`environtment.rb` file doesn't mean it's not used by the app - it's one of the
joys of pre-Bundler apps - it may be required elsewhere in the application.
You'll usually find out what's missing by attempting to start the server.

Along the same vein as libraries, it's also useful to discover which plugins, if
any, are used. You can find these under the `vendor/plugins` directory in older
applications.

### Frequency of Updates

Knowing how frequently the application has been updated can give you an idea
about how important a project is to a person or organization. To find this
information - if the project uses an Source Code Management system (SCM) - look
at the SCM's log. You can do that with one of the commands below depending on the
SCM used:

* Subversion - `svn log`
* Git - `git log`
* Mercurial - `hg log`

If the project isn't under source control you may be limited to looking at the
timestamps of the files, but this should also be a warning to you about the last
developer(s).

While you're looking at the commit log, see if you can recognize the names of any
of the developers. Knowing who's previously worked on a project can make all the
difference when deciding whether or not to get involved.

### Are There Tests?

The easiest way to find out if there are tests is just to look under the `test`,
`spec`, or `features` directories, depending on what framework the previous
developers chose (there may be more than one). Just because test files exist
doesn't mean tests have been written, so you'll want to find out if the tests
are more than just boilerplate files provided by the framework. You can find that
out in one of two ways: you can manually look in each of the files, or you can
use the `wc` command (word count), but by passing the `-l` flag, it can count
lines in a file.

**Example:**

``` bash
$ wc -l test/models/*

...
     126 test/models/proposal_test.rb
     103 test/models/registration_test.rb
      47 test/models/search_test.rb
      91 test/models/service_estimate_test.rb
       4 test/models/service_template_test.rb
      28 test/models/service_test.rb
      51 test/models/user_registration_test.rb
     106 test/models/user_test.rb
    2239 total
```

The first column is the line count for the file. If all the files are between 10
and 15 lines, you can be sure they're just boilerplates.

### Where is the Logic?

Finding the logic is similar to determining if tests have been written. Unlike
what we search for with tests, however, here we're trying to discover two
things: 1) Where are the "god objects"?; 2) Is the application controller-heavy
or model-heavy?

<img src="//samuelmullen.com/images/evaluating_rails_projects/redstone.jpg" class="img-right img-thumbnail">

"God objects" are those classes which seem to get involved in every aspect of an application. I've written before about how to deal with them in [Delegation Patterns in Ruby](http://programming.oreilly.com/2014/02/delegation-patterns-in-ruby.html) over at [O'Reilly Media's blog](http://programming.oreilly.com). The simplest way to discover them is to look for the largest files in the `/app/models` directory. We can use the same trick we just used to look for tests, but we can pipe it to `sort` to more easily find the larger files.

**Example:**

``` bash
$ wc -l app/models/* | sort
       7 app/models/weight.rb
       8 app/models/department.rb
       9 app/models/location.rb
      11 app/models/position.rb
      12 app/models/role.rb
      13 app/models/comment.rb
      13 app/models/salary.rb
      15 app/models/rating.rb
      19 app/models/question.rb
      28 app/models/appraisal.rb
      30 app/models/company.rb
      69 app/models/notification.rb
      96 app/models/category.rb
     111 app/models/user.rb
     441 total
```

You can see here that `Category` and `User` will likely be involved in a lot of
the logic of the app. This isn't always the case, but we're just getting an idea
about the application. If none of the models were more than 15 lines long, that
would tell us that all the logic was being kept in the controllers. Speaking of
which...

You can use this same technique on the controllers directory. Here, though, what
we're looking for is how "fat" the controllers are. Controllers larger than 100
lines probably need to be refactored. Seeing a lot of fat controllers tells you
something about the state of the project.

### Other Things to Scan

* Is the README something more than the default? What does it say? Is it up to
  date?
* What's in the `lib` directory?

## Going Deeper

<img src="//samuelmullen.com/images/evaluating_rails_projects/goingdeeper.jpg" class="img-right img-thumbnail">

Oftentimes just scanning a repository will be all you need to determine if you
want to work on it. But there are other times when you're still on the fence.
In those cases, it makes sense to be more invasive.

### Will the Application Start?

This may seem like an obvious thing to do, and it is, but just getting a Rails
application to start can be very telling about the project itself. If it's an
older app, you'll discover missing libraries. If it's a newer project, what
deprecations and errors are you presented with. How long does it take to piece
everything together in order to start it? In any case, launching the program for
the first time should give you some idea of its state.

### Do the Tests Run?

We are Ruby developers after all; there should be tests, right? The state of the
tests suite (passing, failing, or non-existent) will give you ample information
about the project.

If there are no tests, or if the tests are so out of date as to be useless,
reconsider taking on the project (or upping your meds). It is a serious
undertaking to add tests to a project that has none. Although it is a simple
matter to add a test for some method, oftentimes that method will be bloated with
logic and need to be refactored. Is this really the kind of project on which you
want to work?

### How Complex is the Code?

<img src="//samuelmullen.com/images/evaluating_rails_projects/complexlogic.jpg" class="img-right img-thumbnail">

Arguably the best tool available for determining how much of a steaming pile of
filth you're going to have to deal with is the gem,
[flog](http://ruby.sadi.st/Flog.html). Flog is a tool to measure code complexity.
Although it has features similar to other code metrics tools, Flog is specific to
Ruby and is able to understand all of her Foibles.

To use flog, install it and run it against a directory such as `app/models`

``` bash
flog app/models/*rb
```

Without arguments, Flog retrieves the scores for the largest 60%. The output looks like this:

``` bash
  1265.4: flog total
     6.2: flog/method average

    57.3: AppointmentCalendar#to_ics       app/models/appointment_calendar.rb:8
    34.2: OrganizationClauseManager#move   app/models/organization_clause_manager.rb:17
    27.4: Area#none
    25.5: LineItem#none
    25.5: AreaService#none
    23.9: Lead#set_facility_variables      app/models/lead.rb:176
    22.7: Activity#all                     app/models/activity.rb:9
    ...
```

The higher the score, the more complex the code. For the `models` directory,
you'll want to see scores below 15. Scores above that may require investigation.
For the `controllers` directory, expect higher scores; good scores are less than
20.

There may be very good reasons for having high scores, but beware of applications
which have nothing but high scores.

## Other Things to Note

There are a few other minor things to make note of; none of which should affect
your appraisal.

### Javascript

An entire post could be written about evaluating Javascript in Rails projects - I
have no intention of writing it - but for now it's useful to know a couple
things:

* Does the project still use the old [Scriptaculous](http://script.aculo.us/)
  library or has it moved on to something modern?
* Have the JS libraries been kept up to date?
* What style of AJAX does the app use? RJS or JSON?

### Observers

I hate observers in Rails. I've written before about their evil twin
[callbacks](//samuelmullen.com/2013/05/the-problem-with-rails-callbacks/),
but observers are worse because they're so easy to miss. Like I said in the
aforementioned post, they're "kind of like ninja callbacks". 

When evaluating a Rails application, make sure to look for `_observer.rb` files
in the `models` directory.

### Non-standard Directories

Depending on the gems used by an application, or by the "ingenuity" of the
previous developers, there may be some non-standard directories under the `app`
folder.  Here are some of the directories I run into most frequently:

* `decorators`: usually created by the
  [draper](https://github.com/drapergem/draper) gem. These are classes which
  adhere to the decorator pattern.
* `presenters`: oftentimes created by developers wanting to follow the decorator
  pattern, but without the overhead of adding yet another library.
* `uploaders`: Created by the [carrierwave](https://github.com/carrierwaveuploader/carrierwave) gem.
* `overrides`: Not limited to [spree](http://github.com/spree/spree), but Spree
  makes heavy use of this directory.

## Conclusion

Much of what's been written above can be applied to any project. Almost
everything from the first section can be directly applied - although the state of
testing in other languages is...disappointing. With the exception of "Will the
Application Start?" and "Do the Tests Run?", the rest of the article is probably
moot, but there may still be some pieces which can be adapted to suit your needs.

As an independent Rails developer I'm faced with the decision of whether or not
to take on various projects. The decision's a lot easier if I'm dealing with a
new project, but if it's a legacy application, I need to know what I'm getting
myself into before I make a decision. Just because an application is in a
horrible state doesn't mean I'll not take on the project; it's more important for
me to have all the information necessary to make the best decision for myself and
my clients.
