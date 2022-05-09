---
title: "Extending Minitest 5: Assertions"
description: "Extend Minitest 5 by adding new assertions and expectations to make your tests better"
author: Samuel Mullen
date: 2013-11-06
post: true
categories: [minitest ruby]
---

[Minitest](https://github.com/seattlerb/minitest), as a testing framework, is
quickly gaining popularity in the Ruby community. Some of this is due to it
replacing the old `Test::Unit` library in the Ruby standard library, but
certainly much is due to the simplicity of the framework. This simplicity lends
itself to easily extending the framework, which I believe is exactly what its
creator ([Ryan Davis](http://zenspider.com/)) wanted.

In this, the first of three posts on extending Minitest, we'll start off slow
and look only at extending Minitest with new assertions and expectations. In the
posts to follow, we'll look more closely at naming files and directory
structures, tweaking the progress output, and then doing something with the
results once everything has run.

## assert_background

Assertions were originally developed in programming languages, not for the
specific purpose of testing, but rather ensuring a sort of contract between
caller and receiver was maintained. If a caller sent the wrong message to the
receiver, the assertion would fail (i.e. the contract was broken), and an
exception would be raised.

Tests, then, are just contracts stating what we expect from our software. And in
the end, all assertions and expectations boil down to the humble `assert` method
which asks, "does your output match the expectation?"

## must_include "reasons"

Minitest contains a comprehensive list of both assertions and expectations, and
as was already mentioned, assertions and expectations all fall back to the
`assert` method, so why would you want or need to add something new?

### assert_readable

One reason to create new assertions, is similar to the reason we might create
new methods: it makes our code more readable. For example, which snippet of code
below is more readable?

``` ruby
assert_includes users, user

# -- OR --

assert_respond_to users, :include?
assert users.include? user
```

Furthermore, by making the assertions and expectations more readable, they can
show specifically what is being tested.

``` ruby
3.14.must_round_to 3

# -- OR --

3.14.round.must_equal 3
```

In this example, by creating the `must_round_to` expectation, it is clear the
test is on the value 3.14. In contrast, the second example implies the `round`
method is what is being tested.

Hat tip: [Jared Ning](http://redningja.com/) for his [Gist on creating expectations](https://gist.github.com/ordinaryzelig/2032303)

### assert_dry

Creating new assertions also helps to DRY your code, which in turn makes your
tests less error prone. You know from experience that duplicated code is
problematic, and so you extract logic into other classes and methods. Why would
it be different in tests?

**note:** This section could use more support and possibly code, but the post is
getting long, and as a Rubyist, it's easier to swing "because it's DRYer" around
like a club to end any disagreement.

## assert_new_assertion

It is not difficult to add new assertions and expectations. It's just
a matter of creating a positive assertion, a negative assertion (`refute`), and
inserting them into Minitest. Expectations are almost laughably simple.

In the following code, we'll add assertions to ensure all values within a
collection match – or don't match, in the case of `refute` – the value being
tested. 

``` ruby
module Minitest::Assertions
  def assert_all_equal(collection, value, msg=nil)
    msg = message(msg, "") {
      "Expected #{mu_pp(collection)} to contain only #{mu_pp(true)} values"
    }
    assert collection.all? {|item| item == value} == true, msg
  end

  def refute_all_equal(collection, value, message=nil)
    msg = message(msg, "") {
      "Expected #{mu_pp(collection)} not to only contain #{mu_pp(true)} values"
    }
    assert collection.all? {|item| item == value} == false, msg
  end
end
```

As you can see, we are adding `assert` and `refute` methods to the
`Minitest::Assertions` module. In each method, we accept a collection to test
against, a value we expect the collection to only contain (or not only contain),
and an optional message.

The `mu_pp` method used in the `message` call is a Minitest-local method which
basically prints the object name nicely.

Lastly, we `assert` that all objects in the collection match (or don't) the
value passed in.

### assert_loaded

Unlike Minitest plugins, assertions and expectations don't need to reside under
a `minitest` directory – plugins don't either, really, but that's a different
post – they just need to get loaded. You can store all your assertions and
expectations in separate files and `require` or `load` them through a helper, or
you can store them in the `helper` file itself. 

There really isn't a "correct" way of doing this, which, in a lot of ways, is
what I love about Minitest. As you use the framework more and more, you're
continually reminded that it's not some sort of sacred cow, but rather it's
still just Ruby, and as such, you are at liberty to do whatever you damn well
please.

### assert_usage

This is how we might use our newly created assertion

``` ruby
assert_all_equal([true, true, true], true)
refute_all_equal([true, false, true], true)
```

## assert_expectations

If you run `Minitest::Spec` you'll want add some expectations. Nothing could be
simpler.

``` ruby
module Minitest::Expectations
  infect_an_assertion :assert_includes, :must_all_equal, :reverse
  infect_an_assertion :refute_includes, :wont_all_equal, :reverse
end
```

That really is all you have to do. Just open up the module and add the
"infections". Did I mention Ryan Davis has a wicked sense of humor?

A note about `:reverse`. It doesn't have to be `:reverse`, it's just a "flag".
It could be `:unary`, `:reverse`, `:foo`, `true`, etc. As long as it evaluates
to a "truthy" value.

All this flag does is reverse the order of the arguments passed into the
assertion. You'll generally use this flag when dealing with collections or
boolean methods (e.g. #nil?, #empty?, etc.)

### must_have_usage

Usage for the new expectations:

``` ruby
[true, true, true].must_all_equal true
[true, false, true].wont_all_equal true
```

## assert_end

In the next posts, we'll cover creating plugins for Minitest, but at this point,
you should have enough knowledge to start creating your own assertions and
expectations. If you have questions, or would like to see more examples, I
encourage you to look at the code itself. The Minitest library is remarkable
small and very approachable; it's also really funny. For what we've covered
today, you'll only need to look at
[assertions.rb](https://github.com/seattlerb/minitest/blob/master/lib/minitest/assertions.rb)
and
[expectations.rb](https://github.com/seattlerb/minitest/blob/master/lib/minitest/expectations.rb).
