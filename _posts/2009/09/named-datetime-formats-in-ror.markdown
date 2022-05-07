---
title: Named Date/Time Formats in Ruby on Rails
description: "Simplify formatting of dates and times in Ruby on Rails"
date: 2009-09-08
post: true
categories: [datetime, formats, ruby on rails]
---

When I first began writing perl code in the mid 90's I was amazed at how easy it was to program most tasks in contrast to programming them in C. It was fun to program again. Now, as I come to Ruby and its relevant web frameworks I am again rediscovering the joy of programming I didn't realize I had begun to lose.

One of the tasks I always hated was date comparisons and date formatting. In perl, you grab two dates, change them to UNIX epoch seconds, compare them, and then run some calculations on that comparison to return some value. It's easier now with the DateTime module, but for the longest time, that's how you did it. Date formatting was similar; you had to hand-roll it.

I'm not using perl anymore - well, I am, but only until I can port things to Ruby - but I still find myself doing things the "perl way". Until last week, I'd been using Ruby's implementation of `strftime` to do most of my date formatting. And then I found this little nugget in the Rails API under [ActiveSupport::CoreExtensions::Date::Conversions](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Date/Conversions.html)" and its sister "[ActiveSupport::CoreExtensions::Time::Conversions](http://api.rubyonrails.org/classes/ActiveSupport/CoreExtensions/Time/Conversions.html)"

> You can add your own formats to the Date::DATE_FORMATS hash. Use the format name as the hash key and either a strftime string or Proc instance that takes a date argument as the value.

``` ruby
Date::DATE_FORMATS[:month_and_year] = "%B %Y"
Date::DATE_FORMATS[:short_ordinal] = lambda { |date| date.strftime("%B #{date.day.ordinalize}") }
```

Huh? What it means is that I can add now add my own personal date/time formats and call them with a `to_s` on any Date object in Rails. Here's an example from my `config/initializers/datetime_formats.rb` file:

``` ruby
datetime_formats = {
  :standard => "%b %d, %Y"
}
Date::DATE_FORMATS.merge!(
  datetime_formats.merge(
    :ymd => "%Y%m%d"
  ) 
)
Time::DATE_FORMATS.merge!(
  datetime_formats
)
```

In the above example `datetime_formats` is a list of those formats which are common to both `Date::DATE_FORMATS` and `Time::DATE_FORMATS`. To bring in `Time` or `Date` specific formats, we just merge them into the `datetime_formats` hash.

Now, when you need to apply a format, say to the `created_at` field of an ActiveRecord object, just call `to_s(:format_name)`. Here's an example:

``` ruby
x = Post.find(100)
x.created_at.to_s(:standard) # returns "Sep 08, 2009"
```

It's these little things that make programming fun again.
