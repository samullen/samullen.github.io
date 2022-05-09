---
title: "Extending Minitest 5: Custom Reporters"
description: "Extend Minitest 5 by creating custom reporters"
author: Samuel Mullen
date: 2013-11-21
post: true
categories: [minitest ruby]
---

In the previous two posts, we looked at extending
[Minitest](https://github.com/seattlerb/minitest) with new [Assertions and Expectations](//samuelmullen.com/2013/11/extending-minitest-5-assertions/),
and [modifying the progress reporter output](//samuelmullen.com/2013/11/extending-minitest-5-progress-reporters/).
In this post, we will look at what can be done with the data collected from the
test suite once it's run.

To be clear, Minitest has a class called
[SummaryReporter](https://github.com/seattlerb/minitest/blob/eaabfce90e73b9533f7e1921a3d16ac1866efe42/lib/minitest.rb#L525)
which has the purpose of summarizing the run, providing information on the
arguments used, displaying failures and errors, and reporting the statistics
from the run.  The only way to alter this output is to override the
`SummaryReporter`.

In this post, rather than altering Minitest itself, we'll look at what can be
done with the data collected from the test suite. We'll use a plugin called
`VocalReporter` as our example.

## must_be_kind_of AbstractReporter

All custom reporters will be a subclass of
[AbstractReporter](https://github.com/seattlerb/minitest/blob/eaabfce90e73b9533f7e1921a3d16ac1866efe42/lib/minitest.rb#L392),
either by subclassing it directly or by inheritance through another reporter
such as `StatisticsReporter`. In so doing, your class will be able to override,
the following four methods:

* `start` - Called when the run has started
* `record` - Called for each result, passed or otherwise
* `report` - Called at the end of the run
* `passed?` - Called to see if you detected any problems

## must_include :example

For our example, we will be subclassing the
[StatisticsReporter](https://github.com/seattlerb/minitest/blob/eaabfce90e73b9533f7e1921a3d16ac1866efe42/lib/minitest.rb#L465)
and only use the `report` method. We'll also take advantage of the Mac's `say`
command to announce our test results.

``` ruby
module Minitest
  def self.plugin_vocal_reporter_init(options)
    self.reporter << VocalReporter.new(options[:io], options)
  end

  class VocalReporter < StatisticsReporter
    def report
      super 

      pct = self.failures / self.count.to_f * 100.0

      if pct > 50.0
        message = "#{self.count} tests run with #{self.failures} failures. Are
you even trying?"
      elsif self.failures > 0
        message = "#{self.count} tests run with #{self.failures} failures. That
kinda sucks"
      else
        message = "%d tests run with no failures. You rock!" % self.count
      end
      `say #{message}`
    end
  end
end
```

As explained in [the previous post](//samuelmullen.com/2013/11/extending-minitest-5-progress-reporters/)
under "must_respond_to :conventions", the file's name and init methods must be
in alignment.

Let's break this down:

* Line 1: Like all Minitest plugins, we're adding to the Minitest module
* Lines 2-4: The init method which has been discussed previously
* Line 3: We append an instance of our `VocalReporter` to Minitest's
  [CompositeReporter](https://github.com/seattlerb/minitest/blob/eaabfce90e73b9533f7e1921a3d16ac1866efe42/lib/minitest.rb#L585)
  which handles execution of the four methods (`#start`, `#record`, `#report`, 
  and `#passed?`)across all reporters
* Line 6: Naming the `VocalReporter` class and inheriting from the
  [StatisticsReporter](https://github.com/seattlerb/minitest/blob/eaabfce90e73b9533f7e1921a3d16ac1866efe42/lib/minitest.rb#L465)
* Lines 7-20: Our `report` method which will output our results
* Line 8: calls `StatisticReporter`'s `#report` method in order to get access
  to attributes set therein, such as `#failures` and `#count`
* Line 10: calculate the percentage of fail
* Lines 12-18: a little logic to define the message
* Line 19: output the message audibly

If you were to include this plugin in your test suite, you would hear – assuming
all tests passed – "*n* tests run with no failures. You rock!"

It's a silly example, but it does make the point that you can do interesting –
and unexpected – things with your test results.

### @ideas.wont_be_empty

Other ideas for customer reporters:

* Output results to a USB LED device using [blinky](https://github.com/perryn/blinky)
* Send emails to everyone on the team announcing your success or failure (Public
  shaming always leads to increased motivation. Just ask anyone who's tried
dieting.)
* Output statistics to a database to track progress
* Send results to a Continuous Integration server
* Make a game out of the results
* Other ideas? List them in the comments below

## must_be_kind_of Conclusion

We've really only scratched the surface with what you can do with custom
reporters for Minitest. Remember, it's just Ruby, get in and play. At this point
in the series, you should be able to implement any customization you want, be it
new assertions or expectations, progress reporters, or customized reporters.

I hope you've enjoyed reading this series as much as I've enjoyed writing it.
I've learned a lot from getting into Minitest's code and trying to understand it
, and I would encourage you to do the same; it's small, it's very approachable,
and it's pretty funny. Just start with
[autorun.rb](https://github.com/seattlerb/minitest/blob/eaabfce90e73b9533f7e1921a3d16ac1866efe42/lib/minitest/autorun.rb)
and follow the code.
