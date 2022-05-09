--- 
title: On Speed Matters, Because Speed Matters
date: 2010-10-03
comments: false
post: true
categories: [high performance websites, speed, efficiency]
---

In April, 2010, [Google announced](http://googlewebmastercentral.blogspot.com/2010/04/using-site-speed-in-web-search-ranking.html) they would begin using site speed as a metric in determining site ranking. While this no doubt upset a great number of people who have spent countless days tweaking their site's wording and links for better SEO, it does make a great deal of sense. How many times have you found yourself hitting the "Back" button to go to an alternative site because a page wouldn't load? Google is in the business of helping people find what they are looking for, if people are not *finding* what Google gave to them as an answer, then that answer is useless. If Google were to persist in providing poor answers, soon Google wouldn't exist. Their solution? Reduce the ranking (the value) of poorly performing sites.

Let's say you're not a big company and can't afford all new hardware, how are you supposed to compete with those who can just throw money at the problems?Just like with most "David and Goliath" scenarios: you out-maneuver and out-think your opponents. Matt Cutts, the head of Google's Webspam team, had this to say about this very question:

> I want to pre-debunk another misconception, which is that this change will somehow help “big sites” who can affect to pay more for hosting. In my experience, small sites can often react and respond faster than large companies to changes on the web. Often even a little bit of work can make big differences for site speed. So I think the average smaller web site can really benefit from this change, because a smaller website can often implement the best practices that speed up a site more easily than a larger organization that might move slower or be hindered by bureaucracy.

Out-maneuvering your competition to increase page speed doesn't require spending a lot of money on newer, faster hardware. You may be surprised to find that upwards of 90% of the time required to display your webpage to users is on their end (the end-users' computers) not yours (your servers). HTML and CSS rendering, Javascript executions, external file calls, and more all have an effect on how quickly your page is displayed. Steve Souders, who literally wrote the book on "High Performance Web Sites", says this:

> The time spent generating the HTML document affects overall latency, but for most Web sites this back-end time is dwarfed by the amount of time spent on the front end. If the goal is to speed up the user experience, the place to focus is on the front end. Given this new focus, the next step is to identify best practices for improving front-end performance.

What does that mean? It means that just by making minor adjustments to the programming of your website, you can drastically improve your site's performance. Here is Steve Souders' original list of is a list of 14 best practices (each are explored in detail in his book.)

1.  Make Fewer HTTP Requests
2.  Use a Content Delivery Network (CDN)
3.  Add an Expires Header to outgoing files
4.  Gzip Web Page Components
5.  Put Stylesheets at the Top
6.  Put Scripts at the Bottom
7.  Avoid CSS Expressions
8.  Make JavaScript and CSS External
9.  Reduce DNS Lookups
10.  Minify JavaScript and CSS
11.  Avoid Redirects
12.  Remove Duplicate Scripts
13.  Configure ETags
14.  Make AJAX Cacheable

Souders has since identified another 21 practices and has also written a followup book. You can find [all 35 practices](http://developer.yahoo.com/performance/rules.html) and other great articles at [Yahoo!s Developer Network](http://developer.yahoo.com/)

Most of these practices require minimal effort to implement; a couple, such as item #2, are a little more involved; and each item which is implemented will play a part in making your site faster.

It should be noted that when you increase the performance of your website you won't just help your ranking on Google, your site may also experience the following side-effects: 1) increased traffic; 2) increased pageviews; 3) increased sales; 4) increased cash flow. And you might just experience one more side-effect: a few less sleepless nights.

###Tools and Resources
* [Google Libraries API](http://code.google.com/apis/libraries/)
* [Google Page Speed Firefox Extension](http://code.google.com/speed/page-speed/)
* [Google Webmaster Tools](https://www.google.com/webmasters/tools)
* [Yahoo!'s YSlow Firefox Add-on](https://addons.mozilla.org/en-US/firefox/addon/5369/)
* [Douglas Crockfordd's original JSMin Javascript Minifier](http://www.crockford.com/javascript/jsmin.html">Douglas Crockford's original JSMin Javscript Minifier)

###Further Reading
* [Best Practices for Speeding Up Your Web Site](http://developer.yahoo.com/performance/rules.html)
* [High Performance Web Sites](http://www.amazon.com/gp/product/0596529309?ie=UTF8&amp;tag=dumpgrou-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=0596529309) - Steve Souders, [O'Reilly Publishing](http://oreilly.com/)
* [Even faster Web Sites](http://www.amazon.com/gp/product/0596522304?ie=UTF8&amp;tag=dumpgrou-20&amp;linkCode=as2&amp;camp=1789&amp;creative=390957&amp;creativeASIN=0596522304) - Steve Souders, [O'Reilly Publishing](http://oreilly.com/)
* [Steve Souder's Website](http://stevesouders.com/)
* [Google Incorporating Site Speed in Search Rankings](http://www.mattcutts.com/blog/site-speed/) - [Matt Cutts](http://www.mattcutts.com/blog/)
>
