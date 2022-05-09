---
title: "Finding the \"Next Occurrence\" with SQL"
author: "Samuel Mullen"
description: "Given a start date, an interval, and a frequency, how can you easily determine if a date is the next occurrence?"
date: "2016-10-31T17:46:49-05:00"
tags: [ "sql", "dates", "databases", "postgres"]
---

## The Problem

In one of our current projects, we have a feature which handles recurring donations for a non-profit organization. The recurrence could happen on some frequency of week or month, such as “every six week”, “every other month”, “every quarter”, etc.

To keep track of how often a donation is to be processed, we store both the “interval” and “frequency” in the associated database table. The “interval” would be either “week”, “month”, or “year”, while frequency would be an integer value. A frequency of “6” on a “month” interval would mean “every six months.”

To determine which donations need to be processed, we need to also know when they first began. A monthly donation which began on the 15th of January should be processed on the 15th of every month thereafter.

The trick comes in when you’re dealing with donations starting on the last day of the month. A monthly donation which begins on the 31st of January, should also be processed on the 28th of February (in a non-leap year), the 31st of March, and the 30th of April.

One possible solution we’ve seen is to retrieve all the records and use a library, such as the excellent [IceCube](https://github.com/seejohnrun/ice_cube) Ruby library, to determine if a record occurs within the sequence and on the specified day.

This solution is suboptimal, not because of the library, but because every record must be retrieved and processed to determine the next occurrence. Ideally, we should _only_ retrieve those records which need to be processed.

Here’s how we can do that in pure SQL.

## The queries

Here’s the basic database table from which we’ll be retrieving data.

```sql
                         Table "public.donations"
       Column  |            Type             |         Modifiers
---------------+-----------------------------+-------------------------------
 person_id     | integer                     | not null
 amount        | integer                     | not null
 begin_on      | timestamp without time zone | not null
 end_on        | timestamp without time zone |
 interval      | string                      | not null
 frequency     | integer                     | not null
```

We’re going to break things up between a weekly and a monthly query. Trust me, it’s easier this way.

### The weekly query

```sql
SELECT *
  FROM donations
 WHERE interval = 'week'
   AND ('2016-10-31'::date - begin_on::date)::int % (frequency * 7) = 0
```

There's a bit of noise in the `where` clause, but don't be fooled, it's simpler
than it looks. The `::date` and `::int` bits merely cast the data to those
particular types.

What we are doing is getting the number of days between the start date
(`begin_on`) and the date we want to run this for (2016-10-31) and then using
the modulo operator (`%`) to see if the frequency of weeks (`frequency * 7`)
equals zero, i.e. if it lands on today.

Overall, pretty simple. The monthly query's a bit more involved.

### The monthly query

```sql
SELECT *
  FROM donations
 WHERE interval = 'month'
   AND (begin_on::date + (round(('2016-10-31'::date - begin_on::date)::int / (30.4367 * frequency)) * frequency || ' months')::interval)::date = '2016-10-31'::date
```

Similar to the "weekly query" above, we're limiting our results to only those
with an interval of "month".

To see if our target date lands  _n_ months from our start date, we can use
Postegres' `interval` feature. In our calculation, we...

* determine the difference in days between the start date and the target date.

```
('2016-10-31'::date - begin_on::date)::int
```

* Divide that by the average number of days in a month times the frequency

```
/ (30.4367 * frequency))
```

* And then multiple it again by the frequency and rounding it which gives us the
  number of months

```
round(('2016-10-31'::date - begin_on::date)::int / (30.4367 * frequency)) * frequency || ' months'
```

* We use the number of months and Postgres' `::interval` function to add to the
  begin_on date

```
(begin_on::date + (...)::interval)::date
```

* And test that against our target date

```
(begin_on::date + (...)::interval)::date = '2016-10-31'::date
```

This solution isn’t perfect. If you didn’t already know, when you perform a
database function or calculation within the “where clause” of a SQL statement,
the database can no longer retrieve data merely by following indexed fields or
other algorithms, but instead performs the calculations on the data while
retrieving it to determine if it meets the constraints (in our case, comparing
it to a date).

How is this any different than performing these calculations outside the
database?

1. Keeping the calculations inside the database reduces the transfer time of the
   data;
2. Databases are really good at searching and comparing against calculated
   results.

I had a lot of fun figuring this solution out. If it helps you, [drop us a line](/contact) and let us know.
