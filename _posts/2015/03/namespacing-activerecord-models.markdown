---
categories:
- experiments\_on\_rails
- rails
- activerecord
comments: false
date: 2015-03-17T06:54:54-06:00
description: words go here
post: true
title: "Experiment 0: Namespacing ActiveRecord Models"
---

In his article, [Making ActiveRecord Models
Thin](http://solnic.eu/2011/08/01/making-activerecord-models-thin.html), Piotr
Solnica provides an example of how to separate the persistence and logic layers
in a Rails app. The persistence layer being that which handles database
interactions, while the logic layer handles what the application is supposed to
do (i.e. the business logic.) 

In the comments section of the article, however, a discussion breaks out about
naming classes. If you have a class named "Product" which handles persisting a
product, what do you name the class which handles the business logic? How do you
name either of them that communicates to developers what their purpose is?

The answer, as you've likely guessed from the title of this article, is
namespaces – well, it is for this experiment, anyway. We'll see what happens
later. (see [Experiments on Rails](//samuelmullen.com/2015/02/experiments-on-rails/)).

As a reminder, this series is about experimentation, not about how you should be
doing things in your projects.

## Setup

The code for this experiment can be found on the [namespacing](https://github.com/samullen/experiments_on_rails/tree/namespacing) branch of the [experiments_on_rails](https://github.com/samullen/experiments_on_rails) repository. 

The Gemfile is pretty light at the moment. Here are the gems of note:

* Guard: to automate running the tests
* minitest-rails-capybara: Includes both minitest-rails and the capybara
  component.
* Pry: this should be standard in all Rails projects
* Quiet Assets: removes logging output noise from the asset pipeline
* Factory Girl: We'll primarily be using fixtures, but I like having FG around
  to `build` objects when it makes sense.
* Database Cleaner: (commented out). We'll try to avoid this, but I usually run
  into problems with data sticking around.
* Spring: Speeds up tests by preloading Rails, but we'll see about getting rid
  of it in the next experiment.

The following lines have been added to the `config/application.rb` file to get
minitest-rails to produce "spec" test files when models are generated.

``` ruby
config.generators do |g|
  g.test_framework :mini_test, :spec => true
end
```

And here's out `test_helper.rb`:

``` ruby
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/rails/capybara"

include FactoryGirl::Syntax::Methods

Dir[Rails.root.join("test/support/**/*.rb")].each {|f| require f}

class ActiveSupport::TestCase
  fixtures :all

  self.use_transactional_fixtures = true
end
```

We're ready to write our first test.

## The Root Page

When a person visits an e-commerce sites, they have certain expectations: There
should be navigation controls, a search area, maybe a place to sign in, but
primarily, they expect to see products. For our first test, then, we're going
to display some promoted products on the first page. We can add the menu,
search, and even other groupings of products later, but right now we just want
to do something simple.

Let's look for ten promoted products on the main page:

``` ruby
require "test_helper"

feature "Visiting the site through the first page" do
  scenario "Happy path" do
    visit root_path

    within "#products-promoted" do
      page.all("div.product-thumbnail").size.must_equal 10
    end
  end
end
```

The test is is simple and straightforward: upon visiting the root path of the
site, we expect to see 10 product images (or at least `div`s which will
eventually hold the images).

We'll tackle the resource for the `root_path` first. 

### The Site Resource

This is easy enough. We need a `SiteController.rb` with a route to it, and
`site` views directory:

``` ruby
Rails.application.routes.draw do
  root "site#index"
end
```

We'll use the `SiteController` for displaying the landing page as well as static
pages such as "about", "terms and conditions", "employment opportunities", etc.
(not that those static pages will ever be created here). One could use a
`HomeController` for displaying the landing page, and use `StaticController` for
displaying static content like "About", "Terms and Conditions". Use what makes
sense for you and your organization.

If you were to look at the repo, the `SiteController` currently looks like this:

``` ruby
class SiteController < ApplicationController
  def index
    @root_page = RootPage.new
  end
end
```

In most Rails apps you run across, you will instead see instance variables for
each collection used on the page. If we were doing that, our controller might
look like this:

``` ruby
class SiteController < ApplicationController
  def index
    @popular_products = Product.popular
    @sale_products = Product.on_sale
    @deal_of_the_day = Product.deal_of_the_day
  end
end
```

We can't do that because of of Rule #4: "Controllers can instantiate only one
object." Instead, we're instantiating a class (discussed below in "The Root
Problem") which will contain all the necessary data. It could conceivably know
about product information, the shopping cart, personal information, and more.
I'm just not entirely sure what that's going to look like, and for right now, we
don't have to worry about it.

To get our tests to pass, we need to display the promoted products. This means
we'll need to create our first ActiveRecord model.

## DB::Product

We're going to namespace all of our models with `db`. It's short and let's us
know that this particular class is our interface to the `products` table (`AR`
for ActiveRecord would have worked too).

Before generating the Model, you'll want to add this to `config/initializers/inflections.rb` to ensure the "db" namespace constant is always generated as `DB` instead of `Db`:

``` ruby
inflect.acronym 'DB'
```

Now we can generate the `DB::Product` model and associated table:

``` ruby
rails g model db/product
```

Right now, we're creating the table with a name, price, and image ([the
migration](https://github.com/samullen/experiments_on_rails/blob/namespacing/db/migrate/20150218130101_create_db_products.rb). 

**Note:** When Rails generates the migration, it will add a leading `db_` to the
table name. Take care to remove that or you will have table names like
`db_products`.

By adding the `db/` prefix to the model name, Rails will generate a `db`
directory under `app/models`, `test/models`, and `test/fixtures`.

The last thing we'll want to do is tweak `app/models/db.rb`. It tells every
class which includes it to prefix its tablename with "db\_". We'll just set that
to an empty string.

And that's our first model. Let's use it.

## Displaying Products

We have a means by which we can display products, and we have a resource from
which to draw that information, now we need the first to be able to speak to the
latter. Remember, one of the rules I'm working under is that neither controllers
nor views can speak directly with an ActiveRecord model.

### Products

To start, we need a class which is able to store and retrieve data about a
product. This class will act as an interface to `DB::Product`, but it will also
provide some useful methods which might be out of place in the ActiveRecord
class, such as specific methods for product images.

At the minimum, we'll need to be able to instantiate objects from a single
`DB::Product` instance or from a collaction, and we'll need a means of accessing
some of the ActiveRecord class's methods and attributes.

``` ruby
class Product
  extend Forwardable

  def_delegators :@stored_product, :name, :price

  attr_accessor :stored_product

  def initialize(stored_product)
    @stored_product = stored_product
  end

  def self.from_collection(collection)
    collection.map {|object| self.new(object)}
  end
end
```

Right now, this class doesn't do much: it forwards `#name` and `#price` to the
`DB::Product` instance from which this class was instantiated, and it has a
class method, `::from_collection` to instantiate itself in bulk.

If you're not familiar with the `Forwardable` module, I've written about it
elsewhere: [Delegation Patterns in Ruby](http://radar.oreilly.com/2014/02/delegation-patterns-in-ruby.html). You can also find more in [the official documentation](http://ruby-doc.org/stdlib-2.2.1/libdoc/forwardable/rdoc/Forwardable.html).

In the first incarnation of the `Product` class, I had a class method which
retrieved and instantiated the "promoted" products, but as I thought more
about it, I realized that mehtod belonged in a class designed specifically to
list products.

### The Catalog Class

Catalogs have traditionally grouped products together in a number of ways. It
may have been by age and gender, or by department, such as housewares or
sporting goods, and oftentimes they even have listings for discounted items or
best sellers. We're going to take a queue from the real world object and model
our catalog after it.

Because we're currently only interested in listing the promoted products, let's
start by creating a method to retrieve them.

``` ruby
class Catalog
  attr_accessor :stored_products

  def initialize(collection=nil)
    @stored_products = collection.presence || DB::Product.all
  end

  def promoted_products(qty=10)
    Product.from_collection(self.stored_products.limit(qty))
  end
end
```

The catalog can be instantiated with a provided collection (so we could
instantiate it with a scope), or it can use the default scope (In Rails 3.2 or
lower, use `DB::Product.scoped`). Once instantiated, we can retrieve the
promoted products (a collection of `Product`s).

The astute reader will notice that "promoted products" are returning the first
ten products, there's nothing "promoted" about them. We'll figure out how to
best handle that later.

### The Root Problem

We've done a lot of work so far. We have a namespaced ActiveRecord model for the
products table, a class which acts as an interface for that model, another class
which can instantiate groups of products, and a resource through which to
display our products. Now we're ready to tie the backend to the front. We'll do
that with the `RootPage` class.

``` ruby
class RootPage
  def promoted_products
    Product.from_collection(Catalog.new.promoted_products)
  end
end
```

And now the `sites/index.html.erb`

``` ruby
<div id="products-promoted">
<%= @root_page.promoted_products.each do |product| %>
  <div class="product-thumbnail">
    <%#= image_tag product.image_url(:thumbnail) %>
    <ul>
      <li><%= product.name %></li>
      <li><%= product.price %></li>
    </ul>
  </div>
<% end %>
</div>
```

This class, as I learned from [this ThoughtBot article](https://robots.thoughtbot.com/sandi-metz-rules-for-developers) uses the
[Facade Pattern](http://c2.com/cgi/wiki?FacadePattern). The pattern "provides a
unified interface to a set of interfaces in a subsystem". In the one method
shown above, we have an interface to the catalog of products, but it's easy to
imagine other methods which might return collections of products such as
"deals", or "recommended products". We could also `include` common sets of
methods which would provide interfaces for a shopping cart or user specific
menus.

This one `RootPage` class is the only thing we'll need to instantiate in the
controller. It's also the only thing the view will need.

## So What?

This seems like an awful lot of effort just to display ten products on a landing
page. Could you imagine what the original ["Create a Blog in 15 minutes with Ruby on Rails" video](https://www.youtube.com/watch?v=Gzj723LkRJY) would look
like had DHH developed it like we've done above? And we've really only just
begun. Forms, authentication, authorization, model associations, are all going
to be affected by developing in this manner.

Is it worth it? I don't know yet. I've used some of the above techniques in real
projects with some success, but I also know creating classes for every single
form is a pain in the backside, and I've never namespaced ActiveRecord models
before. I've also never strictly followed Sandi's Rules either. I have some
concerns about how it's all going to work with authentication and authorization.
I'm also concerned that taking things to this extreme will eliminate the
usefulness of some gems, such as kaminari, which I believe is more performant
with `ActiveRecord::Relation` than changing it to an array.

Ruby on Rails is a framework, and it wants things done a certain way. There are
certainly areas in the framework where you can break all the rules, but there
are other areas where breaking rules requires a higher price to be paid. As we
continue to hide the persistence layer away from the Controllers and View
layers, we'll see that price become increasingly more pronounced.

Tests definitely run faster. Feature tests and tests for ActiveRecord scopes are
currently the only thing which need to hit the database. Everything else should
remain separated from the database and thus, wicked fast.

In the next post we'll look at how we can speed up tests for both ActiveRecord
models and non-ActiveRecord models as well.
