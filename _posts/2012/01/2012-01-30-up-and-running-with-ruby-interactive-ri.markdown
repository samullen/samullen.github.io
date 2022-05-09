---
title: "Up and Running With Ruby Interactive (ri)"
description: "An overview of the usage and benefits of Ruby's Interactive CUI
(ri)"
date: 2012-01-30
comments: true
post: true
categories: [ri, ruby, documentation]
---
Unbenownst to many Ruby developers, Ruby has a wonderful CUI (Composite User Interface) for referencing the API of the language and all available libraries: `ri`. `ri` stands for "Ruby Interactive", which is an odd name for a tool to navigate documentation, and one which inevitably gets confused with `irb` (Interactive RuBy). Seriously, try Googling "Ruby Interactive".

Perhaps it is due to the popularity of editors such as [TextMate](http://macromates.com/) or [Sublime](http://www.sublimetext.com/2), or perhaps because it is the ease of finding documentation through [Google](http://google.com), but it seems that most developers either don't know about, or don't use `ri`. I do, but I'm a command-line junkie and I've not found another tool which is as simple or as accessible as plain old `ri`.

## Getting Started
If you have Ruby installed, you should have all that's necessary to play around
with `ri`. If you are have troubles, look at "Troubleshooting" below.

To try it out, at the command-line type `ri` followed by the class or method you want documentation about. Typing `ri Array` should show you the docs for the Array class. If you type `ri Array.min`, `ri` will provide the documentation for Array's `min` instance method. To be very specific about things, use a `::` or `#` for class and instance methods rather than the generic `.`.

Example:

``` bash
ri Array::wrap # class method lookup
ri Array#min # instance method lookup
```

One really useful feature of the tool is the suggestions `ri` provides when you enter only part of what you are looking for. Try it out:

``` bash
$ ri Enumerable.each
Enumerable.each not found, maybe you meant:

Enumerable#each_cons
Enumerable#each_entry
Enumerable#each_slice
Enumerable#each_with_index
Enumerable#each_with_object
```

Neat. I didn't know about `#each_with_object`.

## In Technicolor
You may have noticed that all the documentation is in black and white - or at least you would have if you were using my color scheme. If you want to add a little color to your output, use the "ansi" format.

``` bash
ri -f ansi Array.sort
```

If you like this, you can set up an alias in your .bashrc or .zshrc.

``` bash
alias ri='ri -f ansi'
```

Make sure not to use a direct path to `ri` since RVM projects will have `ri` located somewhere else. You want to use your project's instance of `ri`.

## It's All About the Interactive

It might surprise you to learn that "Ruby Interactive" actually has an "interactive" mode. You can start `ri` in interactive mode by passing the `-i` flag.

Here's what that looks like:

``` bash
 $ ri -i

Enter the method name you want to look up.
You can use tab to autocomplete.
Enter a blank line to exit.

>> 
```

At the prompt, just type in what methods, classes, or what-have-you and hit return. To exit, just hit return again, or the ever available ctrl-d.

Unlike calling `ri` with a specific parameter, interactive mode will, like an inquisitive child, keep prompting you to search again.

## VIM and ri
It's not always convenient to drop down to the command-line just to look up documentation. Wouldn't it be cool if you could search the docs from your favorite editor? Daniel Choi thought so and created the excellent [ri_vim](https://github.com/danchoi/ri_vim) plugin. It's easy to install, but you will need to install it in each RVM project you want to use it in.

`ri` isn't for everybody and that's cool, but for those of us who are more at home at the command-line than in our own house, it's indispensible. Try it out for yourself, you may very well find it's more accessible and useful than you realized.

## Troubleshooting
If you are not in an RVM project and you are unable to find `ri` documentation,
try this:

``` bash
gem install rdoc rdoc-data
rdoc-data --install
```

If you are in an RVM project, this should clear things up.

``` bash
rvm docs generate-ri
```

## Further Reading
* [Regenerating Ruby ri documentation](http://kedarm.posterous.com/regenerating-ruby-ri-documentation)
* [The ri_vim plugin](https://github.com/danchoi/ri_vim)
