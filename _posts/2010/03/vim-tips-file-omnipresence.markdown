---
title: 'VIM Tips: File Omnipresence'
date: 2010-03-29
post: true
categories: [vim, tips]
---

I ran into a problem last night while I was working on a rather large HTML file. A client requested that I add a feature which would involve adding a little bit of both HTML and jQuery to a particular page of their application. The HTML portion of the file in question was near the top of the file, and the jQuery code was near the bottom. I realized very quickly that flipping between the top and bottom of the file wasn't going to work, so the practice "marking" my spots was out. Alternatively, I could have "view"ed the file in another terminal, but the drawback with that is that the "view"ed file is opened read-only, so I wouldn't be able to edit it.

I finally decided to just split the screen on the same file with the `:sp` command. By splitting the VIM session, I was able to edit the same file in two different places. In the top half of the session I moved to the HTML portion I was editing; in the bottom session, I moved to the jQuery/JavaScript I was editing. Since the file was really only opened once, I could save from either "window". I could edit the file omnipresently.
