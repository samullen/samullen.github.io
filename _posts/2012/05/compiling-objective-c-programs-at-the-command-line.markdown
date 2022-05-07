---
title: "Compiling Objective-C Programs at the Command Line"
date: 2012-05-13
comments: true
post: true
categories: [ios, objective-c, command line, hacks]
---

**Update 2014-09-01:** This post is very outdated and should not be used as
reference for any modern iOS development.

I've switched my learning efforts from JavaScript frameworks to iOS development. I'm using my morning 30 minute period of time to study the "[Objective-C Programming](http://www.amazon.com/gp/product/0321706285/ref=as_li_ss_tl?ie=UTF8&tag=themulfam-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321706285)" book from "[Big Nerd Ranch](https://www.bignerdranch.com/)". I'm also taking an hour out of my normal billable hours to study Big Nerd Ranch's "[iOS Programming](http://www.amazon.com/gp/product/0321821521/ref=as_li_ss_tl?ie=UTF8&tag=themulfam-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321821521)".

Many of the chapters of the "Objective-C Programming" book have exercises at the end to help the student cement what he or she has learned. As I've been going through them, I've become very frustrated with needing to open a new XCode project for each exercise. It would be a lot easier for me just to code up the solutions in Vim and compile them at the command line.

I wasn't sure it was possible, but after a quick Googling, I ran across a [sample chapter from "Programming in Objective C"](http://www.informit.com/articles/article.aspx?p=1819492) which had the solution.

In a nutshell:

1. Create an objective-c implimentation file (*.m)
2. Add the necessary code
3. Compile it using the following command

```
$ clang -fobjc-arc –framework Foundation filename.m -o output_filename
```

For those who are familiar with GCC or other command-line compilers, that should be enough to get you started. For the rest of you, you may want to stick with XCode. Seriously, I'm not sure how long I'll stick with this method.

> You should note that writing and debugging Objective-C programs from the terminal is a valid approach. However, it’s not a good long-term strategy. If you want to build Mac OS X or iOS applications, there’s more to just the executable file that needs to be “packaged” into an application bundle. It’s not easy to do that from the Terminal application, and it’s one of Xcode’s specialties. Therefore, I suggest you start learning to use Xcode to develop your programs. There is a learning curve to do this, but the effort will be well worth it in the end.

As stated at the end of the linked article (chapter), this is not something you'll want to use to build MacOS or iOS applications. I'm only doing things this way to simplify completion of exercises.
