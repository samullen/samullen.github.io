--- 
title: "FireFox's getCurrentPosition error_callback Problem"
date: 2011-07-31
comments: false
post: true
categories: [geolocation, firefox]
---
Recently, I began working with an application which required the retrieval of users' current location. Initially I was using the [geo-location-javascript library](http://code.google.com/p/geo-location-javascript/), but stopped because I was running into a "problem" wherein the error_callback handler was not being called. After switching over to the native navigator.geolocation.getCurrentPosition, I ran in to the same problem and realized it had nothing to do with the geo-location library. It turns out, this is a "feature" of FireFox (see [Mozilla Bug 650247](https://bugzilla.mozilla.org/show_bug.cgi?id=650247))

When a user goes to a site which retrieve's that user's location, a dialog box pops up alerting the user that the website is requesting permission to retrieve their current location. In FireFox, a user has four options which are detailed below:

* Share Location: For this one page, the user chooses to share his/her location. The user will be prompted again the next time the app makes a request.
* Always Share: If this is selected, the user agrees to always share his/her position with the application.
* Never Share: The app will never have access to the user's position information.
* Not Now: The user is choosing not to share his/her location for this one page.

<img src="samuelmullen.com/images/Screen-shot-2011-07-31-at-4.36.41-PM.png" height="431" width="208" class="img-thumnail img-left">

If the user selects either to "Share Location" or "Always Share", the success_callback is fired. If, on the other hand, the user selects "Never Share", the error_callback is fired. Here's the funny part, if the user selects "Not Now", neither the success nor error callbacks are fired; [here's the code to prove it](https://developer.mozilla.org/en/using_geolocation#Prompting_for_permission).

So what's the workaround? So far I haven't found one, but I wanted to post this to at least help devs who are experiencing the same problems. If you have an answer, post it in the comments below and I'll update this post accordingly giving credit where credit is due.
