---
title: "Understanding ActiveRecord::Base.explain in Rails 3.2"
description: "Understanding ActiveRecord::Base.explain in the Rails 3.2 release"
date: 2012-03-07
comments: true
post: true
categories: [activerecord, databases, ruby on rails, SQL]
---
With the [release of Rails 3.2](http://guides.rubyonrails.org/3_2_release_notes.html), comes a host of new features. There are two in particular in ActiveRecord which seem to have attracted a lot of attention, so I thought I would look at them each more closely. This post, as you have no doubt realized from the title, is focused on `ActiveRecord::Base.explain`

This may come as a shock, but `explain` is only *new* in Ruby on Rails; it - or similar features - has been around in the database world forever. Stated most simple, "The `EXPLAIN` statement provides information about the execution plan for a `SELECT` statement." ([MySQL 7.8.2. EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html)) In other words, when you `explain` a query, the database returns information about how it is going to go about finding all the data. It's a very useful tool which can help developers uncover why queries are running slowly and what might be done to speed them up.

Let's look at an example so we can see the value of `explain`.

## Schema Setup
We'll need a couple tables with data for our example. I'll use users and user_restaurants. 

``` ruby
class CreateUsers < ActiveRecord::Migration                                     
  def change                                                                    
    create_table :users do |t|                                                  
      t.string :name                                                            
      t.string :email                                                                
      t.timestamps                                                                  
    end                                                                         
  end                                                                           
end
```
``` ruby
class CreateUserRestaurants < ActiveRecord::Migration                       
  def change                                                                    
    create_table :user_restaurants do |t|                                  
      t.integer :user_id                                                        
      t.string :name                                                                  
      t.boolean :like                                                                 
      t.timestamps                                                              
    end                                                                         
  end                                                                           
end    
```

The users table is self-explanatory. user_restaurants, on the other hand, is a table of restaurants a user likes (I guess that's self-explanatory as well.)

Well need a couple of users, so let's add them here.

``` ruby
class AddUsers < ActiveRecord::Migration                                        
  def up                                                                        
    User.create(:name => "John Galt", :email => "john@galtsgulch.com")          
    User.create(:name => "Howard Roark", :email => "howard@architect.com")      
  end                                                               
end
```

And our users will want to "like" or "dislike" restaurants, so we'll need to create the liked restaurant records. I'll name the restaurants "Restaurant n" to save myself from having to come up with 100,000 restaurant names. We'll split those restaurants between the two users and define 20% of them to be restaurants the users did not "like".

``` ruby
class AddRestaurants < ActiveRecord::Migration                                  
  def up                                                                        
    users = User.all                                                            
                                                                                
    100000.times do |i|
      UserRestaurant.create(:user_id => i % 2 == 0 ? users.first.id : users.second.id, :name => "Restaurant #{i}", :like => i % 5 == 0 ? false : true)                
    end
  end
end 
```

## Model Associations
The last thing we have to do is associate the users table to the user_restaurants table.

``` ruby
class User < ActiveRecord::Base
  has_many :user_restaurants
end

class UserRestaurant < ActiveRecord::Base
  belongs_to :user
end
```

## Explain Round 1
Okay, we've created our tables and populated them with data, and we've got our models and associations. Let's run a query to find "John Galt's" favorite restaurants and see what's going on.

``` ruby
User.where(:email => "john@galtsgulch.com").
  joins(:user_restaurants).where("user_restaurants.like = 1")
```

When I run this from the Rails Console, `explain` kicks in automatically and returns the table below (this is output from MySQL, PostgreSQL looks and is worded differently). "Active Record monitors queries and if they take more than [`config.active_record.auto_explain_threshold_in_seconds`] their query plan will be logged using warn." ([What's new in Edge Rails: EXPLAIN](http://weblog.rubyonrails.org/2011/12/6/what-s-new-in-edge-rails-explain))

*Note:* To manually execute explain on a query, just append `.explain` to it. 

```
+----+-------------+------------------+------+---------------+------+---------+------+--------+--------------------------------+
| id | select_type | table            | type | possible_keys | key  | key_len | ref  | rows   | Extra                          |
+----+-------------+------------------+------+---------------+------+---------+------+--------+--------------------------------+
|  1 | SIMPLE      | users            | ALL  | PRIMARY       | NULL | NULL    | NULL |      2 | Using where                    |
|  1 | SIMPLE      | user_restaurants | ALL  | NULL          | NULL | NULL    | NULL | 100041 | Using where; Using join buffer |
+----+-------------+------------------+------+---------------+------+---------+------+--------+--------------------------------+
```

The columns you're going to be most interested in are "key" and "rows". The "key" columns lists the indexes, if any, the database uses to find data. "The rows column indicates the number of rows MySQL believes it must examine to execute the query." [7.8.2. EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html)

In the output above, we can see that the query would use no indexes, and would have to search through 100,041 rows (Hey, that's more rows than are in the database). "For InnoDB tables, this number is an estimate, and may not always be exact." [7.8.2. EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html)

## Database Refactoring
Let's add some indexes to a couple of the key table columns and see if we can't reduce the pain.

``` ruby
class AddTableIndexes < ActiveRecord::Migration
  def up
    add_index :users, :email
    add_index :user_restaurants, :user_id
    add_index :user_restaurants, :like
  end
end
```

Now, when we run our query it still issues an explain (because it's a really stupid example), but we now see how adding the indexes improved performance.

```
+----+-------------+------------------+------+------------------------------------------------------------------+-----------------------------------+---------+---------------------+-------+-------------+
| id | select_type | table            | type | possible_keys                                                    | key                               | key_len | ref                 | rows  | Extra       |
+----+-------------+------------------+------+------------------------------------------------------------------+-----------------------------------+---------+---------------------+-------+-------------+
|  1 | SIMPLE      | users            | ref  | PRIMARY,index_users_on_email                                     | index_users_on_email              | 768     | const               |     1 | Using where |
|  1 | SIMPLE      | user_restaurants | ref  | index_user_restaurants_on_user_id,index_user_restaurants_on_like | index_user_restaurants_on_user_id | 5       | ar_explain.users.id | 25010 | Using where |
+----+-------------+------------------+------+------------------------------------------------------------------+-----------------------------------+---------+---------------------+-------+-------------+
```

## Improvements
Looking at the new `explain` output, we see two things: 1) the query is now using the indexes we created; and 2) the number of potential rows that have to be searched through has been quartered.

It may not seem like a big deal that we went from two to one for the search by email, but imagine if you had 10,000 users, and by using the index here it was still able to go directly to that one record. And if the data we were searching for was something other than a boolean, as it is with the "like" column, we would be able to further reduce the number of potential records through which were searched.

Of course, if we didn't have our handy dandy `explain` tool we might not even have realized it was a database problem to begin with.

As I alluded to in the beginning, there is nothing new about `explain`. It's an excellent tool which provides insight into what course of action the database will take to find the data you are searching for. I've been using `explain` for some time directly from the database command line; it's nice to finally have it accessible from the Rails Console.

I've purposely ignored the various implementations and configurations of `explain` in order to focus more on why it's useful. If you are interested in configuration and implementation, check out [What's new in Edge Rails: EXPLAIN](http://weblog.rubyonrails.org/2011/12/6/what-s-new-in-edge-rails-explain).

##Further Reader
* [What's new in Edge Rails: EXPLAIN](http://weblog.rubyonrails.org/2011/12/6/what-s-new-in-edge-rails-explain)
* [MySQL: EXPLAIN Output Format](http://dev.mysql.com/doc/refman/5.6/en/explain-output.html)
* [MySQL: Optimizing Queries with EXPLAIN](http://dev.mysql.com/doc/refman/5.1/en/using-explain.html)
* [SQLite: EXPLAIN Query Plan](http://www.sqlite.org/eqp.html)
* [PostgreSQL: Using EXPLAIN](http://www.postgresql.org/docs/current/static/using-explain.html)
