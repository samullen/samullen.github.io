---
title: David Chelimsky's Answer to Testing Named Scopes
date: 2011-03-18
comments: false
post: true
categories: [activerecord, rspec, ruby on rails, scopes]
---
I was looking for the best way to test named scopes in Rails using Rspec and I ran across the following answer by David Chelimsky (Rspec's creator) in the Rspec Google Group:

``` ruby
describe User, ".admins" do 
  it "includes users with admin flag" do 
    admin = User.create! :admin => true 
    User.admin.should include(admin) 
  end 
 
  it "excludes users without admin flag" do 
    non_admin = User.create! :admin => false 
    User.admin.should_not include(non_admin) 
  end 
end 
 
class User < ActiveRecord::Base 
  named_scope :admins, :conditions => {:admin => true} 
end 
```

Read [the entire thread](http://groups.google.com/group/rspec/browse_thread/thread/6706c3f2cceef97f) for context.
