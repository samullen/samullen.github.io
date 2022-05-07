---
title: "Left Pad Zeroes in JavaScript"
description: "JavaScript doesn't have all the formatting niceties of other languages. Here's an elegant way to left pad numbers with zeroes."
date: 2012-03-01
comments: true
post: true
categories: [javascript, hacks]
---
I was recently working on a project wherein I needed to present a number padded on the left with zeroes. Most languages have some sort of formatter method which would allow you to do that, but not [JavaScript](https://developer.mozilla.org/en/JavaScript). Instead of following the path of other languages, JavaScript opts to give the developer opportunities to be creative.

After a quick search, I ran across [a very elegant solution](http://www.codigomanso.com/en/2010/07/simple-javascript-formatting-zero-padding/) from [Pau Sanchez](http://www.codigomanso.com/) which I have turned into a the following function and added some smarts to allow the padding to be changed as necessary.

``` javascript
var lpad = function(value, padding) {
    var zeroes = "0";
    
    for (var i = 0; i < padding; i++) { zeroes += "0"; }
    
    return (zeroes + value).slice(padding * -1);
}
```

Note that this doesn't account for numbers which are longer than the padding value; they get cut off. Most of the time you deal with left padded numbers, you're dealing with a fixed width and this isn't going to be a problem. I'll leave it as an exercise for the user, if this is not the current case for you.

Here it is again in CoffeeScript:

``` coffeescript
lpad = (value, padding) ->
  zeroes = "0"
  zeroes += "0" for i in [1..padding]

  (zeroes + value).slice(padding * -1)
```
