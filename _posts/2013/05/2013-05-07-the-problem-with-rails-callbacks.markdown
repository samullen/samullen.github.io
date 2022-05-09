---
title: "The Problem with Rails Callbacks"
description: "Callbacks in Rails can lead to a host of problems. This post provides some simple tips to avoid those problems."
date: 2013-05-07
comments: true
post: true
categories: [ruby on rails, object oriented programming, callbacks, ActiveRecord]
---

If you search [StackOverflow](http://stackoverflow.com) for "Rails callbacks",
a large number of the results pertain to seeking means to avoid issuing the
callback in certain contexts. It almost seems as though Rails developers
discover a need to avoid callbacks as soon as they discover their existence.

Normally, this would be a cause for concern, that perhaps the feature should be
avoided altogether or even removed, but callbacks are still part of Rails. Maybe
the problem goes deeper.

## What is a Callback?

As you likely already know, callbacks are just hooks into an `ActiveRecord`
object's life cycle. Actions can be performed "before", "after", or even "around"
`ActiveRecord` events, such as `save`, `validate`, or `create`. Also, callbacks
are cumulative, so you can have two actions which occur `before_update`, and
those callbacks will be executed in the order they are occur.

## Where Trouble Begins

<img src="//samuelmullen.com/images/pandora.jpg" class="img-right img-thumbnail">

Developers usually start noticing callback pain during testing. If you're not
testing your `ActiveRecord` models, you'll begin noticing pain later as your
application grows and as more logic is required to call or avoid the callback.

I say, "developers usually start noticing callback pain during testing" because
in order to speed up tests or to get them to pass, it becomes necessary to "stub
out" the callback actions. If you don't stub out the action, then you must add
the supporting data structure, class, and/or logic to each test in order for it
to pass. 

Here's an example of what I mean:

``` ruby
class Post < ActiveRecord::Base
  has_many :followers
  after_save :notify_followers
  
  def publish!
    self.published_at = Time.now
    save
  end
  
  private
  
  def notify_followers
    Notifier.post_mailer.deliver
  end
end

describe "publishing the article" do
  it "saves the object with a defined published_at value" do
    Post.any_instance.stub(:notify_followers) # Codey McSmellsalot
    post = Post.new(:title => "The Problem with Callbacks in Rails")
    post.publish!
    expect(post.published_at).to be_an_kind_of(Time)
    expect(post).to_not be_a_new_record
  end
end
```

In order to get that example code to pass, `notify_followers` must be "stubbed
out". If it isn't, and if `follower`s are used within the mailer, the test will fail because it's not able to execute the delivery (i.e. it'll error out due to `nil` values).

## What About Observers?

Rails developers who've begun moving into a more Object Oriented mindset might
ask, "What about using observers instead of callbacks?" It's the right
direction: by creating an observer, you move responsibilities which don't belong
in the object being observed to the observer. 

<img src="//samuelmullen.com/images/observers.jpg" class="img-right img-thumbnail">

The problem is that observers in Rails are kind of like ninja callbacks: they
perform the same function as callbacks, they just work in the shadows. Unless
you look at the file system, you are very likely to forget Observers even exist
in your application.

Furthermore, observers are assigned to their appropriate class when Rails starts
up, and Rails starts up when you run your tests. Once again, you'll start
feeling pain in your tests first, because in order to avoid observer calls in
your tests, you will need to either create all the dependent objects or install
a gem such as [no_peeping_toms](https://github.com/patmaddox/no-peeping-toms).
Just like callbacks, observers run every time their condition is met.

*Aside:* Herman Moreno wrote a good post on undocumented observer usage: [Fun with
ActiveRecord::Observer](http://blog.crowdint.com/2013/04/23/fun-with-activerecord-observer.html).

## Why Are Callbacks So Problematic?

In his post on [ActiveRecord, Caching, and the Single Responsibility Principle](http://robots.thoughtbot.com/post/9123160250/activerecord-caching-and-the-single-responsibility), Joshua Clayton noticed "after_* callbacks on Rails models seem to have some of the most tightly-coupled code, especially when it comes to models with associations." 

It's no coincidence. "before\_" callbacks are generally used to prepare an
object to be saved. Updating timestamps or incrementing counters on the object
are the sort of things we do  "before" the object is saved. On the other hand,
"after\_*" callbacks are primarily used in relation to saving or persisting the
object. Once the object is saved, the purpose (i.e. responsibility) of the
object has been fulfilled, and so what we usually see are callbacks reaching
outside of its area of responsibility, and that's when we run into problems.

## Solving the Problem

Jonathan Wallace, over at [the Big Nerd Ranch](http://bignerdranch.com), ran into to same problems and came up with one simple rule: "Use a callback only when the logic refers to state internal to the object." ([The only acceptable use for callbacks in Rails ever](https://www.bignerdranch.com/blog/the-only-acceptable-use-for-callbacks-in-rails-ever/))

If we can't use callbacks which extend responsibility outside their class, what
do we do? We make an object whose responsibility is to handle that callback.

## Before Example

Let's look at a hypothetical example. This is what we might originally have:

``` ruby
class Order < ActiveRecord::Base
  belongs_to :user
  has_many :line_items
  has_many :products, :through => :line_items
  
  after_create :purchase_completion_notification
  
  private
  
  def purchase_completion_notification
    Notifier.purchase_notifier(self).deliver
  end
end
```

``` ruby
class Notifier < ActionMailer...
  def purchase_notifier(order)
    @order = order
    @user = order.user
    @products = order.products

    rest of the action mailer logic
  end
end
```

In the above example we can see that when an order is saved, it's going to shoot
off an email to the customer. That Mailer is going to use the `order` object to
retrieve the ordering `user` and the products which were purchased and likely
use them in the email. Pretty simple, right?

In a test, however, *any* time an order is saved to the database, `user`,
`line_items`, and `products` will need to be created, or the `purchase_notifier`
method will need to be stubbed out –
`Order.any_instance.stub(:purchase_notifier)` (Ugh).

## After Example

Here's what happens when we move some responsibilities:

Our `Order` model is much simpler.

``` ruby
class Order < ActiveRecord::Base
  belongs_to :user
  has_many :line_items
  has_many :products, :through => :line_items
end
```

Here's our new class:

``` ruby
class OrderCompletion
  attr_accessor :order
  
  def initialize(order)
    @order = order
  end
  
  def create
    if self.order.save
      self.purchase_completion_notification
    end
  end
  
  def purchase_completion_notification
    Notifier.purchase_notifier.deliver(self.order)
  end
end
```

What we've done above is moved the process of saving the order and sending the
notification out of the `Order` model and into a PORO (Plain Old Ruby Object)
class. This class is responsible for completing an order. Y'know, saving the
order and letting the customer know it worked.

By doing this, we no longer have to stub out the notification method in our
tests, we've made it a simple matter to create an order without requiring an
email to be sent, and we're following good Object Oriented design by making sure
our classes have a single responsibility
([SRP](http://butunclebob.com/ArticleS.UncleBob.SrpInRuby)). 

It's a simple matter to use this in our controller too:

``` ruby
def create
  @order = Order.new(params[:order])
  @order_completion = OrderCompletion.new(@order)
  
  if @order_completion.create
    redirect_to root_path, notice: 'Your order is being processed.'
  else
    @order = @order_completion.order
    render action: "new"
  end
end
```

## Wrapping up

As much as I complain about callbacks, they're really not bad as long as you
remember the rule: "Use a callback only when the logic refers to state internal to the object." And really, that can be applied to any method.

When you start to feel those first twinges of pain from your tests, whether from
callbacks or otherwise, consider if what you are trying to do exceeds your
class's responsibility. Creating a new class is a simple matter, especially
compared to the pain and frustration caused by not doing it.

*Many thanks to [Pat Shaughnessy](http://patshaughnessy.net/) for proof-reading and providing feedback.*
