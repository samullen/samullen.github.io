--- 
title: "Moving from GNU Screen to tmux"
description: ""
date: 2011-05-27
comments: false
post: true
categories: [tmux, environments]
---

After hearing [James Edward Gray II](http://blog.grayproductions.net/) endorse [TMUX](http://tmux.sourceforge.net/) on the [first episode](http://rubyrogues.com/001-rr-testing-practices-and-tools/) of [Ruby Rogues](http://rubyrogues.com/), I decided to give it a go. If you've been using [GNU Screen](http://www.gnu.org/software/screen/), then the first thing you will want to do is rebind "Ctrl-b" to "Ctrl-a". Add this to your .tmux.conf file:

``` bash
unbind C-b
set-option -g prefix C-a
```

The next thing you will likely want is to be able to switch back and forth between your current "screen" and the last screen. You can do that with the following:

``` bash 
unbind l
bind-key C-a last-window
```

I'm not a GNU Screen - or a tmux - power user, but it seems like those are the two most common beefs people have when switching over to tmux.

In order for your changes to take effect, you will need every instance of tmux closed out. I spent a good thirty minutes trying to figure out why my .tmux.conf changes weren't taking, until I discovered that I had a couple other sessions running on a different desktop.

So far, I've liked what I've seen with tmux, but it's a pretty deep rabbit hole, and I've only just taken my first step.
