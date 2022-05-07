---
title: 'inotify: When You Absolutely, Positively Have to Know About it Right Now.'
date: 2009-12-20
post: true
categories: [amqp, ruby, inotify]
---

At [Universal Uclick](http://universaluclick.com), I deal with a lot of files. Comics, puzzles, advice columns, etc.: If it can be syndicated online, I handle it. Content is retrieved in a variety of ways (FTP, HTTP, internal filesystems [Samba, NFS, etc.]) and from a variety of sources. Because the content I deal with has deadlines and because our creators occasionally (almost never [wink, wink, nudge, nudge]) make a mistake, I've spent a lot of time trying to figure out the best way to retrieve files into our system as quickly as possible.

When I was first hired, files which had not been modified for over 30 minutes were considered safe to pull into the system. This really wasn't ideal since, when combined with other parts of our system, moving a file from it's origination to it's final destination could take upwards of two hours. After rewriting a couple of key pieces and tweaking some other areas, I managed to reduce the time to about ten minutes.

I did a lot of things correctly in my initial rewrites - moving from croned processes to resident (daemon) processes - but I was still relying (incorrectly) on modification times to determine if a file was safe to bring into the system.

What I needed was a way of determining if a file had been closed (i.e. finished downloading) or not and some means of kicking off a process as soon as it was. I knew it was possible, [Dropbox](http://getdropbox.com) was doing it and it just seemed like a very Unixy sort of thing. Most of the research I did resulted in people performing a system call to the [lsof](http://en.wikipedia.org/wiki/Lsof) command to determine if anything was accessing the file. That's fine I suppose, but 1) system calls such as this carry with them a bit of overhead; 2) I'm never confident about the consistency of the response between systems; and 3) it's a hack. I knew that if there was a command which could be called, there had to be library available to do the same thing.

After a bit of research I ran across the [inotify](http://en.wikipedia.org/wiki/Inotify) library. The first paragraph of the manpage reads: 

> The inotify API provides a mechanism for monitoring file system events.  Inotify can be used to monitor individual files, or to monitor directories.  When a directory is monitored, inotify will return events for the directory itself, and for files inside the directory.

I could use the inotify system commands to kick off processes, but I'm not too keen on a process being launched for each of a 100+ files that might get uploaded simultaneously. The alternative, in my case, was to use a ruby library for inotify.

The library I chose is Nex3's [rb-inotify](http://github.com/nex3/rb-inotify). It's dead simple and sits right on top of the C libraries (errr, pretty much). To use it you just instantiate it, give it a directory to watch and conditions to watch for, and a blob of code to execute when the conditions are met. A simple example might look like this:

``` ruby
#!/usr/bin/env ruby

require 'rb-inotify'

notifier = INotify::Notifier.new

notifier.watch("/path/to/watch", :moved_to, :create) do |event|
  puts "I found #{event.name}!"
end
notifier.run
```

This example just prints "I found &lt;filename&gt;!" any time a file is moved into or created within the "/path/to/watch" directory.

For the most part, this would work for us as long as we weren't doing anything too intensive with the files. Unfortunately, we are. Our system has to resize PDF, EPS, and TIFF files to web version, process crosswords and sudoku files, make sure everything is formatted correctly, move the files to our storage system, and so on and so forth. There are two main problems with this scenario as it stands: 1) if the system goes down while there are files which have yet to be processed, someone (myself) will have to fire the triggering event to get the files processing again; 2) This only works for one machine. It's not scalable.

The two problems above are the reasons I ignored inotify as a possible solution last year when I began redesigning our digital asset management system (DAM). Since then, however, we began using <a href="http://rabbitmq.com">RabbitMQ</a> (an AMQP queueing system) for some of our processing and it occurred to me (thanks to Mike Admire) that I could combine the two technologies to achieve my goals.

Now, rather than processing files as they come into the system, I just send RabbitMQ a blob of JSON which other processes on other servers then retrieve to perform the necessary processing. Since the queueing is performed so quickly, I really don't need to worry about missing anything if the server dies unexpectedly - I just have to worry about the server dying unexpectedly.

Now, full disclosure: I really don't need to know the exact moment a file is done downloading. We've never received so many files in a single day so as to necessitate worrying about every second. Still, I feel better knowing that I'm doing things properly, using the libraries at my disposal, instead of some hack.
