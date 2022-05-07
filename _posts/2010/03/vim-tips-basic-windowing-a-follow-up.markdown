---
title: 'VIM Tips: Basic Windowing - A Follow Up'
date: 2010-03-10
post: true
categories: [vim, tips]
---
From the comments of the [previous post](//samuelmullen.com/2010/03/vim-tips-basic-windowing/), jheryer mentioned that you can split a VIM session vertically with ":vs <filename>"

Also in the post, I mentioned that window size could be altered with "Ctrl-W+" or "Ctrl-W-". I like those commands so much that I've created the following mappings to save a couple of keystrokes:

``` bash
:map - <C-w>-  
:map + <C-w>+
```

Of course, you can no longer lead the command with a number, but with a keyboard repeat that problem is mitigated.

I was using "+" to perform the same action "." and then drop down a line "j" (useful for simple repetitions.) I just mapped the pipe "|" character to do that (with a leading "\")"

``` bash
:map \| 0j
```
