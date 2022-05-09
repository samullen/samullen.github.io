---
title: "Replacing the Rails Asset Pipeline with Webpack and Yarn"
description: "In this tutorial we look at how to completely replace the Rails Asset Pipeline with tools from the the Javascript ecosystem, Webpack and Yarn."
date: "2016-11-15T20:31:49-06:00"
tags: [ "rails", "javascript", "tutorials", "toolin"]
author: "Samuel Mullen"
---

<em>**Update:** Since this article was published, the Rails team announced the
inclusion of both webpack and Yarn into Rails 5.1. I have a new article covering
these latest changes: [Embracing Change: Rails 5.1 Adopts Yarn, Webpack, and the JS Ecosystem](/articles/embracing-change-rails51-adopts-yarn-webpack-and-the-js-ecosystem/).</em>

Ruby on Rails has a pretty sweet ecosystem. We have libraries for everything
from printing a [table flipping emojicon](https://github.com/iridakos/table_flipper) on an exception to [natural language processing](https://github.com/diasks2/ruby-nlp). Just add the desired libraries to your Gemfile, type `bundle`, and you're on your way (ahem. Usually).

When it comes to dealing with JavaScript libraries in a Rails project, however,
things aren't as straightforward. Should you download the Javascript code and
manually store it in the `/vendor` directory or look for a wrapper gem that'll
just make the bad Javascript man go away? If you install the libraries manually,
it's up to you to ensure all the dependent libraries are also installed. If you
rely on a gem, you must rely on the gem maintainer to keep things current. It's
a real problem, and we're not even considering the minor detail of version
compatibility amongst the various javascript libraries in both scenarios.

## What's the solution?

The solution is to let each ecosystem, Ruby and Javascript, be awesome at what
they do best. The idea of the asset pipeline was a great idea when it was first
conceived. It provided a solution to breaking cached assets with fingerprints,
it concatenated and minified both CSS and Javascript, and it even accounted for
fonts, images, and whatever else we wanted to throw in there. What it didn't
account for was how dominant [Node.js](https://nodejs.org/) and all the frontend
frameworks would become.

Today, when you look at any Javascript library, the installation
instructions can be summed up with this: `npm install libraryname`. There are no
instructions for how to install the library manually, or if there are, it's with
an incredulous tone. It's just not done that way anymore.

Rails no longer needs to control the entire ecosystem, and arguably it shouldn't
because tools have been developed which do a better job. Letting go of this one
area doesn't reduce the value or importance of Rails, and it doesn't mean
Node.js won. It just means we're choosing the right tools for the job.

Assuming you agree with me, let's start the process of replacing the Asset
Pipeline.

## Starting a new Rails project

We'll first need a Rails project to use as a our lab for this experiment. You
can switch to a new branch of an existing project, but it may result in more
headaches until you have a better grasp of the technologies. It's your call.

```bash
rails new antipipeline
```

With our Rails application created, we can start replacing the Pipeline.

## Laying the Javascript foundation

To chisel out the asset pipeline from Rails, we're going to need some tools.
Those tools are [Node.js](https://nodejs.org), the Javascript Runtime, and
[Yarn](https://yarnpkg.com/), a dependecy management tool (think Bundler). Node
allows us to run Javascript executables from the commandline, and Yarn enables
us to install all the other libraries we need.

Both tools are super easy to install if you're running MacOS.

```bash
brew install node

brew install yarn
```

You'll want to refer to the documentation of both tools if you're running
another OS.

You're probably already familiar with Node, but Yarn is a newcomer to the
Javascript scene. It is a replacement for [npm](https://www.npmjs.com/), and
was developed as "a collaboration between Facebook, Exponent, Google, and
Tilde". It still pulls libraries from the "npm registry, but can install
packages more quickly and manage dependencies consistently across machines or in
secure offline environments."

## Webpack

Sprockets does a lot of work, and it's work our new toolchain will now need to
handle, such as concatenating the Javascript and CSS files, minifying them,
transpiling CoffeScript to Javascript, etc. To do that we need a new tool. We're
going to use [Webpack](http://webpack.github.io).

Webpack is a lot like [Grunt](http://gruntjs.com/) and
[Gulp](http://gulpjs.com/), but is quickly gaining more and more mindshare. If
you're not familiar with any of these tools, the idea is really simple: they
take the asset files (CSS, Javascript, SaSS, images, etc.), and process them for use.

Webpack is the tool which will handle transpiling CoffeeScript to Javascript,
including all the dependencies, minifying the output, exporting the files, and
everything else we once relied on Sprockets to perform.

We can install Webpack with two commands. The first installs webpack into the
global space, allowing us to call the `webpack` command from the command line.

```bash
yarn global add webpack
```

The second command adds Webpack to our development environment so we can use it
from within our `webpack.config.js` file.

```bash
yarn add --dev webpack
```

### Webpack configuration

Webpack needs to know which directories to read from, what transformations
it needs to apply to what files, and where to put everything once it's completed
its run. To provide it direction, we need to create a `webpack.config.js` file
which will live in the Rails app's root directory:

```javascript
'use strict';

const webpack = require("webpack");

module.exports = {
  context: __dirname + "/app/assets/javascripts",

  entry: {
    application: "./application.js",
  },

  output: {
    path: __dirname + "/public",
    filename: "javascripts/[name].js",
  },
};
```

The configuration file can be boiled down to two actions: take an input (the
"entry" block) and producing an output (the "output" block). More specifically,
it's instructing Webpack to read the `application.js` file from
`/app/assets/javascripts`, perform any actions required by that file such as
including other libraries, giving it the name "application", and then output
the resulting file(s) to `/public/javascripts/application.js`.

Try it for yourself: run `webpack` from the command line.

## Nixing the pipeline

With Webpack providing our new foundation, we can start removing the old asset
pipeline.

### The Gemfile

To begin cutting our ties to the past, we need to first remove some Ruby
dependencies.

Comment out or delete the following gems from your `Gemfile` and run `bundle`
from the command line:

* sass-rails
* uglifier
* jquery-rails
* turbolinks
* coffee-rails

These gems are no longer needed, being
replaced or deprecated by Webpack and the Javascript libraries we'll install
later..

### Environment files

Our next task will be to tell Rails to ignore assets in both the
`development.rb` and `production.rb` files of `config/environments` (`test.rb`
will be left untouched.)

In your `config/environments/development.rb` file:

```ruby
config.assets.debug = false

config.assets.compile = false

config.assets.quiet = true
```

In the `config/environments/production.rb` file:

```ruby
config.public_file_server.enabled = true

# config.assets.js_compressor = :uglifier
# config.assets.css_compressor = :sass
```

We enable `config.public_file_server` in order to serve static files out of the
`/public` directory.

## Install Javascript and CSS compilers and transpilers

By removing `jquery-rails`, `coffee-rails`, and `sass-rails` we've put ourselves
in a bit of a pickle: we're stuck with raw CSS and Javascript. Let's fix that.

### Babel -> ES6

First, the bad news: This tutorial doesn't cover adding CoffeeScript. Now the
good news: ES6 more than makes up for it.

CoffeeScript made Javascript nicer by cleaning up the syntax, simplifying class
creation, perform string interpolation, and call functions. ES6 is doing the
same thing, albeit with a more Javascript feel, and it will be the language
browsers eventually switch too.

[Babel](http://babeljs.io/) is the library we'll use to transpile ES6 to pure
Javascript. We can install it with the following command:

```bash
yarn add --dev babel-core babel-preset-es2015 babel-polyfill
```

With babel installed, we then need to add a "loader" to enable webpack to use
it:

```bash
yarn add --dev babel-loader # loader for webpack
```

The last thing we must do is configure Webpack to use it. We'll do that by
adding the loader to the "module" section:

```javascript
'use strict';

const webpack = require("webpack");

module.exports = {
  ...

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          presets: ['es2015']
        }
      },
    ]
  },
};

```

If you add the following line to your `app/assets/javascripts/application.js`
file, and run `webpack`, you'll see it output into pure Javascript in the
`public/javascripts` directory:

```javascript
let odds = [0,2,4,6,8].map(v => v + 1);
```

### CSS & SASS

Adding CSS and [Sass](http://sass-lang.com/) isn't much different from adding
Babel. We need to install the libraries and the loaders, and then modify the
`webpack.config.js` file.

Install the CSS and Sass libraries with the following commands:

```bash
yarn add --dev css-loader style-loader extract-text-webpack-plugin

yarn add --dev sass-loader node-sass
```

To update your config file, first add the following line near the top of the
file:

```javascript
const ExtractTextPlugin = require("extract-text-webpack-plugin");
```

Next, you'll want to add the "loader" underneath the Babel loader:

```javascript
{
  test: /\.css$/,
  loader: ExtractTextPlugin.extract("css!sass")
}
```

Finally, we need to add a "plugins" section underneath the "module" section and
initialize the `ExtractTextPlugin`:

```javascript
plugins: [
  new ExtractTextPlugin("stylesheets/[name].css"),
]
```

The `ExtractTextPlugin` will handle moving our CSS files to their final resting
place.

If we run `webpack` now, we're not going to see our CSS files output. I'll get
to that in a minute, but first I'd like to talk about the importance of
fingerprinting.

## Fingerprinting

When the Asset Pipeline was introduced, a new method of "fingerprinting" assets
was also introduced:

> Fingerprinting is a technique that makes the name of a file dependent on the contents of the file. When the file contents change, the filename is also changed. For content that is static or infrequently changed, this provides an easy way to tell whether two versions of a file are identical, even across different servers or deployment dates. - [The Rails Guides](http://guides.rubyonrails.org/asset_pipeline.html#what-is-fingerprinting-and-why-should-i-care-questionmark)

Fingerprinting allows us to make changes to the assets, compile and deploy the
changes, and in the process, break the caching of the previous versions. Webpack
allows us to continue fingerprinting our assets, by simply adding `[hash]` to
the filename attibute.

In the "output" section, replace the "filename" line with the following:

```javascript
filename: "[name]-[hash].js",
```

And in the "plugins" section, replace the only line with this:

```javascript
new ExtractTextPlugin("stylesheets/[name]-[hash].css"),
```

Running `webpack` now creates the files with the added "hash" signature. There's
just two more issues we need to tackle: 1) getting Rails to read the correct
asset file; 2) deleting the previously compiled files.

### Giving Rails the Fingerprint

The easiest way to provide Rails the fingerprint is to dump the hash into an
configuration file. We can do that by dumping it into an initializer.

To work with files, we'll first need to include the File System (`fs`) module at
the top of your webpack.config.js:

```javascript
const fs = require('fs');
```

Then we can create the plugin to perform the write:

```javascript
plugins: [
  ...

  function() {
    // output the fingerprint
    this.plugin("done", function(stats) {
      let output = "ASSET_FINGERPRINT = \"" + stats.hash + "\""
      fs.writeFileSync("config/initializers/fingerprint.rb", output, "utf8");
    });
  }
]
```

This function opens the `config/initializers/fingerprint.rb` file for
writing and then adds the `ASSET_FINGERPRINT` constant and hash to the file. If
the file already exists, it just overwrites it.

Unfortunately, if we only rely on retrieving the fingerprint from the
initializer, it means we'll need to restart the Rails server each time we change
and recompile an asset. That won't do. To get around that, we'll want to change
some behavior depending on whether or not we're running in production.

Add the following lines near the top of your `webpack.config.js` file:

```javascript
const prod = process.argv.indexOf('-p') !== -1;
const css_output_template = prod ? "stylesheets/[name]-[hash].css" : "stylesheets/[name].css";
const js_output_template = prod ? "javascripts/[name]-[hash].js" : "javascripts/[name].js";
```

When you pass the `-p` flag to the `webpack` command, it prepares the assets as
if it were in production. We can use that to our advantage, structuring the CSS
and Javascript output files accordingly. If we're in production, we'll create
asset files with fingerprints. When we're in development, we won't.

You'll need to change the `filename` key of the `output` section to
`js_output_template`, and the argument to `ExtractTextPlugin` to
`css_output_template` in the `plugins` directory.

Finally, we can use a helper method to allow us to include the asset
files in our views:

```ruby
module ApplicationHelper
  def fingerprinted_asset(name)
    Rails.env.production? ? "#{name}-#{ASSET_FINGERPRINT}" : name
  end
end
```

And in our view:

```ruby
<%= stylesheet_link_tag    fingerprinted_asset('application'), media: 'all' %>
<%= javascript_include_tag fingerprinted_asset('application') %>
```

### Removing previous assets

In the same way that fingerprinting breaks the cache by creating a new filename,
it also leaves behind the old files. If you look in your `public/javascripts`
and `public/stylesheets` folders, you'll see them littered with previously
created assets. We need to get rid of those. We can do that by adding function
to the `plugins` section to handle it:

```javascript
plugins: [
  ...

  function() {
    // delete previous outputs
    this.plugin("compile", function() {
      let basepath = __dirname + "/public";
      let paths = ["/javascripts", "/stylesheets"];

      for (let x = 0; x < paths.length; x++) {
        const asset_path = basepath + paths[x];

        fs.readdir(asset_path, function(err, files) {
          if (files === undefined) {
            return;
          }

          for (let i = 0; i < files.length; i++) {
            fs.unlinkSync(asset_path + "/" + files[i]);
          }
        });
      }
    });
  }
]
```

This function just loops through all the files in both the `javascripts` and
`stylesheets` folders, deleting them as it goes, or breaking out if there are no
files. Don't worry, the only files which should be in those directories will
have been put there by Webpack.

## Multiple outputs through multiple entries

At this point, when you run `webpack` from the command line, the only thing
which is output is the `application.js` file. That's cool, but we also need the
CSS file. The solution is super simple, we just turn the "entry" into an array
and provide the CSS file:

```javascript
entry: {
  application: ["./javascripts/application.js", "./stylesheets/application.css"]
},
```

Now, let's say we had Javascript and CSS we only wanted to use in a specific
view like a "Contact us" page. We could continue to dump all the things into
"application", *or* we could break those assets out into their own files:

```javascript
entry: {
  application: ["./javascripts/application.js", "./stylesheets/application.css"]
  contact: ["./javascripts/contact.js", "./stylesheets/contact.css"]
},
```

Doing this – assuming you have a `contact.js` and `contact.css` file - will
produce the `application.js` and `application.css`, and `contact.js` and
`contact.css` files in the public folder which you can then use in the
appropriate views.

## Deploying to Heroku

For the sake of completeness, let's make sure we can deploy to Heroku. I'm going
to assume you have a Heroku account, know how to create a new app, and also how
to type `git push heroku`.

When we initially commented out gems related to the pipeline, we didn't touch
the `sqlite3` gem. Heroku doesn't support SQLite, so you'll need to replace the
`sqlite3` gem with the `pg` gem.

Next, we've done everything necessary to host assets from the `/public`
directory, but Heroku's still going to try to precompile the assets. To get
around that, we're going to override (i.e. monkeypatch) the `assets:precompile`
rake task with one of our own (HT: [Josh Becker](http://blog.geesu.net/))

```ruby
# /lib/tasks/assets.rake
Rake::Task["assets:precompile"].clear
namespace :assets do
  task 'precompile' do
    puts "#----- Skip asset precompilation -----#"
  end
end
```

Finally, and this may be the most irritating piece of the entire puzzle, before
you deploy to Heroku, you'll need to remember to both compile webpack for
production *and* commit it.

```bash
webpack -p
```

Seriously, you think it's hard to remember to run `heroku run rake db:migrate`?
Yeah. This is so much more easily forgettable.

We now have a complete replacement for the Rails Asset Pipeline. You can
continue developing Javascript and CSS in your normal directories, and even
better, when you're looking at how to install new Javascript files, you no
longer need to worry about installing them manually or hoping for a Ruby gem to
do it for you. Now you can just type:

```bash
yarn add <packagename>
```

Ruby on Rails is still awesome and it's still helping companies launch new
products every day, but Node.js and its ecosystem are pretty awesome too. For a
while we really did need Rails to handle compiling and bundling our assets into
a manageable output, but things have changed and it's in our best interest to
start using the tools which are best suited to the task.

## For your reference - The final `webpack.config.js`

```Javascript
const fs = require('fs');
const webpack = require("webpack");
const ExtractTextPlugin = require("extract-text-webpack-plugin");

const prod = process.argv.indexOf('-p') !== -1;
const css_output_template = prod ? "stylesheets/[name]-[hash].css" : "stylesheets/[name].css";
const js_output_template = prod ? "javascripts/[name]-[hash].js" : "javascripts/[name].js";

module.exports = {
  context: __dirname + "/app/assets",
  entry: {
    application: ["./javascripts/application.js", "./stylesheets/application.css"]
  },

  output: {
    path: __dirname + "/public",
    filename: js_output_template,
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          presets: ['es2015']
        }
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("css!sass")
      },
    ]
  },

  plugins: [
    new ExtractTextPlugin(css_output_template),

    function() {
      // delete previous outputs
      this.plugin("compile", function() {
        let basepath = __dirname + "/public";
        let paths = ["/javascripts", "/stylesheets"];

        for (let x = 0; x < paths.length; x++) {
          const asset_path = basepath + paths[x];

          fs.readdir(asset_path, function(err, files) {
            if (files === undefined) {
              return;
            }

            for (let i = 0; i < files.length; i++) {
              fs.unlinkSync(asset_path + "/" + files[i]);
            }
          });
        }
      });

      // output the fingerprint
      this.plugin("done", function(stats) {
        let output = "ASSET_FINGERPRINT = \"" + stats.hash + "\""
        fs.writeFileSync("config/initializers/fingerprint.rb", output, "utf8");
      });
    }
  ]
};
```

## Updates

* **Update 12/14/2016:** Webpack and Yarn are coming to Rails 5.1! In the pull request, [Add Yarn support in new apps using --yarn option](https://github.com/rails/rails/pull/26836), it's revealed that both Yarn and Webpack are set to be added in Rails 5.1. Webpack will only be responsible for JavaScript, while other assets will continue to be handled by the asset pipeline.
* **Update 12/01/2016:** Jason Galvin spotted an error, prompting me to add a check for existing files in the asset deletion block under "plugins"
* **Update 11/21/2016:** Jeremy Weathers at [CodeKindly.com](http://codekindly.com) spotted a missing `const fs = require('fs');` under "Giving Rails the Fingerprint"
