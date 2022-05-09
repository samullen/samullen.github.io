---
title: "The Two Most Productivity Enhancing Scripts Ever Written in the History of UNIX"
date: 2013-10-10
description: "Two unix scripts which modify the /etc/hosts to help you stop wasting time"
post: true
categories: [unix, scripting, productivity]
---

You're not a slacker. In fact, you're a pretty good developer who gets things
done on time and done well. But sometimes you find yourself wasting time on that
site again. You weren't planning to go there, but the code takes a minute to
compile and the tests take a bit longer to run and so you just flip over there
while you wait. 

Ten minutes later you're still there, not thinking, just consuming. 

And you berate yourself again for wasting time.

What you don't need is some overlord application telling you you can't access
the internet for the next three hours. You just need a gentle reminder that you
want to be productive.

Here it is. Two simple scripts. ([go to the GitHub Gist](https://gist.github.com/samullen/6497129)) 

One to block the sites you don't want to visit:

``` bash
function worktime {
  echo "# WORKTIME" | sudo tee -a /etc/hosts > /dev/null
  while read -r line; do
    echo "127.0.0.1 ${line}"
  done < $HOME/.blocked_sites | sudo tee -a /etc/hosts > /dev/null
}
```

And one to remove the block:

``` bash
function slacktime {
  flag=0
  while read -r line; do
    [[ $line =~ "# WORKTIME" ]] && flag=1
    [[ $flag -eq 1 ]] && continue
    echo $line
  done < /etc/hosts > /tmp/hosts
 
  sudo cp /tmp/hosts /etc/hosts
}
```

List the sites you don't want to be visiting in `.blocked_sites` in your `$HOME`
directory. Like this:

``` bash
twitter.com
www.twitter.com # you may need to include the www subdomain
feedbin.me
alpha.app.net
app.net
```

When you want to be productive, run `worktime`. When you're ready to slack off,
run `slacktime`.

`worktime` adds those sites to your `/etc/hosts` file redirecting you back to
`localhost`. If you're feeling creative, make a landing page with a picture or
text reminding you to keep been awesome. I use a picture of [R. Lee Ermey](https://www.google.com/search?safe=active&site=&tbm=isch&source=hp&biw=1436&bih=806&q=r.+lee+ermey&oq=r.+lee&gs_l=img.3.0.0l8j0i5l2.1735.2810.0.4433.6.6.0.0.0.0.107.579.5j1.6.0....0...1ac.1.27.img..0.6.578.gCW9yVwp1X0)
to gently remind me what I'm supposed to be doing.

When you're done being productive, run `slacktime`. `slacktime` just removes the
entries which were added to the `/etc/hosts` file.

So are these really the two most productivity enhancing scripts ever written in
the history of UNIX, or am I just using a bit of hyperbole to increase traffic?
Probably the latter, but I still hope I help you become more productive.

<img src="//samuelmullen.com/images/get_back_to_work.jpg" class="img-left img-thumbnail">

Now quit slacking off and get back to work!
