---
title: 'IRB: Global + Local .irbrc'
date: 2010-04-01
post: true
categories: [git, irb, ruby]
---

I really like the way the Git SCM handles global and local configurations. Globally, you have .gitconfig and .gitignore files which define how Git behaves across all projects. Locally, you have .gitignore and .git/config files which are applied specifically to the current directory or project. This approach works very well and this morning I tried applying it to the way Ruby's IRB works.

With IRB, you really only have a global configuration file: the .irbrc in your $HOME directory. In one of my current projects I have found that I type the same blob of code every time I enter the IRB shell in that project: I always need to load a couple libraries, connect to a database, dance a jig, etc. I really don't like doing this and so I decided to take a page from Git and implement my own locale-based .irbrc. This is what I came up with:

``` ruby
# requires and stuff go here

def load_irbrc(path)
  return if (path == ENV["HOME"]) || (path == '/')

  load_irbrc(File.dirname path)

  irbrc = File.join(path, ".irbrc")

  load irbrc if File.exists?(irbrc)
end

# other ruby code in your .irbrc

load_irbrc Dir.pwd # probably should stay at the bottom
```

The load_irbrc method is recursive and will load every .irbrc file in the path, starting at the top, but stops short of loading $HOME/.irbrc. I did this to allow myself to build upon previous .irbrc files - well that and I thought it'd be fun.

Now, in my $HOME/.irbrc file I have global configurations and in my projects I have project specific configurations. Yea, me.
