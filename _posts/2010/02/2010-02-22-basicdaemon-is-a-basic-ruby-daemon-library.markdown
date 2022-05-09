---
title: BasicDaemon is a Basic Ruby Daemon Library
date: 2010-02-22
post: true
categories: [ruby, gems, daemons, basic daemon]
---
There have been a number of occasions when I have needed to a background process running: image manipulation, content transfer, queuing emails, etc. Initially I wrote the piece which forked off the parent process by hand. Not having read Richard Stephens sections on daemons ([Advanced Programming in the Unix Environment](http://www.amazon.com/gp/product/0321525949?ie=UTF8&tag=themulfam-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321525949)) closely enough, I ended up with processes which didn't get forked enough. Hrmm, this paragraph is going downhill quickly.

Realizing I was wasting a lot of time and making my code look like utter garbage, I began looking for a Ruby library which could replace and correct my forking code. The libraries I found (ctrl-f for daemon on [ruby-toolbox](http://ruby-toolbox.com)) either did way too much, did things antithetical to what I was wanting, or was questionable.

Long story short: I wrote my own. I named it [BasicDaemon](http://github.com/samullen/basic_daemon) because it's just a basic daemon library; well, that and [simple_daemon](http://github.com/bryanl/simple-daemon) was already taken. It runs in two different ways: 1) you can subclass it and override the run method; 2) you can pass a block to it.

Here's an example of subclassing BasicDaemon:
``` ruby
!/usr/bin/env ruby

require 'rubygems'
require 'basic_daemon'

class MyDaemon < BasicDaemon
  def run
    foo = open("/tmp/out", "w")

    i = 1

    while true do
      foo.puts "loop: #{i}"
      foo.flush
      sleep 2

      i += 1
    end
  end
end

d = MyDaemon.new

if ARGV[0] == 'start'
  d.start
elsif ARGV[0] == 'stop'
  d.stop
  exit!
elsif ARGV[0] == 'restart'
  d.restart
else
  STDERR.puts "wrong! use start, stop, or restart."
  exit!
end

exit
```

Here's the example passing a block:

``` ruby
#!/usr/bin/env ruby

require 'rubygems'
require 'basic_daemon'

basedir = "/tmp" 

d = BasicDaemon.new

# for restarts to work properly, you can't use anonymous blocks. In other
# words, blocks have to be assigned to a variable
process = Proc.new do
  i = 1
  foo = open(basedir + "/out", "w")

  while true do
    foo.puts "loop: #{i}"
    foo.flush
    sleep 2

    i += 1
  end
end

if ARGV[0] == 'start'
  d.start &process
elsif ARGV[0] == 'stop'
  d.stop
  exit!
elsif ARGV[0] == 'restart'
  d.restart &process
else
  STDERR.puts "wrong! Use start, stop, or restart."
  exit!
end

exit
```

As you can see, both examples do the same thing: they put a loop into the background which logs the number of loops to a file (out) in /tmp. Wheeee!

That's about it. There are a couple parameters you can set to define where the pidfile will be located or named, but not much more. You can [check out the code](http://github.com/samullen/basic_daemon) on [GitHub](http://github.com). If you don't care about checking out the code, you can just install it from gemcutter with the following command:

``` ruby 
sudo gem install basic_daemon
```

And of course, wouldn't you know it, as soon as I tagged it v1.0.0 and pushed everything out, I realized something I could add to make it better. I guess that's what v2.0.0 is for.
