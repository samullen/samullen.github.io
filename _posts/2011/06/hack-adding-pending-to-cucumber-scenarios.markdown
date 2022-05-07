--- 
title: "Hack: Adding \"Pending\" to Cucumber Scenarios"
date: 2011-06-02
comments: false
post: true
categories: [hacks, cucumber]
---

There are occasions when you need to skip over an entire [Cucumber](http://cukes.info) scenario for a while. You could comment it out, but without any visual queues in the test output, you are dependent upon your memory to come back to it. Alternatively, you can create a "Given" step. Here's how to do that...

In one of your cucumber step files - I always have a step file with the same name as the app I am working on (i.e. someproject_steps.rb) - add the following "Given":

``` ruby
Given /^PENDING/ do
  pending
end
```

You can now use this in your Cucumber feature files like so:

```
Given PENDING The original Given line
  And some other given
 When this is true
 Then some other action
```

The output will look something like this:

```
(::) pending steps (::)

features/some_feature.feature:8:in `Given PENDING The original Given line'
```

As mentioned in the title, this is a [hack](http://en.wikipedia.org/wiki/Hack_\(computer_science\)#In_computer_science). Ideally, Cucumber would provide a tag - "Pending" for example - at the same level as "Background" or "Scenario" which would allow scenarios to be skipped over entirely, but with a visual queue denoting them as being skipped.

Somebody should get on that...
