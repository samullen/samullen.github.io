+++
author = "Samuel Mullen"
date = "2016-09-10T06:13:46-05:00"
description = "When ActiveRecord just isn't enough"
tags = ["rails", "ruby","arel","activerecord","sql"]
title = "More than Enough Arel"
canonical = "http://radar.oreilly.com/2014/05/more-than-enough-arel.html"
+++

**Note:** *This is the second article about the Arel library I wrote for
[O'Reilly Publishing's Radar blog](http://radar.oreilly.com/).*

In [Just Enough Arel](//samuelmullen.com/articles/just_enough_arel/), we explored a bit into how the Arel library transforms our Ruby code into SQL to be executed by the database. To do so, we discovered that Arel abstracts database tables and the fields therein as objects, which in turn receive messages not normally available in ActiveRecord queries. Wrapping up the article, we also looked at arguments for using Arel over falling back to SQL.

As alluded at the end of the previous article, Arel can do much more than merely provide a handful of comparison operators. In this post, we’ll look at how we can call native database functions, construct unions and intersects, and we’ll wrap things up by explicitly building joins with Arel.

Named Functions
---------------

With so many helper methods provided by the framework, doing things the “Rails Way” becomes second nature and we often forget the power the database holds. It’s often more performant to allow the database to handle the burden of our calculations and transformations, but it’s typically not possible with vanilla ActiveRecord. Arel, however, provides the solution.

To show how to take back this power, let’s pretend we need the MD5 hash of the “title” field of all the records from the “posts” table. This is the final SQL we’re expecting:

```
SELECT posts.*, md5(posts.title) AS md5_title FROM posts;
```

To achieve this final result, we can use Arel’s `Arel::Nodes::NamedFunction` The `NamedFunction` class takes three parameters: the name of the database function, a list of parameters to pass to that function, and an optional alias. The “alias” is especially helpful when used with ActiveRecord’s select: It provides a simple means to way to access the data.

The Ruby code which builds the SQL calling the md5 function follows:

```
Arel::Nodes::NamedFunction.new("md5", [Post.arel_table[:title]], "md5_title")
```

Passing `to_sql` to the above snippet results in the following SQL:

```
md5("posts"."title") AS md5_title
```

Named functions can also be nested within one another to perform a series of manipulations on the data. For example, if we wanted to perform the MD5 hash on the lowercase version of the posts’ titles, we could do the following:

```
lower_title = Arel::Nodes::NamedFunction.new("lower", [Post.arel_table[:title]])

Arel::Nodes::NamedFunction.new("md5", [lower_title], "md5_title")
```

And here’s the resulting SQL snippet:

```
md5(lower("posts"."title")) AS md5_title
```

Using the select method on our Post model, we can specify the fields we want to retrieve – in this case all of them – and the named function to execute. We now have the SQL we were trying to build:

```
Post.select(
  Post.arel_table[Arel.star],
  Arel::Nodes::NamedFunction.new("md5", [Post.arel_table[:title], "md5_title")
)
```

It’s easy to look at the code above, or that which follows, and assume a developer is better off sticking with raw SQL, but as we saw in the previous post, it’s easier, more readable, and results in less duplication to define methods to take the place of Arel’s method calls. With little effort, the previous snippet could be made to look like this:

```
Post.select(all_fields, md5(:title, "md5_title"))
```

Unions
------

There are occasions when what you really need is the combined data of two queries (i.e. a “union”), or the data of where those two queries intersect (i.e. an “intersect”). Just like SQL, Arel can do that.

In either case, using a “union” or an “intersect” is straightforward, being easily implemented in two parts: defining the union, and executing the union.

### Defining the Union

To create the union, we need to know the two ActiveRecord::Relation objects we want to join. We’ll send the first object the union message, passing in the second `ActiveRecord::Relation` object to union as an argument.

```
# For example only: you would typically use an "OR" here.
new_and_updated = Post.where(:published_at => nil).
          union(Post.where(:draft => true))
```

What’s returned isn’t an `ActiveRecord::Relation` object, it’s an `Arel::Nodes::Union` object, so treating it like an iterator won’t work (i.e. sending each is going to fail). This brings us to the second step.

### Executing the Union

Once we have our Union object, we need to execute it to access our data. To do that we must pass the object to the Post model as a “table alias”.

```
post = Post.arel_table
Post.from(post.create_table_alias(new_and_updated, :posts))
```

This final step returns the `ActiveRecord::Relation` object we want, allowing us to iterate upon it.

By default, "UNION" returns distinct records. To include the duplicates in the union, we can pass `:all` as the first argument to the union method, giving us a “UNION ALL” statement.

```
new_and_updated = Post.where(:published_at => nil).
          union(:all, Post.where(:draft => true))
```

Alternatively, executing an “intersect” instead of a “union” merely requires changing union to intersect.

```
new_and_updated = Post.where(:published_at => nil).
          intersect(Post.where(:draft => true))
```

Joins
-----

Although ActiveRecord is really good at handling most joins, it can be difficult to get “outer joins” to work, and it lacks the fine grain control we might otherwise have with raw SQL. The last thing we’ll look at then, is building joins with Arel.

The easiest way to construct joins in Arel is to break it up into three parts: defining the constraints, creating the join, and executing the query.

### Defining the Join Constraints

The first thing we’ll need to do is define the join’s constraint. If you were writing this in SQL, this would be the “ON” portion of the join; it defines how two tables relate. For our example, let’s join author’s to their posts. To do this, we’ll want to get the `arel_table` for each model and then define the conditions by which they relate.

```
author = Author.arel_table
post = Post.arel_table

constraints = post.create_on(
  post[:author_id].eq(author[:id])
)
```

The method is named `create_on` and that’s exactly what we’re doing: creating the “ON” syntax for the join. In this case, we’re linking posts to authors by way of the author’s ID.

Passing `to_sql` to the above returns the following snippet:

```
ON "posts"."author_id" = "authors"."id"
```

You can also chain multiple conditions together. This is especially useful when dealing with polymorphic tables.

```
constraints = post.create_on(
  post[:id].eq(comment[:commentable_id]).
    and(comment[:commentable_type]eq("Post")
  )
)
```

### Constructing the Join

Now that we have our constraint, we need to create the “join”. Remember, we’re not executing anything yet, Arel merely constructs the SQL which ActiveRecord sends to the database.

To construct the join, we need to pass create_join to our first table with the second table, constraints, and an optional join type as arguments.

```
# Inner join
join = post.create_join(author, constraints)

# Outer join for anonymous posts
join = post.create_join(author, constraints, Arel::Nodes::OuterJoin)
```

### Executing the Query

We’ve defined our constraints and constructed our join, the only thing left is to execute the query, and it couldn’t get easier; we just give the join we created to ActiveRecord’s `joins` method as an argument.

```
Post.joins(join)
```

If we needed multiple joins, we would just pass them as multiple arguments to the `joins` method.

```
Post.joins(author_join, comment_join, ...)
```

That’s all there is to it. Here’s the combined code for creating the join.

```
author = Author.arel_table
post = Post.arel_table

constraints = post.create_on(
  post[:author_id].eq(author[:id])
)

join = post.create_join(author, constraints)

Post.joins(join)
```

The purpose of the Arel library is to “simplify the generation of complex SQL queries” with Ruby. It’s able to easily handle comparisons, join multiple tables, construct unions and intersects, and it even provides a means to execute database specific functions. Arel delivers almost everything missing from ActiveRecord.

In these two posts we’ve covered everything you need to solve most of the problems you’re going to face with Rails and ActiveRecord. We covered some major components of Arel, but just as there’s much more you can do in SQL, there’s also more you can do with Arel. We could delve further into the library in a third post, but the only title remaining is “Enough with Arel, Already!”. Yeah, let’s stop here.
