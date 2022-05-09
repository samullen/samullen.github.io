---
title: 'VIM Tips: Basic Windowing'
date: 2010-03-04
post: true
categories: [vim, tips]
---
As you can see from the screenshot below, I like to work with a lot of terminal screens at once.

<img src="//samuelmullen.com/images/vimterms.png" class="img-thumbnail img-left">

I like to see everything I'm working on at a glance and so I've never picked up the habit of using VIM's tabbed environment. I do, however, like the benefits the tabbed environment offers, namely: a single terminal; a single VIM environment for yanking, putting, etc.; and an ever increasing amount of area for code.

To accomplish this, I use VIM's windowing features. What follows is a list and description of the one's I primarily use:

``` bash
vim -o <file 1> <file 2> ... <file n> # opens a vim session with as many VIM windows as there are files  
 :sp <filename>      # opens a new file in a new VIM window above the currently focused window  
 [n]CTRL-Ww          # Rotates focus down 'n' windows (default 1; Same as CTRL-Wj)  
 [n]CTRL-Wk          # Rotates focus up 'n' windows (default 1)  
 [n]CTRL-W-          # Reduces size of focused window by 'n' lines (default 1)
 [n]CTRL-W+          # Increases size of focused window by 'n' lines (default 1)
 CTRL-Wx             # flips the position of focused window and window below (e.g. window in position 1 will be put in position 2 while the window in position 2 is put into position 1)  
```

If you have one (or more) practical examples of VIM's windowing, put them in the comments below. I'd love to see other ways people are using this particular feature
