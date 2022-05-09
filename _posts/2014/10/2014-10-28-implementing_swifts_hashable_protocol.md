---
title: "Implementing Swift's Hashable Protocol"
description: "A step-by-step guide for implementing the Hashable protocol, and
ridding yourself of the 'does not conform to protocol 'Hashable'"
date: 2014-10-28
comments: false
post: true
categories: [swift, protocols, hashable]
---

You're already familiar with dictionaries - why else would you be here? They're
a collection type similar to arrays, but more flexible because their ability to
use a variety of data types to act as the index (or key) value. In many
programming languages, dictionaries can use almost anything as a key - an
integer, a string, a date object, or even an object you've created - but in
Swift, you're limited only to those classes which conform to the `Hashable`
protocol.  If your choice doesn't conform to that protocol, you'll run into an
error like the following:

``` swift
type 'SomeObject' does not conform to protocol 'Hashable'

// ... or ...

Cannot convert the expression's type '[SomeObject: OtherObject].Type' to type 'Hashable'
```

In both errors above, Swift is complaining that it doesn't know how to use the
specified object as a key. You must provide that information.

## Conformity

In order to use a class as a dictionary key, the first thing we must do is
ensure it conforms to the `Hashable` protocol. If you've done any amount of
iOS or Mac development work, you're already aware of what protocols are. They're
a sort of contract whereby classes promise to behave in a certain manner and
function, and that as such, other classes and libraries can trust them.

Let's create a `User` class to use as our example. We'll keep it simple and just
give it an ID (`uid`) and `name` properties:

``` swift
class User {
  var uid: Int
  var name: String

  init(uid: Int, name: String) {
    self.uid = uid
    self.name = name
  }
}
```

Next we need to tell Swift that our class should conform to the `Hashable`
protocol.  We do so by adding the `Hashable` protocol after the class
definition.

``` swift
class User: Hashable {
  var uid: Int
  var name: String

  init(uid: Int, name: String) {
    self.uid = uid
    self.name = name
  }
}
```

Doing this raises an error stating that "Type 'User' does not conform to
protocol 'Hashable'."

To make `User` conform to the `Hashable` protocol, we need to provide a
`hashValue` getter property. This property must provide a unique identifier for
your objects. If it doesn't, you'll wind up retrieving the erroneous data for a
given key. In the case of our `User` class, we'll use the `uid` property as our
unique identifier. We could use `name`, but there are instance where people
share the same name, for example, John Jacob Jingleheimer Schmidt. Here's what
our class looks like after making the necessary changes:

``` swift
class User: Hashable {
  var uid: Int
  var name: String
  var hashValue: Int {
      return self.uid
  }

  init(uid: Int, name: String) {
    self.uid = uid
    self.name = name
  }
}
```

We've declared that our `User` class conforms to the `Hashable` protocol, and
defined the `hashValue` property, everything should work now, right? Not quite.

## Hashable Conforms to Equatable

Because `Hashable` is derived from (i.e. conforms to) `Equatable`, our class
must also conform to `Equatable`, and so the last thing we need to do is define
an version of `==` which can compare our class. In the case of our `User` class,
it's going to look like this:

``` swift
func ==(lhs: User, rhs: User) -> Bool {
  return lhs.uid == rhs.uid
}
```

The function takes two arguments: the `User` instance from the left-hand side
of the `==` (lhs), and the instance from the right-hand side (rhs). It then
returns whether or not the two instances share the same `uid` value.

The `==(User, User)` function must be defined in the global scope, because
this is where Swift defines its own version of the function and where it looks
for any others versions whose signature might be a better match. 

When you create your own `Equatable` or `Hashable` based classes, you'll likely
want to define `==` in the same file as the class to make finding it easier, but
outside of the class definition.

``` swift
// User.swift

class User: Hashable {
  var uid: Int
  var name: String
  var hashValue: Int {
      return self.uid
  }

  init(uid: Int, name: String) {
    self.uid = uid
    self.name = name
  }
}

func ==(lhs: User, rhs: User) -> Bool {
  return lhs.uid == rhs.uid
}
```

Now that our class conforms to both the `Hashable` and `Equatable` protocols,
we can safely use `User` instances as `Dictionary` keys.

``` swift
let user1 = User(uid: 1, name: "Bill")
let user2 = User(uid: 2, name: "Jay")
var user_arrays: [User:String] = [
  user1:"The sky above the port was the color of television, tuned to a dead channel.", 
  user2:"In a hole in the ground there lived a hobbit."
]
```
