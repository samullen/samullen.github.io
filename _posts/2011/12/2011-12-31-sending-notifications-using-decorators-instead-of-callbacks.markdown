---
title: "Sending Notifications Using Decorators Instead of Callbacks"
description: "Move your notification callbacks out of the model and in to a decorator to simplify testsing and practice good OOP habits."
date: 2011-12-31
comments: false
post: true
categories: [decorators, patterns, object oriented programming]
---
It seems that lately, many of the better Rails articles have focused less on Rails and more on Object Oriented development. Uncle Bob Martin noticed the same thing and at Ruby Midwest stated that developers have finally gotten over the excitement of the past couple of decades (i.e. the Internet) and have begun getting back to doing OOP correctly.

One article which stands out and which seems to have started a whole avalanche of similar articles is Harold Gimenez's excellent [Tidy Views and Beyond with Decorators](http://robots.thoughtbot.com/post/13641910701/tidy-views-and-beyond-with-decorators). Although the article is primarily focused on the view layer, he does mention that decorators are particularly useful in other scenarios as well, "For example, you could use them to handle all the types of notifications should occur when saving a record without resorting to a nasty callback soup."

That's what I had been looking for, but I hadn't realized it yet. It wasn't until Avdi Grimm tweeted, "any_instance_of is an abomination :-P Albeit an abomination which sadly exists in RSpec now", that everything began to fit together.

I have a couple models which send out notifications when they are either created or updated. I had been using callbacks to perform the notifications, but in order to get my unit tests to pass and to avoid the call to send notifications - they depend on information from multiple sources - I've had to stub out the callback method using RSpec's "any_instance" method. I had any_instance stubs everywhere, and then to test the callback itself I had to unstub the stub. What a mess.

The solution, as you probably guessed, was to move the callback out of the model and into a decorator. Here's an example of my original code:

``` ruby
class Invite < ActiveRecord::Base
  after_create :send_invite # callback

  private

  def send_invite
    Notifier.some_invite(invite).deliver
  end
end
```

``` ruby
describe Invite do
  it "does something" do
    Invite.any_instance.stub(:send_invite) # stub here or...

    @invite = Factory.create :invite # ... this will raise an exception

    @invite.some_method_call.should be_true
  end
end
```

There's no need to post the controller logic, since it's just a normal save.

Here's the new code without the callback (note: I'm using the [Draper gem](https://github.com/jcasimir/draper))

``` ruby
class Invite < ActiveRecord::Base
end
```

``` ruby
class InviteDecorator < ApplicationDecorator
  decorates Invite

  def create
    save && send_invite
  end

  private

  def send_invite
    Notifier.some_invite(invite).deliver
  end
end
```

``` ruby
class InviteController < ApplicationController
  def create
    @invite = InviteDecorator.new(Invite.new(params[:id]))

    if @invite.create # calling the decorator.create method
      # handle the success
    else
      # handle the failure
    end
  end
end
```

``` ruby
describe Invite do
  it "does something" do
    @invite = Factory.create :invite # no longer need to stub the callback
    @invite.some_method_call.should be_true
  end
end
```

Now the model is only handling database communications (i.e. adhering to the [Single Responsibility Principle](http://en.wikipedia.org/wiki/Single_responsibility_principle)) and not getting messed up with sending emails. 

Since the callback is removed into the decorator, I am able to get rid of the any_instance stubs from my tests and just focus on the model, which means I no longer have to remember to stub out the notification method every time I need to create an instance of Invite. Testing the notification was simplified as well.

I still use the occasional callback when it is appropriate and when it doesn't violate the SRP, but with the Decorator Pattern in my toolbox I'm no longer as quick to do so.

### Further Reading
* [Draper gem](https://github.com/jcasimir/draper)
* [Tidy Views and Beyond with Decorators](http://robots.thoughtbot.com/post/13641910701/tidy-views-and-beyond-with-decorators)
* [Uncle Bob Martin's Ruby MidWest Keynote](http://confreaks.net/videos/759-rubymidwest2011-keynote-architecture-the-lost-years)
* [Decorator Pattern with Ruby in 8 lines](http://lukeredpath.co.uk/blog/decorator-pattern-with-ruby-in-8-lines.html)
* [Comparison of Four Decorator Styles in Ruby](https://github.com/croaky/decorators)
* [Evaluating alternative Decorator implementations in Ruby](http://robots.thoughtbot.com/post/14825364877/evaluating-alternative-decorator-implementations-in)
