---
title: "Extending Minitest 5: Progress Reporters"
description: "Extend Minitest 5 by modifying the output behavior of the Progress Reporter"
author: Samuel Mullen
date: 2013-11-14
post: true
categories: [minitest ruby]
---

Minitest has a number of strengths: small size, speed, simplicity, and inclusion
in the Ruby standard library. Arguably, its small size and simplicity are the
greatest, not because they enhance testing, but rather because they encourage
modifying Minitest's behavior.

In the last post ([Extending Minitest 5: Assertions](//samuelmullen.com/2013/11/extending-minitest-5-assertions/)),
we saw how easy it is to add new assertions and expectations to our tests. In
this post, we'll look at extending Minitest by modifying the output of the
`ProgressReporter`.

## must_include :explanations

If you've done any amount of testing, you've seen the results of progress
reporters: the string of dots punctuated by the occasional "F", "S", or "E"
(depending on your test suite). Out of the box, Minitest's progress reporter is
rather dull; it's your terminal's foreground color. 

<img src="//samuelmullen.com/images/minitest/default_progress_reporter.png" class="img-left img-thumbnail">

We're going to change that.

## must_respond_to :conventions

In order to get Minitest to automatically read our new progress reporter –
and this will be the same for any "plugin" you create – we'll need to adhere to
a few conventions.

### $LOAD_PATH.must_include "/path/to/plugin"

In the
[`::load_plugins`](https://github.com/seattlerb/minitest/blob/master/lib/minitest.rb#L68) method in the `minitest.rb` file of Minitest, it uses
`Gem::find_files` to search for plugins. The `::find_files` method uses the
`$LOAD_PATH` global variable to determine which directories in which to look.
So, in order for Minitest to find your plugins, you'll either need to create it
as a Gem, or `push` your directory onto the `$LOAD_PATH` array.

``` ruby
$LOAD_PATH.push "/home/fooman/projects/rearden"
```

Furthermore, you will need a "minitest" directory immediately under the
directory you push onto `$LOAD_PATH`. Based on our example, our plugin file
would reside under `/home/fooman/projects/galt/minitest`.

### filename.must_match /_plugin.rb/

As the heading implies, all plugins must end with `_plugin.rb`. Therefore, if
your plugin is named "whizbang", it would reside in the file
`whizbang_plugin.rb`.

### initializers.must_match /plugin_name_(init|options)/

Continuing with the filename example above, you will also need to create
initializer methods in your plugin using the following format: 

``` ruby
def plugin_whizbang_init
...
end

def plugin_whizbang_options # This one is optional
...
end
```

The first method (i.e. the "init" method) is required for every Minitest plugin,
and we'll see how that works shortly. The latter method, as mentioned in the
code comment, is optional.

## examples.must_include "The Hard Way"

What follows is an example plugin which adds Unix escape characters to
Minitest's default output to make the results green (success), yellow (skips),
or red (fails and errors). An explanation of the code is below.

``` ruby
  module Minitest
    def self.plugin_stoplight_init(options)
      io = StoplightReporter.new(options[:io])
  
      self.reporter.reporters.grep(Minitest::Reporter).each do |rep|
        rep.io = io
      end
    end
  
    class StoplightReporter
      attr_reader :io
  
      def initialize(io)
        @io = io
      end
  
      def print(o)
        case o
        when "." then
          opening = "\e[32m" # green
        when "E", "F" then
          opening = "\e[31m" # red
        when "S" then
          opening = "\e[33m" #yellow
        end
  
        io.print opening
        io.print o
        io.print "\e[m"
      end
  
      # Just here so you can see it can be overridden
      def puts(*o)
        io.puts(*o)
      end
  
      def method_missing(msg, *args) # :nodoc:
        io.send(msg, *args)
      end
    end
  end
```

As you can see, we are adding the `StoplightReporter` class to the `Minitest`
module, and we are initializing that class in the `plugin_stoplight_init`
method.

This method does a couple things:

1. It retrieves a "modified" `io` object from the `StoplightReporter` class
2. It replaces the `io` object used by every `Minitest::Reporter` with that
   newly created `io` object.

We use this new `io` object to override the `print` method, and as you can see
it's just wrapping a Unix escape sequence to what is sent. The `puts` method is
merely there to show that it can be overridden as well. And the `method_missing`
catches everything else which might be sent to the original `io` object.

Now, anytime Minitest's reporters output a ".", "S", "E", or "F", it gets
colored.

## examples.must_include "The Easy Way"

Of course there's an easier way to do all of this, but to do it, you have to
ignore the plugin system [Ryan Davis](http://www.zenspider.com/) set up.

``` ruby
module Minitest
  class ProgressReporter < Reporter
    def record(result)
      case result.result_code
      when "." then
        opening = "\e[32m"
      when "E", "F" then
        opening = "\e[31m"
      when "S" then
        opening = "\e[33m"
      end

      io.print opening
      io.print result.result_code
      io.print "\e[m"
    end
  end
end
```

This is pretty straightforward. All we're doing here is [monkey patching](http://en.wikipedia.org/wiki/Monkey_patch) Minitest's
`ProgressReporter` class with our own version, and so avoiding the `io`
component altogether. To use it, you'll need to `require` it rather than load it
through Minitest's plugin system. 

Of course, there are risks involved with doing things this way, but we're just
playing with the output of a test framework. What could possibly go wrong? :)

## must_be_kind_of Conclusion

Minitest, by design, wants to be extended, and in this post we've seen how easy
it is to do just that by modifying the behavior of the `ProgressReporter` class.

In the next post, we'll see what we can do with the results of our test runs.

