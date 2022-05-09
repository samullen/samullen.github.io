--- 
title: Mimicking Most Link Behavior with jQuery
date: 2011-06-04
comments: false
post: true
categories: [jquery, web]
---

There are occasions when using link tags on a web page doesn't make sense, which is why [JavaScript](https://developer.mozilla.org/en/About_JavaScript) allows you to bind "click" events to the page elements; it's also why [jQuery](http://jquery.com/) provides [methods to do the same](http://api.jquery.com/click). Binding click events to page elements is not ideal and if you can find a way to use an anchor tag instead, you should. But for the sake of this post, let's assume you need to make some element behave like a normal link?

What will our link need to do? The first thing is it needs to take the user to some other location; that's easy. Secondly, it should also open up a new window with the locaiton if the user clicks with the middle button; a bit harder. Third, it should display the location of the link in the status bar would be helpful; yeah, it should. Lastly, it needs to display the appropriate context menu on a right mouse button click; that's not going to happen.

The first thing we need is an HTML element to bind clicks to:

``` html
<div id='clickable' data-location="http://google.com">Click Me</div>
```

Yup, that will do nicely. Notice the new "data-" attribute. This sort of attribute is the new, accepted way of adding non-standard attributes to an element; especially those which hold "data". We could have named it anything, but "data-location" informs us of where we will go if we click on the element. Using "data-" attributes will also allow you to put HTML5 on your resume. Bonus!

To accomplish the first two points of the link mimic - the latter two are not possible with modern browsers - we'll use the following chunk of jQuery code:

``` javascript
$.fn.mimiclick = function() {
  this.live('mouseup', function(e) {
    var url = $(this).attr("data-location");

    if (e.which == 1) {
      document.location = url;
    }
    else if (e.which == 2) {
      window.open(url, "_blank");
    }
  });
}
```

Here's what's going on:
* Line 1: We're using this function as a jQuery plugin (but not a chainable one).
* Line 2: Rather than using the normal "bind()" method, I've chose to use the  "live()" method. It behaves like "bind()", but it binds events to  elements which are created before and after page loads.
* Line 3: Snag the URL the element is supposed to take us to
* Line 5: A normal left mouse click
* Line 8: A Middle mouse click
* Line 9: Open the link in a new page

Notice that we are using the "mouseup" event rather than click. We have to do this in order to capture the middle mouse click. The "click()" event doesn't capture it.

Since we made this a jQuery plugin, we just need to use the following code to make our element clickable:

``` javascript
$("#clickable").mimiclick();
```

So that mostly solves our problem. I say mostly, because we're not handling the status bar message or the right-button click (again, those are browser limitations). Also, some browsers will think the bound code is attempting to open a new window without the user's consent even though the call is tied to the "mouseup" event.. This results in the ever-annoying, "so-and-so prevented this site from opening a pop-up window."

Like I said, it's not ideal, but it does provide some value for those of us that love clicking links with the middle button.

###Further Reading
* [Status Bar](http://stackoverflow.com/questions/1444770/how-to-display-information-at-the-status-bar-of-browser)
* [Opening Windows](http://ajaxian.com/archives/the-one-true-way-to-open-a-window-in-javascript)
* [Capturing Middle Click](http://stackoverflow.com/questions/1795734/triggering-onclick-event-using-middle-click)
