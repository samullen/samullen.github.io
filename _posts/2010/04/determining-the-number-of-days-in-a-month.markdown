---
title: Determining the Number of Days In a Month
date: 2010-04-19
post: true
categories: [ruby, dates]
---

``` ruby
def days_in_month(year, month)
  Date.new(year, 12, 31).prev_month(12 - month).day
end
```

You're basically grabbing the last day of the year, and then getting the day for *n* months previous (12 - month).

**Update:** For those who ask, "Yeah, but how do you find the first day of the month?" It's "1".
