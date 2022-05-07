---
title: "ActiveRecord::Base.store - Pros, Cons, and Usage"
description: "Using the new Store feature in Rails 3.2 and some of the pros and cons therein."
date: 2012-04-02
comments: true
post: true
categories: [ruby on rails, activerecord, sql, databases]
---

In [my post on `ActiveRecord`'s new `explain`method](//samuelmullen.com/2012/03/understanding-activerecord-base-dot-explain/), I mentioned there were "two"  features in ActiveRecord (introduced in Rails 3.2) I wanted to look at. This post covers the second method: `ActiveRecord::Base.store`.

`Store` provides a simple means of accessing and storing key/value pairs related to a model. The [API documentation](http://api.rubyonrails.org/classes/ActiveRecord/Store.html) uses the example of a `User` model which has settings. "Settings" may not in themselves warrant their own model, but there still needs to be a means of accessing them. This is where `Store` comes in to play.

Behind the curtain, store is just a `Hash` which gets serialized and deserialized upon save and load. It has a few accessors added in to make it look less hashy, but the hash is still there nonetheless as we'll see later.

Prior to Rails 3.2, if you needed this functionality you had three choices: 1) implement it yourself; 2) Muck up your table with a bunch of extra fields; 3) create another table to store all the fields.

For the sake of laziness, I'll use the same project I used in [my previous post](//samuelmullen.com/2012/03/understanding-activerecord-base-dot-explain/): [https://github.com/samullen/ar_explain](https://github.com/samullen/ar_explain)

## Setup
In our example, we're going to allow users to toggle the different types of email they want to receive. The first thing we'll need to do is add the field in which to store the settings.

``` ruby
class AddContactSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contact_settings, :string, :limit => 4096
  end
end
```

You'll likely need some space for your settings so set the `string` limit to something large. Alternatively, you can use `text` instead of `string` if you like, but I tend to run more conservative.

Next, we'll need to let the user model know we'll be using the `contact_settings` field as a store.

``` ruby
class User < ActiveRecord::Base
  store :contact_settings, accessors: [ :daily_email, :weekly_email, :account_email ]
  
  has_many :owner_restaurants
end
```

Well that wasn't too difficult.

### Usage
Like I said, the field used as the store is really just a hash. You can see that in the console when I retrieve the first user record:

``` ruby
1.9.3p125 :001 > u = User.first
  User Load (0.3ms)  SELECT `users`.* FROM `users` LIMIT 1
 => #<User id: 1, name: "John Galt", email: "john@galtsgulch.com", created_at: "2012-03-08 01:50:22", updated_at: "2012-03-08 01:50:22", contact_settings: {}> 
1.9.3p125 :002 > u.contact_settings
 => {} 
1.9.3p125 :003 > u.contact_settings.class
 => Hash 
```

Instead of accessing the attributes through `contact_settings` as you would a normal `Hash`, you access them as if they were attributes on the model itself.

``` ruby
1.9.3p125 :005 > u.weekly_email = true
 => true 
1.9.3p125 :006 > u.account_email = true
 => true 
1.9.3p125 :007 > u.daily_email = false
 => false 
1.9.3p125 :008 > u
 => #<User id: 1, name: "John Galt", email: "john@galtsgulch.com", created_at: "2012-03-08 01:50:22", updated_at: "2012-03-08 01:50:22", contact_settings: {:weekly_email=>true, :account_email=>true, :daily_email=>false}> 
1.9.3p125 :009 > u.contact_settings
 => {:weekly_email=>true, :account_email=>true, :daily_email=>false} 
```

As mentioned earlier, `store` fields are just hashes. This means you can access them and use methods on them just like any other hash. You can even add attributes not defined in the store.

``` ruby
1.9.3p125 :010 > u.contact_settings[:foo] = "bar"
1.9.3p125 :012 > u.contact_settings
 => {:weekly_email=>true, :account_email=>true, :daily_email=>false, :foo=>"bar"} 
```

If we were to save the record and look at it in the database (without `:foo => "bar"`), it would look like this.

```
mysql> select * from users;
+----+--------------+----------------------+---------------------+---------------------+-------------------------------------------------------------------+
| id | name         | email                | created_at          | updated_at          | contact_settings                                                  |
+----+--------------+----------------------+---------------------+---------------------+-------------------------------------------------------------------+
|  1 | John Galt    | john@galtsgulch.com  | 2012-03-08 01:50:22 | 2012-04-04 11:23:47 | ---
:weekly_email: true
:account_email: true
:daily_email: false
 |
|  2 | Howard Roark | howard@architect.com | 2012-03-08 01:50:22 | 2012-03-08 01:50:22 | NULL                                                              |
+----+--------------+----------------------+---------------------+---------------------+-------------------------------------------------------------------+
```

## Pros

I think many of the "pros" for ActiveRecord.store are pretty obvious: it eliminates the need for yet another table or extra fields; simplifies adding new attributes; they work just like normal model attributes. Did I mention that validations work on Store attributes? They do, and [Rafal Wrzochol](https://plus.google.com/117671343455128545584) has [a great write up on using them](http://blog.rawonrails.com/2012/02/using-activerecordstore-with-rails-32.html)

So what are the drawbacks?

## Cons

There are a number of philosophical reasons against using the new Store feature. The main argument against is that the data really isn't normalized. But we're using Rails, which means we have a tendency to abuse normalization for the sake of the application anyway.

Another minus is that dirty attributes don't work quite as well in the Store. For instance, you can't call `User#weekly_email_changed?`. The only thing you can do is check if the Store field has changed (e.g. `User#contact_settings_changed?`). Again, it's not really a huge issue and I imagine this will get resolved in future releases.

Really the main "con" with regard to using store - and this really is a big deal - is that you can't perform efficient searches on the field. The only way to perform a search is by surrounding the search term with "%" characters. 

``` sql
SELECT * FROM users WHERE contact_settings LIKE '%weekly_email: true%';
```
If the percent sign was just on the end, that would be one thing, but with the leading "%" it's now the slowest possible way of searching the database.

I really think the new Store feature in Rails 3.2 is a nice feature. They've done it well and made its usage fairly seamless (i.e. store attributes look and act like any other attribute). If your application's database is fairly large or if you plan on running a lot of queries against the attributes in the Store (e.g. gathering lots of metrics) you may want to use a separate table. For most applications out there, however, this is a very safe and sane solution.

## Further Reader
* [ActiveRecord::Store](http://api.rubyonrails.org/classes/ActiveRecord/Store.html)
* [Ruby on Rails 3.2 Release Notes - Section 8](https://plus.google.com/117671343455128545584/posts)
* [Using ActiveRecord::Store with Rails 3.2](http://blog.rawonrails.com/2012/02/using-activerecordstore-with-rails-32.html)
