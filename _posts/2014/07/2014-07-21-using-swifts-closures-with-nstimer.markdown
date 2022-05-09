---
title: "Using Swift's Closures with NSTimer"
description: "Looking closer at Swift's closures by extracting NSTimer into its own class"
date: 2014-07-21
comments: false
post: true
categories: [programming, swift, ios]
---

Since the announcement of Swift, I've been finding what opportunities I can to
get more acclimated to the language. To that end, I've been working on an app
which makes use of `NSTimer`, and I've been working to maintain good Object
Oriented practices in the process. 

Because the functionality of `NSTimer` doesn't belong in the controller, I've
extracted it into its own class. This wouldn't be a big deal in Objective-C -
we would just send the controller instance and its respective method as
arguments - but things are done differently in Swift; closures work better.

## Closures

In the first pragraphs of the "Closures" chapter, *The Swift Programming
Language* defines them thusly, "Closures are self-contained blocks of
functionality that can be passed around and used in your code...Closures can
capture and store references to any constants and variables from the context in
which they are defined."

They sound more complex than they are; closures are just methods (usually
anonymous, i.e. unnamed), but when we pass them around as arguments they retain
their scope and we give them a fancy name. (Note: I can't hear, say, or write
the word "fancy" without thinking of Kaylee from Firefly)

As mentioned earlier, the timer's functionality doesn't belong in the
controller. The only thing the controller needs to do is provide a means to
update the timer display. To do that, we'll initialize whatever timer class we
create, and provide a method (i.e. a closure) with which that class can
interface.  Here's what the important bits of that controller method might look
like:

``` swift
@IBOutlet func displayTimeRemaining(elapsedTime) {
  var timeRemaining = self.duration - elapsedTime
  timerView.value = timeRemaining
}
```

## The Timer Class

Our `Timer` class will have a couple properties and a few methods. We need know
how long the `Timer` can run (duration), and how long it's been running
(elapsedTime). From there we could use the magic of basic arithmetic to figure
out any other values.

We'll need an `init` and a `deinit` - the `deinit` to ensure the timer is closed
out. And we'll also need three methods: `start`, `stop`, and one to handle what
to do with each tick of the clock, `tick`.

``` swift
import Foundation

class Timer {
  var timer = NSTimer()
  var handler: (Int) -> ()
  
  let duration: Int
  var elapsedTime: Int = 0
  
  init(duration: Int, handler: (Int) -> ()) {
    self.duration = duration
    self.handler = handler
  }
  
  func start() {
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, 
                               target: self, 
                             selector: Selector("tick"), 
                             userInfo: nil, 
                              repeats: true)
  }
  
  func stop() {
    timer.invalidate()
  }
  
  @objc func tick() {
    self.elapsedTime++

    self.handler(elapsedTime)

    if self.elapsedTime == self.duration {
      self.stop()
    }
  }
  
  deinit {
    self.timer.invalidate()
  }
}
```

## Up Close

There are two key things to look at in this class: the `handler`, and the `tick`
method. Let's start with the `handler` method.

The first thing to note is its type. Whereas most variables are types, `Int`,
`Float`, `String`, etc., variables associated to closures use the closure's
signature as the type. In the case above, it's `(Int) -> ()`, which is like
saying, the closure receives an `Int` as an argument and has no return value -
an empty tuple. Just to repeat that, `(Int) -> ()` is the type for the variable.

> Functions without a defined return type return a special value of type Void.
> This is simply an empty tuple, in effect a tuple with zero elements, which can
> be written as ()
> -- The Swift Programming Language (p. 168)

In our `displayTimeRemaining` method (the example method in the imaginary
controller), we receive the `elapsedTime` as an argument and update the
associated label.

Looking at our `tick` method next. The code is self-explanatory, but you
should note that it's here that we're executing `handler`, which references
the `displayTimeRemaining` method, and passing the elapsed time as the
argument.

## Off Topic

Ideally, I would not include the closure as part of the initializer, but instead
pass it to the `start` method (i.e. dependency injection), but you can't do this
in Swift because all properties have to be declared and defined by the end of
initialization.

>Every property needs a value assigned—either in its declaration (as with
>numberOfSides) or in the initializer (as with name).  
> -- The Swift Programming Language (p. 18)

The `@lazy` attribute helps a little, but things would be much easier if I could
define a property other than in the initializer. The Ruby programming language
has spoiled me.

## Conclusion

The Swift programming language really is a lot of fun. It's very Ruby-like in
some ways, JavaScript-like in others, and it includes so many intelligent
features which (I think) lower the barrier of entry. It "feels" more Object
Oriented than Objective-C ever did.

It took a while to figure how Swift's typing worked with closures, and the goal
in this post was primarily to highlight that for anyone else experiencing that
same difficulty. 
