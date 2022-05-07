---
title: "Power Up Search in Google Chrome"
description: "Make search in Google Chrome even better by using shortcuts to targeting specific sites you want to search"
date: 2012-02-16
comments: true
post: true
categories: [search, tips, howto]
---
I always look for ways to simplify my workflow, and one of the best ways I know is to use shortcuts: key bindings, abbreviations, aliases, cutting through neighbors' yards, etc. The other day, I ran across [DuckDuckGo's](http://duckduckgo.com) search shortcuts which allow you to use bang operators to localize search to specific sites. So if you know you are looking for widgets from [Wikipedia](http://en.wikipedia.org), you can type `!w widgets` in DuckDuckGo's search box and see results from [Wikipedia](http://en.wikipedia.org).

In discovering DuckDuckGo's shortcuts, I stumbled upon a similar ability in [Google Chrome](https://www.google.com/chrome). Normally, if you wanted to localize your search to a site such as [GitHub](http:github.com) you would enter `site:github.com linux` in the location bar. After following the steps below, you will be able to type `gh linux`  to localize your search to GitHub.

### Step 1 - Preferences
In Google Chrome, open up the preferences page. You can do that by typing "about:settings" in the location bar or by going through the menu.

<img src="//samuelmullen.com/images/chrome_powerup/chrome_menu.png" class="img-left img-thumbnail">

Once there, click the "Manage Search Engines..." button. 

<img src="//samuelmullen.com/images/chrome_powerup/manage_se_button.png" class="img-left img-thumbnail">

### Step 2 - Edit an Existing Entry

Look through the list of available sites and select one which you search frequently. Now, click on the entry in the second column and change the text to something simpler and easy to remember: if it's "[github.com](http://github.com)", change it to "gh"; if it's "[catch.com](http://catcht.com)", change it to "c"; etc.

<img src="//samuelmullen.com/images/chrome_powerup/search_list.png" class="img-left img-thumbnail">

### Step 3 - Search Using the New Shortcut

Now that you have tweaked your search engine preferences, you can use your shortcuts to localize search. Open up a new tab and type one of your shortcuts followed by a space or tab. Notice that when you type the space/tab, the location bar adds a "Search" highlight area to show you what site you are actually searching. Go ahead and add your search query after this and hit enter.

<img src="//samuelmullen.com/images/chrome_powerup/search.png" class="img-left img-thumbnail">

Cool, right?

### Bonus Step - Adding Your Own Sites

If the site you want to search is not listed, you can add it. Go to the bottom of the list of sites on the preferences page. In the last entry, fill in the three fields: "Search Engine", "Keyword", and the search address.

<img src="//samuelmullen.com/images/chrome_powerup/new_engine.png" class="img-left img-thumbnail">

To determine the search address, you'll need to go to that site and perform a search. Highlight the portion of the location bar which contains the URL and the query string, and paste that in to the third column of the new entry. Now, just replace the search term you used on the site with a "%s" and you're finished. 

<img src="//samuelmullen.com/images/chrome_powerup/query_replace.png" class="img-left img-thumbnail">

For the image above, I would change "https://kippt.com/#/search/vim" to
"http://kippt.com/#search/%s" in the "search address" field.

I'm really just tickled to have found this feature in [Google Chrome](https://www.google.com/chrome). I've been using it a lot since finding it, and I've set up several shortcuts which I've been making heavy use of: [GitHub](http:/github.com), [kippt](http://kippt.com), [catch](http://catch.com), and [rubydoc.info](http://rubydoc.info) to name a fiew. It reduces clicks, it simplifies my workflow, and it makes the web a nicer place to live.
