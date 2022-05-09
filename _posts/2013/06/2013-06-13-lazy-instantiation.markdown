---
title: "Lazy Instantiation"
description: "Lazy instantiation is a simple technique to delay and store the results of a process until it's needed"
date: 2013-06-13
comments: true
post: true
categories: [programming, object oriented programming, techniques]
---

I first heard the term, "lazy instantiation", when I started working in iOS. I'd used the idea before, but didn't have a name for it. The basic idea is to "[delay] the creation of an object, the calculation of a value, or some other expensive process until the first time it is needed." ([Wikipedia](http://en.wikipedia.org/wiki/Lazy_initialization)).

Here's an example in Objective-C:

``` objective-c
- (myClass *)myClass
{
    if (!_myClass){
        _myClass = [[myClass alloc] init];
        [_myClass setUpMyClass]; // this method just loads sounds and some text
    }
    return _myClass;
}
```

## Real World Example

Lately, it seems like all of my projects have needed to access third party APIs. I've been using lazy instantiation to combat unnecessarily calling the external resources. What follows is a simple example of some code for retrieving what's currently playing on [Rdio](http://rdio.com): 

``` ruby
class RdioQueue
  attr_reader :client, :venue

  def initialize(client, venue)
    @venue = venue
    @client = client
  end

  def rdio_user
    @rdio_user ||= self.client.get(:keys => self.venue.uid, :extras => "lastSongPlayed,lastSongPlayTime").values.first
  end

  def rdio_track
    @rdio_track ||= self.rdio_user.lastSongPlayed
  end

  def rdio_track_start_time
    @rdio_track_start_time ||= self.rdio_user.lastSongPlayTime
  end
  
  # ... other unrelated methods ...
end
```

This class is primarily used to retrieve album track information, all of which is handled through the call to Rdio's `user` API. Rather than making a separate call through the Rdio client each time information is needed, we just pass our messages through `rdio_user`. Once it's initially retrieved, the external call is never made again (thanks to the or-equal `||=` operator).

If we needed to perform an action against `rdio_track` further down in our code, we would just call `rdio_track`. There would be no need to first initialize `rdio_user`, it all just happens "just in time"&trade;. At this point, `rdio_user` has its instance variable (ivar) set and further calls to `rdio_user` return immediately, as do calls to `rdio_track`.

## Caveats

Some care must be taken with lazy instantiation. If taken to an extreme, it will result in a [Law of Demeter](http://devblog.avdi.org/2011/07/05/demeter-its-not-just-a-good-idea-its-the-law/) violation.

## Closing

I am not presenting any hidden coding secrets or revelations. None of this is rocket-science, and it's likely you're already using lazy instantiation in a current project. Only, now you have a name for it.
