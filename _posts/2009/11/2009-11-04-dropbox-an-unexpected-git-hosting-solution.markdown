---
title: "DropBox: An Unexpected Git Hosting Solution"
description: "A simple way to use Dropbox as a private Git repository"
published: true
date: 2009-11-04
post: true
categories: [dropbox, git, hacks, hosting]
---

For some time, I've been looking for a hosting provider for projects I'm working on. I use the [Git SCM](http://git-scm.com/) for everything I work on now, and I use [GitHub](http://github.com) to host any public projects I work on. GitHub provides a great service for the community, but I'm just cheap enough to not want to upgrade to one of their paid plans (Yes, I really am that cheap). Free hosting alternatives include [ProjectLocker](http://projectlocker.com), [unfuddle](http://unfuddle.com/), and [a host of others](http://git.or.cz/gitwiki/GitHosting). I'm sure all of these services are adequate solutions for any project, but to be honest, I'm not only cheap, I'm also incredibly lazy. I don't want to take the time to figure out yet another site, set up my public key, create a new project and then configure it. I want something dead simple.

I originally thought I might just set up Git repositories on a USB drive and back my projects up there, but that solution requires that you always have the drive with you to use it. What I wanted was something like the USB drive in that it was just part of the filesystem, but at the same time could be everywhere I could be. The solution I came up with was to use [Dropbox](http:://dropbox.com).

Dropbox, in their own words, "...is software that syncs your files online and across your computers."

> Put your files into your Dropbox on one computer, and they'll be instantly available on any of your other computers that you've installed Dropbox on (Windows, Mac, and Linux too!) Because a copy of your files are stored on Dropbox's secure servers, you can also access them from any computer or mobile device using the Dropbox website.

I've already been using dropbox for some time, so it was really just a matter of creating a Git remote repository. That's simple:

``` bash
mkdir ~/Dropbox/projects/new_project
cd ~/Dropbox/projects/new_project
git --bare init
```

I've got my Git remote repository ready, now I just need to "add" it to my current project and "push" the current project to my new remote repository. Again, simplicity itself:

``` bash
cd ~/projects/new_project
git remote add origin ~/Dropbox/projects/new_project
git push origin master
```

The main drawback with this solution is that I now need to have the "Dropbox" application installed on whatever computer I'm working on. This isn't going to be a problem for me, but I can see how it would be a problem for some. Another drawback is the 2-3 GB limitation. Again, it's not a problem for me, but it may be for some.

The big "wins," on the other hand, are: an external private repository for projects; easy project collaborate with others by "sharing" the project folder; and best of all, it's all free until it's outgrown.

To be honest, I'm pretty sure I'm not sharing any sort of huge revelation; this post was a really just an excuse for me to try to get more storage on my Dropbox account. You see, you start out with 2GB for free and you get another 250MB with every referral up to 3GB. So how about clicking on [this link](https://www.getdropbox.com/referrals/NTEwMDI5Njc5) and getting me to my goal? I'm not only cheap and lazy, I also have no shame.
