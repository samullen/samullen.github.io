---
title: "Getting More Out of the Rails Console"
description: "A general overview of some common and uncommon features of the Rails Console."
date: 2012-07-11
comments: true
post: true
categories: [ruby on rails, cli, irb, console, ruby]
---

Even at it's most basic functionality, the console is indispensable in the Rails
developer's arsenal of tools. Whether it's running a query, testing a chain of
methods, or executing small blocks of code, the console may be the most useful
tool available to the Rails developer. With that in mind, doesn't it make sense
to do what we can to get the most out of it?

## IRB

### .irbrc

Under the hood, the Rails Console is just IRB (Interactive Ruby), so anything
you can do with IRB, you can do in the console. This means you can modify your
IRB environment and .irbrc file to define methods to use  at the console. Here
are three methods I frequently use: 

``` ruby
\# return a sorted list of methods minus those which are inherited from Object
class Object
  def interesting_methods
    (self.methods - Object.instance_methods).sort
  end
end

\# return an Array of random numbers
class Array
  def self.test_list(x=10)
    Array(1..x)
  end
end

\# return a Hash of symbols to random numbers
class Hash
  def self.test_list
    Array(:a..:z).each_with_object({}) {|x,h| h[x] = rand(100) }
  end
end
```

Of course this isn't even scratching the surface of what's possible. Check out
what other people are doing:

* [Example .irbrc files on github](https://github.com/search?langOverride=&q=irbrc&repo=&start_value=1&type=Code&utf8=%E2%9C%93) 
* [What's Your Favourite IRB Trick?  (StackOverflow)](http://stackoverflow.com/questions/123494/whats-your-favourite-irb-trick)

### The Last Expression

While working in the console, have you ever typed out a bit of code to return a
value and then realize you forgot to assign the returned value to a variable?
You then have to go back into the console history, move your cursor to the
beginning of the line, add the variable, and then execute the code again.

Ugh, what a pain!

Unbeknownst to most people, IRB places the output of the last command into the
`_` variable. Here, let me show you:

``` ruby
 > Array(1..10)
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
 > _
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

Now, as cool as that is, you have to understand that `_` always contains the
output of the last expression. This means if you try call a method on it, it
will then contain the output of the method executed.

``` ruby
 > Array(1..10)
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
 > _
 => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
 >  _.map {|i| i * 2}
 => [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
 > _
 => [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
```

### Forking IRB 

When working in the console, it's sometimes desirable to have another instance
to play with. It may be that you don't want to lose what you were working with,
or you just need another scratch area, but whatever the case, you can create a
new console (IRB) session by calling `irb` at the prompt (note: you'll use `irb`
for the rails console as well).

I typically don't use this. If I need another IRB instance, I just open a new
`tmux` pane or window and work there.

If this sort of method fits your workflow, I highly recommend reading [Gabriel Horner's in depth post on IRB commands](http://tagaholic.me/2009/05/11/demystifying-irb-commands.html) 

## The Rails Console

### Models

One of the things you will want to make extensive use of in the console are your
app's models. The Rails console is a great way to play with your models and an
alternative way of accessing your data.

``` ruby
 > u = User.find 1234; nil
=> nil

 > u.name
 => "Foo Man"

 > u.email = "fooman@example.com"
 => "fooman@example.com"

 > u.save
 => true
```

### The "app" object

The `app` object is used by test processes to mimic system interactions. Through
this object, we can access routing information and even make requests to our
app.

``` ruby
# displaying path information
 > app.users_path
=> "/users/

 > app.user_path(User.last)
=> "/users/42

# making app requests

 > app.get app.user_path(User.last)
=> 200

 > app.response.body
=>  => "<!DOCTYPE html>\n<html>\n  <head>\n    <title>..."

```

### The "helper" Object

I really don't think I can do a better job on this than what Nick Quaranto
already did in his ["Three Quick Rails console tips" post](http://37signals.com/svn/posts/3176-three-quick-rails-console-tips).

### Reloading the Environment

If you make changes to your app while still in the console, you will need to
reload your console session with the `reload!` command. You will also need to
reinstantiate objects which existed prior to the reload for them to recognize
your changes.

``` ruby
 > u = User.find 1234; nil

\# changes made to User model outside the console 

 > reload!
Reloading...
 => true
 > u = User.find 1234; nil
```

### Better Output

At one time it seemed like everyone was writing a gem for improving the IRB
experience, but it appears like that particular endeavor has since been largely
ignored. The one project that appears to be currently active is the
[awesome_print gem](https://github.com/michaeldv/awesome_print).

I've used this gem in the past, and it really does improve the output and
IRB experience. It also supports [pry](https://github.com/pry/pry://github.com/pry/pry/).

In a pinch, you can format the output as YAML with the `y` command.

``` ruby
 > y Array.test_list(5)
---
- 1
- 2
- 3
- 4
- 5
 => nil
```

### Avoiding Output

Running commands in the console can get pretty noisy. Output follows every
command which is run. To get around this, just end your command with a semicolon
and `nil`.

``` ruby
 > u = User.last; nil
=> nil
```

In the above example, `u` still contains the "last" user record, it just doesn't
print out all the output that would normally be produced.

### The Sandbox

Sometimes it would be nice to open up a console session and mess around with the
data to see what happens. But if you do that, the data's messed up. The solution
to that is to lunch the console with the `--sandbox` flag. When launched, you
can handle the data, tweak it, and destroy it, all without fear of harming any
of your data.

``` ruby
rails console --sandbox

Loading development environment in sandbox (Rails 3.2.1)
Any modifications you make will be rolled back on exit
 >

```

## Conclusion

In my workflow, the rails console is an indispensible tool. It allows me to test
out ideas, access the database, run minor tasks, and even calculate basic math.
I can't imagine developing Rails applications without it, because I know how
painful it is to be deprived of such a tool in other languages and frameworks.

What are your favorite IRB and console tricks?
