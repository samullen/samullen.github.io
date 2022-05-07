---
title: "Step By Step: Setting Up minitest and Cucumber with Rails"
description: "A step by step guide to setting up a Rails application with both minitest and Cucumber."
date: 2012-11-10
comments: true
post: true
categories: [ruby on rails, testing, tdd, cucumber, minitest, tutorial]
---

I've tried a couple times in the past to successfully set up a
[Rails](http://rubyonrails.org/) application with both
[minitest](https://github.com/seattlerb/minitest) and
[Cucumber](http://cukes.info/); each time, I ran in to issues. I'm not entirely
sure why I ran into the issues I did, but I just couldn't seem to get things
working. Recently, I managed to get everything going with almost no effort.
Here's what I did.

## Step 1: Creating and Configuring a New Rails App with minitest

For the sake of simplicity, we'll assume that we're creating a new Rails application. To do so, we'll want to skip the standard usage of Test::Unit

``` bash
rails new <app_name> --skip-test-unit
```

Immediately after this, we'll need to install and initialize the `minitest-rails` gem

``` ruby
group :test, :development do
  ...
  gem 'minitest-rails', '~> 0.3.0` # as of this writing
  ...
end
```

`bundle install` and then initialize the gem in the app.

``` bash
rails g mini_test:install
```

The last thing we'll do is make sure our generators behave accordingly. To do that, add the following logic to the `config/application.rb` `config` block:

``` ruby
config.generators do |g|
  g.test_framework :mini_test, :spec => true, :fixture => false
end
```

This turns on `minitest`'s `spec` functionality and turns off fixture generation. If you don't want to use `minispec` or if you do want to use fixtures, just alter the values accordingly.

## Step 2: Setting up Cucumber

Okay, at this point we have our foundational test suite set up. Now we need to add cucumber to the mix. 

Add `cucumber-rails` to your `Gemfile` as you normally would.

``` ruby
group :test do
  gem 'cucumber-rails', "~> 1.3.0"
  gem "database_cleaner", "~> 0.9.1"
end
```

Call `bundle install` and then call the cucumber Rails generator:

``` bash
rails g cucumber:install
```

Now, add the following lines of code to `features/support/env.rb`. (I placed mine near the top.)

``` ruby
require 'minitest/spec'
World(MiniTest::Assertions)
MiniTest::Spec.new(nil)
```

For greater separation, the previous lines of code above can be added to a different support file.

## Step 3: Running the Tests

At this point, everything should work. Let's find out with a couple simple tests.

### minispec Test

Create the following test file and model:

``` ruby
require_relative "../minitest_helper"

describe Foo do
  it "must be valid" do
    Foo.must_respond_to :new
  end
end
```

And the corresponding model file:

``` ruby
class Foo
end
```

Notice in the first line of `foo_test.rb` that we're using `require_relative` instead of a normal `require` call. We do this to avoid the need to use rake. Now, rather than running `bundle exec rake minitest:models` and running all the models, we can execute `bundle exec ruby test/models/foo_test.rb`.

### Cucumber Test

Create the following Cucumber "feature" file:

``` cucumber
Feature: test
  In order to test cucumber
  a user
  wants to successfully land on the home page

  Scenario: foo
    Given I am on the home page
     Then I should see "Ruby on Rails: Welcome aboard"
```

And an associated step file:

``` ruby
Given /^I am on the home page$/ do
  visit "/"
end

Then /^I should see \"([^"]+)"$/ do |string|
  page.has_content?(string).must_equal true
end
```

Run the test and everything should be green.

``` bash
bundle exec cucumber features/test.feature
```

## Final Thoughts

I like minitest a lot, mainly because it's fast, it's simple, and it's included in Ruby 1.9+, but there are drawbacks; the two main ones for me are its readability and the lack of integration with the [vim-rails](https://github.com/tpope/vim-rails) plugin. Neither of these "drawbacks" are deal breakers, however: the `vim-rails` plugin will eventually support it, and there are gems to make the suite more "civilized" (listed below).

So if you like the idea of a really simple and fast test suite, and you don't mind the syntax, give `minitest` a go on your next project. Oh, and let me know how it works out for you.

## Further Reading

* minitest on GitHub: [https://github.com/seattlerb/minitest](https://github.com/seattlerb/minitest)
* minitest RDoc: [http://docs.seattlerb.org/minitest/](http://docs.seattlerb.org/minitest)
* minitest-rails: [https://github.com/blowmage/minitest-rails](https://github.com/blowmage/minitest-rails)
* including minitest in Cucumber: [https://github.com/cucumber/cucumber/wiki/Using-MiniTest](https://github.com/cucumber/cucumber/wiki/Using-MiniTest)
* Capybara integration for minitest-rails: [https://github.com/blowmage/minitest-rails-capybara](https://github.com/blowmage/minitest-rails-capybara)
* TURN - minitest Reporters: [https://github.com/TwP/turn](https://github.com/TwP/turn)
* PurdyTest from tenderlove: [https://github.com/tenderlove/purdytest](https://github.com/tenderlove/purdytest)
