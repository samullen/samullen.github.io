---
title: "Experiments on Rails"
description: "An introduction to a series of posts revolving around my experiments with Ruby on Rails"
date: 2015-02-26
comments: false
post: true
categories: [experiments_on_rails, rails]
---

<img src="//samuelmullen.com/images/experiments_on_rails/unclebob_madsci.jpg" class="img-thumbnail img-right">

At the 2011 Ruby Midwest conference, Uncle Bob Martin challenged those in
attendance to ask ourselves what the architecture of our apps should really look
like. Does having a directory full of "models", "controllers", and "views" give
us any insight into what our apps do? Or is it instead like looking at a city
full of cookie cutter buildings. How do you know what an application (or
building) does without going inside?

Four years have passed since Uncle Bob gave that presentation and our Rails
apps still default to the same basic layout. However, many developers have since
asked the question, "Have we allowed ourselves to be unnecessarily constrained
by the defaults?" This isn't to say Ruby on Rails itself is to blame for the box
we've found ourselves in - far from it - it's a box of our own making, because
we saw the defaults and assumed that's the *only* way to do things.

Here's a simple example of what I mean: when you create a table through a
migration, did you know you can define the `limit` of a string field in a table
to something greater than 255?  It's true, 255 is just the default set by Rails;
the real limit is defined by your database.

``` ruby
# Try it out

class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title, :null => false
      t.string :content, :limit => 4096, :null => false
      t.timestamps
    end
  end
end
```

What about REST and CRUD? Doesn't it feel like a 1:1:1 ratio must exist between
your database schema, models, and controllers? One table must correspond to one
model and have one controller.

Are we really following the "Rails Way"? Or are we following the path that's
most comfortable? Developers like Piotr Solnica, Sandi Metz, Corey Haines, and
many others have argued that it's the latter, and that we need to push back on
the Rails conventions by adhering to stricter OO design principles, and letting
business rules dictate the development process rather than the underlying
technology.

<img src="//samuelmullen.com/images/experiments_on_rails/badtime.jpg" class="img-thumbnail img-right">

But going against convention can be hazardous; worse, it can take time. 

I want to put into practice what I read from the Ruby-famous, but I also have
work to do, and asking a client to use their next project as an experiment
doesn't seem like a recipe for success. I'm just not [that type of
freelancer](//samuelmullen.com/2015/02/the-12-freelancer-archetypes) (see
Mad Scientist). 

What I need is a project on which to experiment; an application which can grow
large enough to explore edge cases and find pain points, but one which doesn't
affect business.

To meet this need, I'm creating is a traditional e-commerce site, one experiment
at a time, and not with the goal of creating a feature complete application,
but rather to see what works and what doesn't. The e-commerce bit, is just to
provide structure and purpose.

Throughout the project, I will be following Sandi Metz' rules:

* Classes can be no longer than one hundred lines of code.
* Methods can be no longer than five lines of code.
* Pass no more than four parameters into a method. Hash options are parameters.
* Controllers can instantiate only one object. Therefore, views can only know
  about one instance variable and views should only send messages to that object

I will also be adhering to these rules:

* Controllers, and especially Views, are not allowed to directly access
  `ActiveRecord` objects.
* ActiveRecord models must only contain associations, validations matching
  what's in the schema, and scopes.

<img src="//samuelmullen.com/images/experiments_on_rails/its_alive.jpg" class="img-thumbnail img-right">

There is a [GitHub repo](https://github.com/samullen/experiments_on_rails) for
the project, and each article will have a corresponding branch. Feel free to
comment on the project, or add issues and even provide Pull Requests; I'll use
what I can in followup articles.

As I run across articles or ideas, I'll create a new experiment. Some
experiements will get merged into master, and some won't. Every experiment will
keep it's own branch.

<div class="clearfix"></div>
