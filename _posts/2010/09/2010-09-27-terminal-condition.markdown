---
title: Terminal Condition
date: 2010-09-27
post: true
categories: [scripting, shell, unix]
---

Those who know me know that I have a kind of old-school mentality when it comes to my preferred workspace layout; I use a lot of terminals.

Here's a screenshot of what my desktop generally looks like.

<img src="//samuelmullen.com/images/terminals.png" class="img-thumbnail img-left">

Anyway, I got sick of opening up _n_ terminals every time I started to work, moving them to where I wanted them to be, and then resizing them to their "correct" sizes, so I wrote a simple shell script to do it for me.

``` bash 
rxvt -geometry 80x65-0+0 &
rxvt -geometry 80x65+600+0 &
rxvt -geometry 80x65+100+0 &
rxvt -geometry 180x24+0-25 &
rxvt -geometry 180x24+0+195 &
rxvt -geometry 80x39+0+0 &
```

First, I set up the terminals the way I wanted them and then I used xwininfo (not sure if you Mac types have that) and then applied the geometries to the terminal call. Easy stuff.

**Update: 20120522** I've since switched to TMux and no longer do things this way. 
