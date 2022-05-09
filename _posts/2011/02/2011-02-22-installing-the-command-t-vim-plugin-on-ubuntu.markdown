---
title: Installing the Command-T VIM Plugin on Ubuntu
comments: false
date: 2011-02-22
post: true
categories: [linux, ubuntu, vim]
---
I ran into an issue while installing the Command-T VIM plugin on my Ubuntu box. Once installed, I received this ever so helpful message which trying to launch VIM: 

``` bash
Vim: Caught deadly signal SEGV
Vim: Finished.
Segmentation fault
```

If you've run into the problem too, chances are you're running RVM and your default Ruby is something other than the version used by VIM. Since I installed vim through apt, it's using the default Ruby provided by Ubuntu.

Here's the fix:

1. Go back into your .vim/ruby/commnd-t directory.
2. Type: make clean
3. Type: rvm system
4. Type: ruby extconf.rb
5. Type: make

That fixed it for me, hopefully it fixes it for you too.
