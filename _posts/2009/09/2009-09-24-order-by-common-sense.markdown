---
title: ORDER BY common sense;
published: true
date: 2009-09-24
post: true
categories: [ activerecord, mysql, sql]
---

Being that I am a programmer and I work and associate with programmers and I follow the trends of programming and technology, I oftentimes forget that the average person does not. I become acutely aware of my disconnect when speaking with non-techies. They'll smile and nod as if to say they understand, but the glazed and confused look in their eyes make it apparent that I have slipped into "geek speak" yet again.

My wife, being a technical trainer and writer, is technically savvy and can usually understand or at least follow my conversation. Where she differs from me is that she can look at things from a non-techy perspective. Where she differs from the non-techy is that she'll ask those probing questions which highlight how disconnected I am. An instance of this happened last night.

I've been working on a contract for a chemical engineering company ([Citadel Technologies](http://cittech.com)) for the past few months and the project is moving into the documentation phase. This is where my wife comes in; she's writing the courseware. When showing her a page which lists the sizes of steel pipe in the database, she asked why it wasn't ordering the data correctly. I told her it was ordering correctly: first by size, then by schedule. See for yourself:

``` bash
+------+----------+----------------+----------------+
| size | schedule | outer_diameter | inner_diameter |
+------+----------+----------------+----------------+
|    1 | 10       |         0.0394 |         0.0394 |
|    2 | 10       |          2.375 |          2.157 |
|    2 | 160      |          2.375 |          1.687 |
|    2 | 40       |          2.375 |          2.067 |
|    2 | 5        |          2.375 |          2.245 |
|    2 | 80       |          2.375 |          1.939 |
|    2 | STD      |          2.375 |          2.067 |
|    2 | XS       |          2.375 |          1.939 |
|    2 | XXS      |          2.375 |          1.503 |
|  2.5 | 10       |          2.875 |          2.635 |
|  2.5 | 160      |          2.875 |          2.125 |
|  2.5 | 40       |          2.875 |          2.469 |
|  2.5 | 5        |          2.875 |          2.709 |
```

Then she pointed out the obvious: schedule is ordered funny. I explained that it's ordered ASCIIbetically. And that's when I realized what I had done; I forgot to develop for the user.

So how do you go about ordering a field in a way that makes sense. After searching around on Google for about 10 seconds, I came up with this (Note: only works in MySQL):

``` sql
SELECT size, schedule, outer_diameter, inner_diameter
  FROM pipe_sizes
 ORDER BY size, schedule regexp '[0-9]', 0+schedule, schedule;
```

The result:

``` bash
+------+----------+----------------+----------------+
| size | schedule | outer_diameter | inner_diameter |
+------+----------+----------------+----------------+
|    1 | 10       |         0.0394 |         0.0394 |
|    2 | STD      |          2.375 |          2.067 |
|    2 | XS       |          2.375 |          1.939 |
|    2 | XXS      |          2.375 |          1.503 |
|    2 | 5        |          2.375 |          2.245 |
|    2 | 10       |          2.375 |          2.157 |
|    2 | 40       |          2.375 |          2.067 |
|    2 | 80       |          2.375 |          1.939 |
|    2 | 160      |          2.375 |          1.687 |
|  2.5 | STD      |          2.875 |          2.469 |
|  2.5 | XS       |          2.875 |          2.323 |
|  2.5 | XXS      |          2.875 |          1.771 |
|  2.5 | 5        |          2.875 |          2.709 |
|  2.5 | 10       |          2.875 |          2.635 |
|  2.5 | 40       |          2.875 |          2.469 |
|  2.5 | 80       |          2.875 |          2.323 |
|  2.5 | 160      |          2.875 |          2.125 |
```

Notice the difference? Size is correctly ordered and schedule is now ordering alphabetically first and then numerically. Outstanding.

-- Ruby on Rails section --

Does this work in ActiveRecord? Yup. Just like this:

``` ruby
PipeSize.scoped.order("size, schedule regexp '[0-9]', 0+schedule, schedule")
```

Of course, you don't want to add that to each ActiveRecord.find. So let's drop it into the model proper as a named scope so it is only called when actively requested:

``` ruby
class PipeSize < ActiveRecord::Base
  has_many :assessments

  def self.ordered
    order("size, schedule regexp '[0-9]', 0+schedule, schedule")
  end
end
```

Now we can issue finds thusly:

``` ruby
p = PipeSize.ordered
```

Outstanding. We're now ordering alpha-numerically rather than ASCIIbetically. We're ordering by common sense.

Update 20120331: Updated for Rails 3.x
