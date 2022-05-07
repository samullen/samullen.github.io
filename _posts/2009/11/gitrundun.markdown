---
title: Gitrundun
description: "removing a file from being tracked by Git"
published: true
date: 2009-11-18
post: true
categories: [git]
---

I was having an issue pushing a project out the production this evening. I was tracking files in my git repository that really should have been in my `.gitignore` file because the application updated them. What happened was that I was not able to push my project live because Git didn't want to allow me to "pull" the files down without a proper merge.

"Nuts to that", I say. "I'll just add the file to my `.gitignore` file and be done with it."

That didn't work.

It didn't work because the file was already being tracked. So, turning to the one who knows all, sees all, and reveals all (i.e. Google), I found a link to [source.kohlerville.com](http://source.kohlerville.com) which provided the answer.

``` bash
git rm --cached filename
```

Don't worry, it doesn't delete your file, just the tracking of it. The next step is to add the file or directory to your `.gitignore` file.

Outstanding.
