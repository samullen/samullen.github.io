+++
author = "Samuel Mullen"
date = "2016-09-09T21:36:28-05:00"
description = "Replacing hand-coded SQL with object oriented programming"
tags = ["rails", "activerecord", "ruby", "sql", "arel"]
title = "Just Enough Arel"
canonical = "http://radar.oreilly.com/2014/03/just-enough-arel.html"
+++

**Note:** *I originally wrote [Just Enough Arel](http://radar.oreilly.com/2014/03/just-enough-arel.html) for [O'Reilly Publishing's Radar Blog](http://radar.oreilly.com/) in early 2014. I'm reposting it here because we frequently reference the article and our site loads faster.* :)

If you were a web developer prior to ActiveRecord, you probably remember rolling your own SQL and being specific about which fields you retrieved, writing multiple queries to handle “upserts” (update or insert), and getting frustrated with how difficult it was to generate SQL dynamically.

Then Ruby on Rails came along with its ActiveRecord API, and all of that pain seemed to melt away into distant memory. Now we no longer have to worry about which fields to retrieve, “upserts” can be handled with a single method, and scopes allow us to be as dynamic as we want.

Unfortunately, ActiveRecord introduced new pains: the “WHERE” clause (i.e. the predicate) only allows connecting conditions with “AND”s, and the only comparisons allowed are “=” and “in”. To get around this, we often concede ActiveRecord’s shortcomings and revert back to raw SQL. But in Rails 3.0, we were introduced to another way.

Arel
----

The [Arel relational algebra library](https://github.com/rails/arel) is an [abstract syntax tree](http://en.wikipedia.org/wiki/Abstract_syntax_tree) (AST) manager and has the goals of “1) Simplif[ying] the generation of complex SQL queries; and 2) Adapt to various RDBMSes”. It’s the “engine” ActiveRecord uses to change method calls into actual SQL. To be clear, Arel only generates SQL, it doesn’t access the database and retrieve data.

With Arel, we are now capable of fully utilizing the power of SQL, without the mess of hand-coding it. ActiveRecord uses Arel to transform queries like this:

```
Post.joins(:comments).
  where(:published => true).
  where(:comments => {:flagged => true})
```

Into SQL like this:

```
SELECT "posts".*
  FROM "posts" INNER JOIN "comments" ON "posts"."id" = "comments"."post_id"
 WHERE "posts"."published" = true
   AND "comments"."flagged" = true
```

Arel Table
----------

The primary class you will deal with when working with Arel is the `Arel::Table`. This class represents an abstract idea of a database table, and when you get an instance from a model you have a representation of that model’s table. In terms of SQL, you might think of this as the table used in a “FROM” clause.

Once we have an `Arel::Table` instance we can specify fields and functions we want to retrieve, build up how we connect with other tables, and define conditions on the table’s attributes.

You can retrieve a model’s `Arel::Table` instance by sending the `arel_table` class method to an ActiveRecord model like this: `Post.arel_table`. Oftentimes, however, it’s more convenient to create a helper method to eliminate some verbosity. The example below is designed to be used in the context of a scope within an ActiveRecord model.


```
def self.post
  self.arel_table
end
# Force the class method to be private (optional)
private_class_method :post 
```

Arel Attribute
--------------

In the same way an instance of `Arel::Table` represents a specific database table, an instance of `Arel::Attributes::Attribute` represents a field within that table. Although we could use it in a select message to a Model, the most common practice is using attribute instances to build our query’s predicate.

Arel attributes are instantiated from an `Arel::Table` instance by passing the attribute name to the `[]` method, just like you would to a Hash. For example, if we were to call `Post.arel_table[:published_at]`, it would return an `Arel::Atributes::Attribute` instance for the `published_at` field of our table.

Once you have an instance of `Arel::Attributes::Attribute`, you can pass any number of comparison operators to the object, and doing so allows you to build your query, the output of which we can see by appending a to_sql message to the end.


```
Post.arel_table[:published_at].gt(1.year.ago).to_sql

# => ""posts"."published_at" > '2013-03-16 19:56:14.101954'"

Post.arel_table[:title].matches('%updated')

# => ""posts"."title" ILIKE '%updated'"

# Combined with an "OR"
Post.arel_table[:published_at].gt(1.year.ago).
  or(Post.arel_table[:title].matches('%updated')).to_sql

# => "("posts"."published_at" > '2013-03-16 20:00:16.797360' 
#      OR "posts"."title" ILIKE '%updated')"
```

See the GitHub repository for [the full list of comparison
methods](https://github.com/rails/arel/blob/24995298face1d08ffb52f6c1b0374feeb7a380b/lib/arel/predications.rb).

As you can see, in each instance above we’re just generating just a portion of SQL; a portion we can then send to our ActiveRecord’s where method.

Predicates with Arel
-------------------

As you know by now, ActiveRecord uses Arel to transform messages into SQL which are then run against the database. It takes a Hash as part of its constraints (i.e. where clause or predicate), it accepts snippets of SQL, but it can also receive Arel objects. It can do this because, as was shown above, Arel is easily changed into portions of SQL.

Let’s look at an example. Pretend we have the prototypical blog application and we want to retrieve all posts published within the last year, or that have “updated” at the end of the title.

The query in SQL might look like this:

```
SELECT posts.*
  FROM posts
 WHERE posts.published_at > (now() - INTERVAL '1 year')
    OR posts.title LIKE '%updated';
```

To create this same query in ActiveRecord, we would need to write it like what is shown below, because ActiveRecord just doesn’t have the ability to handle value comparisons, “OR” conjunctions, or string matching:

```
Post.where(["posts.published_at > ? OR posts.title LIKE '%updated'", 1.year.ago])
```

However, using a combination of ActiveRecord and Arel, we can write this same query without a single line of SQL:

```
Post.where(
  Post.arel_table[:published_at].gt(1.year.ago).
    or(Post.arel_table[:title].matches('%updated')))
```

We can further simplify this by using the “helper method” discussed in the Arel Table section above.

```
Post.where(
  post[:published_at].gt(1.year.ago).
    or(post[:title].matches('%updated')))
```

Why Use Arel Instead of SQL?
--------------------------

This raises the question: if there is little difference between passing strings of SQL to an ActiveRecord query and passing Arel objects, why use Arel? The same question could be asked of ActiveRecord itself.

While researching this, I discovered this question isn’t unique to Arel and ActiveRecord, but is commonly asked of any ORM, and for every argument made there is an equally compelling rebuttal.

However, I believe these arguments provide enough justification to move away from hand-coding SQL and toward an Arel’s object oriented solution:

Reliable: Column names are used time and time again across tables. id, created_at, and updated_at are examples, and unless they are properly qualified, it could result in an “ambiguous column reference” error. Arel mitigates this possibility.
Simple: The object oriented nature of Arel allows queries to be more easily broken up into smaller more manageable chunks.
Flexible: It is easier and more consistent to build up your query using Arel methods rather than using string interpolation and concatenation.

Enough Already
--------------

There’s a reason Rails developers fall back to SQL instead of Arel. It might be they don’t know about it, or if they do, perhaps the lack of documentation and posts about it have made it too inaccessible for them. It could be that the need to just “get things done” has kept Arel at arms length; but it doesn’t have to be this way.

In this article we’ve looked at the `Arel::Table` and `Arel::Attributes::Attribute` to see how Arel models our database, and we’ve seen how to use those objects to build up our queries’ constraints. We’ve even looked briefly at the reasons why one would choose Arel over writing SQL manually.

But this is not all that Arel can do. It is designed to “simplify the generation of complex SQL queries” and to be a framework with which “you can build your own ORM”. Unions, named functions, complex joins, and more are all made possible with Arel, but this was meant to be “just enough Arel”.
