---
author: "Samuel Mullen"
date: "2016-09-17T07:07:04-05:00"
description: "Reducing object bloat begins with doing less"
tags: ["ruby", "patterns"]
title: "Delegation Patterns in Ruby"
canonical: "http://radar.oreilly.com/2014/02/delegation-patterns-in-ruby.html"
---

**Note:** *I originally wrote this article for O'Reilly Publishing. I'm reposting it here with permission, and referencing the [canonical link](http://radar.oreilly.com/2014/02/delegation-patterns-in-ruby.html).*

In almost every project there are those objects which seemingly get involved in every aspect of the application.  These are the so-called “god objects”: they can do everything (omnipotent), they know everything (omniscient), and they are everywhere in the application (omnipresent). Most often these are objects which are at the intersections of business logic: User or Account, Project, and Order are all usual suspects.

One of the core tenants of object-oriented programming is that large problems are made up of many smaller problems, and as such, can be solved by providing solutions to those smaller problems in the form of objects. God objects violate this core tenet by trying to be one solution for too many problems.

A typical example of a god object is the User model of many Rails applications.  Here, User might be responsible for user specific information as well as knowing about phone numbers, emails, profile information, preferences, and handling authentication. It’s too much and it results in User being coupled to every aspect of the application.

Although there are many tactics a developer can employ to limit the influence of these “god objects”, one of the simplest is just reassigning some of their responsibility, and using a delegation pattern may be the simplest way to do just that.

Let’s look at four different ways we can use delegation in Ruby.

Delegation by Default
---------------------

The act of delegation in Object Oriented Programming is so common we oftentimes don’t even realize when it’s happening. Take “inheritance” for example: when you create a subclass, you inherit all the parent class’s public methods, and unless those methods are overwritten, any calls to the inherited methods are passed to the parent class.

Even in methods which are overwritten, specifically calling the superclass’s method through the use of super, is delegation, because the child class is relying on the parent to accomplish what it doesn’t need to.

Here’s an example of what I mean:

```
class Report
  def records
    # return a list of report records
  end

  def print
    # output the report
  end
end

class InTriplicateReport < Report
  def print
    super
    super
    super
  end
end

report = InTriplicateReport.new
report.records # => returns the records in the report
report.print # => Prints the report in triplicate
```

Here we see that `InTriplicateReport` inherits both records and print from the `Report` class. `InTriplicateReport` doesn’t overwrite records, but instead relies on the parent to handle the responsibility. On the other hand, print is overwritten, but we still rely on the parent through our multiple calls to super. In each case, `InTriplicateReport` delegates responsibility to the parent `Report` class rather than duplicating effort and code. Later, as requirements change, records or print can be further modified, but until then, it’s best to allow `Report` to handle the logic.

Explicit Delegation
-------------------

So inheritance is delegation, but really any time you use another object to perform logic instead of keeping it within the class itself, you are delegating.

In the Report class below, the `#print` method accepts an object which will handle transforming the report data into a specified format (XML, CSV, and JSON). The `Report` class doesn’t "care" about the final output, it just wants to output it, and so it delegates the actual formatting to one of the formatter objects.

```
class Report
  def records
    # lists all the reports records
  end

  def print(delegate)
    # logic to handle output
      delegate.generate(self.records)
    # closing logic
  end
end

class CSVFormatter
  def generate(records)
    # formats to CSV
  end
end

class XMLFormatter
  def generate(records)
    # formats to XML
  end
end

class JSONFormatter
  def generate(records)
    # formats to JSON
  end
end

report = Report.new
report.print(CSVFormatter.new) # outputs to CSV
report.print(XMLFormatter.new) # outputs to XML
report.print(JSONFormatter.new) # outputs to JSON
```

The formatter objects being passed in are the delegates; they handle converting the data to the desired format, while `Report` maintains focus on outputting the formatted data. By delegating responsibility in this instance, we keep our objects focused on performing a single function (see: [Single Responsibility Principle](http://en.wikipedia.org/wiki/Single_responsibility_principle)), decouple our logic, and generally make life easier for ourselves.

This style of delegation is commonly used in statically typed languages such as .Net, Java, and Objective-C. In those languages, the delegate must conform to a sort of contract called an “Interface” or “Protocol”. Thankfully, Ruby doesn’t have such hang-ups and assumes that if the object walks like a duck and quacks like a duck, it’s a duck.

Delegation with method_missing
------------------------------

Delegation in Ruby begins to get really interesting when you hide the fact that another object is even involved. For this example, let’s assume we’re working on an e-commerce system. This system will have “orders” which, in turn, can have zero or more products and will relate to each of those products through a line item. Let’s further assume that we would like to access product information, such as “sku”, “name”, “description”, and “price”, directly from the `line_item` object rather than chaining out to the `product` instance (e.g. `line_item.product_sku` instead of `line_item.product.sku`).

We can do this using Ruby’s `method_missing`, a method inherited from `BasicObject`, and which catches messages sent to an object which are not explicitly defined.

```
class Order
  def line_items
    # collection of LineItems
  end
end

class LineItem
  attr_reader :product

  def initialize(product)
    @product = product
  end

  def method_missing(method, *args)
    if method.to_s.match(/product_(.+)/)
      self.product.send($1, *args)
    else
      super
    end
  end
end

class Product
  attr_accessor :sku, :name, :description, :price
  # product related methods
end
```

In our example, `method_missing` looks to see if the message passed begins with “product_”, if it does, it passes that message (sans “product_”) on to the product instance. If the message doesn’t match the pattern, it passes it on up the call chain with super.

Now, if we were to list the line items from an order we could do something like this:

```
puts "SKU,Name,Price"

order.line_items.each do |line_item|
  puts "%s,%s,%s" % [line_item.product_sku, line_item.product_name, line_item.product_price]
end
```

Although it looks as if we are calling specific methods on the `line_item` object, in reality we’re delegating the messages to the `product` object.

Delegation with Ruby’s Forwardable
---------------------------------

In the above example, we used `method_missing` to delegate all methods beginning with "product\_" not defined in `LineItem` to the `Product` class. The advantage here is that it handles all current and future `Product` methods. If a new method, such as `serial_number`, is added, `LineItem` can immediately begin using it without any alterations to the code.

On the other hand, if you need to be more specific about which methods are allowed to be delegated, Ruby’s `Forwardable` module is a better solution.

Here’s the same `LineItem` class, rewritten using the `Forwardable` module.

```
include Forwardable

class LineItem
  extend Forwardable

  def_delegators :@product, :sku, :name, :description, :price

  attr_reader :product

  def initialize(product)
    @product = product
  end
end
```

In the above code, we extend `Forwardable` into `LineItem`, add the `def_delegators` line, and remove `method_missing` altogether.

The `def_delegators` line is pretty straightforward: it states that any call to sku, name, description, and price, should be instead handled by the `@product` instance variable (note: we could have written :product since we’ve defined it with `attr_reader`)

Where previously we prepended "product\_" to delegated methods, now we can call the method directly, because there’s no longer a need to distinguish product specific methods for `method_missing`.

Here’s our output rewritten to take advantage of the refactoring:

```
puts "SKU,Name,Price"

order.line_items.each do |line_item|
  puts "%s,%s,%s" % [line_item.sku, line_item.name, line_item.price]
end
```

If you wanted to keep the "product\_" prepended to the method calls – maybe to keep from overwriting another method of the same name – you would need to use `def_delegator` instead. However, doing so will limit you to defining one delegator at a time.

```
class LineItem
  extend Forwardable

  attr_reader :id

  # avoid overwriting LineItem#id
  def_delegator :@product, :id, :product_id
  def_delegators :@product, :sku, :name, :description, :price

  ...

end
```

In Object Oriented Programming, delegation is an incredibly useful pattern, and – as is so often the case in Ruby – there are numerous ways to implement it. It is not some elusive concept which is difficult to nail down, but one which we encounter regularly through typical OO development.

Not only is delegation simple, it is powerful in that it allows us to limit the power of our objects.  Through effective use of inheritance, message passing, and forwarding of responsibility, we can create opportunities to segment our classes and delineate responsibility. Delegation helps us bring those “god objects” back down to earth.
