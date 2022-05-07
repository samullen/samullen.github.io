---
title: "Guidelines for Using ActiveRecord Callbacks"
description: Three simple guidelines for helping Rails developers determine if using an ActiveRecord callback is a good idea.
date: 2012-01-17
post: true
categories: [ruby on rails, ActiveRecord, OO, best practices]
---
ActiveRecord callbacks are awesome little devices which allow you to "hook" in to the life cycle of an ActiveRecord object. But from a quick Googling of "ActiveRecord callbacks", you might not come to the same conclusion. Within the first ten results (as of this writing), there are four which are either looking for or providing ways of circumventing the triggering of callbacks.

Why would you want to skip callbacks? I can think of lots of reasons, but every single one of them is the result of models being too tightly coupled to other objects and responsibilities. Examples: sending emails, logging, updating related or unrelated tables, etc. If your callback stays within its object's area of responsibility it should never need to be skipped.

Generally speaking - and I do mean "generally" - an ActiveRecord model has one responsibility: interacting with the database. When your model exceeds that one mandate, it immediately becomes more difficult to maintain. I would even go so far as to say that for every responsibility added to a model or any other object, the difficulty of maintenance doubles (No hard numbers; just shooting from the hip.)

To avoid this exponential growth in model maintenance pain, I've come up with three guidelines to determine if using a callback is appropriate.

### Guideline #1: Use callbacks only if they can be run every time and in every circumstance they are triggered.

This rule is pretty straightforward, but let's look at it for the sake of clarity.

Callbacks are executed *every* time their triggering event occurs (e.g. A `before_save` callback will be triggered before every save event). If there is any instance in which it shouldn't be called, then think about [moving the logic to a decorator object](//samuelmullen.com/2011/12/sending-notifications-using-decorators-instead-of-callbacks/).

Consider also, context. If a callback cannot be issued in every circumstance (e.g. development, production, and test), that is a warning the callback needs to be refactored into something less coupled.

### Guideline #2: Never create callbacks which exceed the model's responsibility.

> If a class has more than one responsibility, then the responsibilities become coupled. Changes to one responsibility may impair or inhibit the class' ability to meet the others. -- Uncle Bob Martin [Single Responsibility Principle](https://web.archive.org/web/20150202200348/http://www.objectmentor.com/resources/articles/srp.pdf)

As mentioned previously, the responsibility of an ActiveRecord model is to interact with the database. When we require our models to send emails, create files, or what have you, we exceed our model's one responsibility. This doesn't sound like a bad thing at first, but as requirements change - and they always change - the model will be required to do more and more in order to meet the added responsibilities.

By limiting callbacks to the scope of the model's responsibility, we simplify maintenance and testing and keep the application prepared for further growth.

### Guideline #3: If you have to stub callbacks during testing, you are violating one of the previous rules of thumb.

[RSpec](https://github.com/rspec/rspec) now has a nifty little method called `any_instance` which it inherited from [Mocha](https://github.com/floehopper/mocha). This method allows a developer to apply a bit of logic to "any instance" of a particular class. In the past I have used `any_instance` to keep my models from sending emails during testing. I did this because the emails were dependent upon more than just the one model and would therefore fail during unit testing. By stubbing out the callback I was saying 1) my callback couldn't by executed every time and in every circumstance, and 2) it was exceeding the model's responsibility. In other words I was violating the first two rules of thumb.

I'm sure there are valid reasons for stubbing your callbacks during normal unit testing (what some call integration testing), but in general, stubbing every instance of a callback in order to get a test to pass is an implication your callbacks have exceeded their responsibility.

I have said somewhat facetiously, "callbacks are the devil." I usually say something like this after dealing with a callback which was doing more than it should. Callbacks, like any tool, can be exceptionally useful and are no more "the devil" than any other tool. It's when we make our tools exceed their responsibility that they get a little devilish.

### Further Reading:
* [Single Responsibility Principle](http://www.objectmentor.com/resources/articles/srp.pdf)
* [Sending Notifications Using Decorators Instead of Callbacks](//samuelmullen.com/2011/12/sending-notifications-using-decorators-instead-of-callbacks/)
* [ActiveRecord, Caching, and the Single Responsibility Principle](http://robots.thoughtbot.com/post/9123160250/activerecord-caching-and-the-single-responsibility)
