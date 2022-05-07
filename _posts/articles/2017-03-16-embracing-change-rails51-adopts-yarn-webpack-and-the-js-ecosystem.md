+++
title = "Embracing Change: Rails 5.1 Adopts Yarn, Webpack, and the JS Ecosystem"
date = "2017-03-16T14:55:56-05:00"
description = "Many naysayers would have you believe Rails is dead. Don't believe the hype. With the coming of Rails 5.1 and its embrace of the JS ecosytem, Rails is solidifying its position as the king of web frameworks."
author = "Samuel Mullen"
tags = ["rails","webpack","javascript","yarn"]
+++

For many years, [Ruby on Rails](http://rubyonrails.org/) has been the go-to framework for startups, micropreneurs, SMBs, and really for anyone who needed to build and launch a tool quickly. With its opinionated, [convention over configuration](https://en.wikipedia.org/wiki/Convention_over_configuration) approach, and [Heroku's](http://heroku.com) brilliant `git push` to deploy feature, Ruby on Rails made every other solution look barbaric by comparison.

But all good things come to an end, and to many it seemed that Rails was on the decline. It began with [node.js](http://nodejs.org/), but then came the never ending onslaught of new JavaScript frameworks. The web was changing and Rails didn't seem to be keeping up. After all, what did it offer in response? Russian doll caching, [Concerns](http://api.rubyonrails.org/classes/ActiveSupport/Concern.html), [Turbolinks](https://github.com/turbolinks/turbolinks), and [ActionCable](https://github.com/rails/actioncable)? Each of these technologies are great, but it felt like Rails was still focused on either the old server-rendered way of doing things, or a sort of grumpy-old-man approach to the changing nature of the web.

Even if you wanted to use the new JavaScript frameworks and libraries with
Rails, it was no simple feat. The Asset Pipeline didn't help much in the matter,
relying on ruby wrappers of JavaScript libraries was questionable at best, and
rolling your own solution with [Gulp](http://gulpjs.com) or
[Grunt](http://gruntjs.com) was a non-trivial problem. We even wrote an article
about how to [Replace the Rails Asset Pipeline](//samuelmullen.com/articles/replacing-the-rails-asset-pipeline-with-webpack-and-yarn/), which while helpful, still left some problems to be solved by the reader.

[Now all of this has changed](http://weblog.rubyonrails.org/2017/2/23/Rails-5-1-beta1/). With [Pull Request 26836](https://github.com/rails/rails/pull/26836) and the inclusion of the [webpacker gem](https://github.com/rails/webpacker), the Rails team is showing why Ruby on Rails will remain the framework of choice for the web. Not only are they embracing change, but they're applying the same "Convention Over Configuration" philosophy to the problem and are going to make JavaScript developers jealous with how easy it is to use their own toolsets.

Let's see how Rails has begun integrating Yarn and webpack and along the way we'll dive into these new technologies to get a better understanding of how they work.

## Setup

As of this writing, the [webpacker gem](https://github.com/rails/webpacker) in only included with Rails 5.1.0.beta1+, but is compatible with versions as old as 4.2. Once installed it provides your project with the ability to install JavaScript libraries with [Yarn](http://yarnpkg.com/) ([discussed below](#yarn)) and "compile" JavaScript assets with [webpack](http://webpack.github.io/) ([also discussed below](#webpack)).

### Rails 5.1.0.beta1+

There are two ways of adding the new features to the latest version of Rails:

1. Including the `--webpack` flag on creation. Example: `rails new example --webpack`
2. Installing it after the fact with a rake task. Example: `rake webpacker:install`

Once installed, you'll have access to the following tasks:

```
rake webpacker                   # Lists available tasks under webpacker
rake webpacker:compile           # Compile javascript packs using webpack for production with digests
rake webpacker:install           # Install webpacker in this application
rake webpacker:install:angular   # Install everything needed for Angular
rake webpacker:install:react     # Install everything needed for react
rake webpacker:install:vue       # Install everything needed for Vue
rake yarn:install                # Install all JavaScript dependencies as specified via Yarn
```

Notice also that you can set up webpack with your JavaScript framework of choice, assuming "your choice" includes [Angular](http://angular.io/), [React](http://reactjs.com/), or [Vue](http://vuejs.org).

### Rails 4.2 and Up

For versions prior to 5.1, add the webpacker gem to your `Gemfile` and run `bundle install`. Afterwards, you'll have access to the following four rake tasks:

```
rake webpacker:compile           # Compile javascript packs using webpack for production with digests
rake webpacker:install           # Install webpacker in this application
rake webpacker:install:angular   # Install everything needed for Angular
rake webpacker:install:react     # Install everything needed for react
```

Note the difference in available tasks between 4.2+ and 5.1. This may change in future webpacker updates.

## What's Included?

Once installed, you'll notice a number of new files and directories have been added to your project. Let's look at each of these in turn.

### Binstubs

Under your project's `/bin` directory, you'll find the following new executables: `webpack`, `webpack-dev-server`, `webpack-watcher`, and `yarn`. Each are Ruby scripts wrapped around the `webpack` executable to provide some easy-to-use functionality.

* **webpack**: The primary script used to compile your "packs" into the final output. It works with the current environment and accepts the same arguments you would normally pass to `webpack` directly.
* **webpack-dev-server**: This allows you to run your own server from which to load assets. "This setup allows you to leverage advanced webpack features, such as [Hot Module Replacement](https://webpack.github.io/docs/hot-module-replacement-with-webpack.html)." As the name implies, this will only be used in development.
* **webpack-watcher**: This script watches for changes in the `app/javascript/` directory and compiles them as changes are made.
* **yarn**: A basic wrapper around the yarn executable. 

### Configuration Files

Configuration files for webpack can be found in the `config/webpack/` directory (I'm showing my age calling it "directory"): `development.js`, `production.js`, and `shared.js`.

Most projects won't need anything done to either the `development.js` or `production.js` files, and will instead only need to modify the `shared.js` file which both of the other files include. 

The `development.js` config includes some flags which are useful during development.

* `devtool: 'sourcemap'`: Used to map compressed files back to their original source. The [webpack documentation](https://webpack.js.org/configuration/devtool/#devtool) says "source-map", not "source map"
* `stats.errorDetails: true`: "Add details to errors (like resolving log)"
* `output.pathinfo: true`: "Tell webpack to include comments in bundles with information about the contained modules."
* `webpack.LoaderOptionsPlugin`: This is here primarily to allow you to use webpack1 loaders. Webpack 2 was only recently released, and not every plugin has been updated for it.

The `production.js` config file is a bit different than the `development.js` file. Instead of helping you debug issues or simplify reading the code, it's designed for performance, which means it's output is going to be "uglified" (using the `UglifyJsPlugin`), compressed (using the `CompressionPlugin`), and given a "fingerprint" for caching.

The last config file is the `shared.js` file. This file is included in both the `development.js` and the `production.js` file, and will be the one you'll most likely need to modify. While I won't go into detail about what this configuration file does, I cover some general webpack principals and provide some descriptions in the [webpack](#webpack) section below.

## Yarn

Let's back up a bit. We've jumped head-first into a whole new Ruby on Rails, looking at rake tasks, configuration files, and executables, but we haven't yet discussed what some of these new features are. Let's look at the first one.

The first of these is [Yarn](http://yarnpkg.com/). "Yarn is a package manager for your code". Think of it as Bundler for JavaScript. It was built through "a collaboration between [Facebook](http://facebook.com), [Exponent](http://www.exponent.com/), [Google](http://google.com), and [Tilde](https://www.tilde.io/)." That's a collection some heavy hitters, and one of those companies ([Tilde](https://www.tilde.io/)) has the guy ([Yehuda Katz](https://github.com/wycats)) that brought us Bundler in the first place.

Yarn uses a file similar to Bundler's `Gemfile` called `package.json`. It's located in the Rails root directory, and it looks like this:

```
// package.json
{
  "name": "packing",
  "private": true,
  "dependencies": {
    "babel-core": "^6.24.0",
    "babel-loader": "^6.4.0",
    "babel-preset-env": "^1.2.1",
    "compression-webpack-plugin": "^0.3.2",
    "glob": "^7.1.1",
    "path-complete-extname": "^0.1.0",
    "rails-erb-loader": "^3.2.0",
    "webpack": "^2.2.1",
    "webpack-merge": "^4.0.0"
  },
  "devDependencies": {
    "webpack-dev-server": "^2.4.2"
  }
}
```

Notice that it's broken up into two sections: "dependencies" and "devDepenencies". Yarn follows a similar pattern in its `package.json` file as Bundler does with its `Gemfile`, and groups packages based on whether it is for development ("devDependences") or runtime ("dependencies").

If you want to add a new package, add it to the appropriate section and run `bin/yarn` from the command line. 

Alternatively, you can use Yarn to add the module to the `package.json` file and pull down the libraries all at once with the following commands:

```
yarn add <package-name>       # add to 'dependences' group
yarn add <package-name> --dev # add to 'devDependencies' group
```

## Webpack

The next big features Rails is bringing in is [webpack](http://webpack.github.io/). The easiest way to describe webpack is to say it's a JavaScript version of the Rails Asset Pipeline. By default it only handles JavaScript, but if you check out the [webpack site and documentation](https://webpack.js.org/) you'll see it can do everything the Asset Pipeline can do and more.

To get started with webpack, you need to understand four basic concepts.

### Entry

Every webpack config file has an `entry` section. This can be set to either a filename or an array of filenames for webpack to use as a starting off point for knowing what to bundle. Webpack treats these files similarly to how the Asset Pipeline treats JavaScript in `app/assets/javascripts`. As it sees a dependency, it includes it in its tree.

> webpack creates a graph of all of your application's dependencies. The starting point of this graph is known as an entry point. The entry point tells webpack where to start and follows the graph of dependencies to know what to bundle. You can think of your application's entry point as the contextual root or the first file to kick off your app. 

The Rails entry configuration looks like this:

```
// config/webpack/shared.js

entry: glob.sync(path.join('app', 'javascript', 'packs', '*.js*')).reduce(
  (map, entry) => {
    const basename = path.basename(entry, extname(entry))
    const localMap = map
    localMap[basename] = path.resolve(entry)
    return localMap
  }, {}
),
```

Although this looks complex, all it's doing is collecting the JavaScript files from the `app/javascript/packs/` directory and returning them as an array. Webpack then uses those entry points to create it "output" bundles.

Note: Make sure to put your entry point files in the "packs" directory, and all your non-pipeline JavaScript files one directory up in `app/javascript/`.

### Output

Once your bundle has been created, webpack needs to know where to store it. The "output" configuration tells webpack where to do that.

In the `shared.js` file, the "output" value is defined thusly: 

```
// config/webpack/shared.js

output: { filename: '[name].js', path: path.resolve('public', distDir) },
```

This tells webpack to name the output file the same as the entry point file, and store the bundle in `public/packs` (`distDir` is defined as "packs" in the `shared.js` file). If you have a file named "application.js" in your `packs/` directory, it will be output to "application.js" in the `public/packs/` directory.

The `production.js` overrides the `shared.js` setting, adding a hash value to the output filename to act as a fingerprint. The resulting file would be named something like `application-52d19136d5660afd39af.js`.

```
// config/webpack/production.js

output: { filename: '[name]-[chunkhash].js' },
```

### Loaders

You'll likely have noticed that the JavaScript in this article as well as that in webpack configuration files looks a bit different from the JavaScript you're used to. That's because it's following the new ES6/2015 syntax. Unfortunately, not all browsers support the new syntax and features, so we need a way of transforming the ES2015 syntax to something all – or most – browsers can understand, namely, ES5. We need a webpack loader.

Loaders are modules you can install which perform actions on assets prior to those assets getting added to the bundle.

> At a high level, they have two purposes in your webpack config.
> 1. Identify what files should be transformed by a certain loader. (test property)
> 2. Transform that file so that it can be added to your dependency graph (and eventually your bundle). (use property)

For the example mentioned above, we can use the `babel-loader` to transform
ES6 JavaScript into browser-friendly ES5 JavaScript.

```
// config/webpack/shared.js

module: {
  rules: [
    ...
    {
      test: /\.js(\.erb)?$/,
      exclude: /node_modules/,
      loader: 'babel-loader',
      options: {
        presets: [
          ['env', { modules: false }]
        ]
      }
    },
    ...
  ]
},
```

In this block, we see a number of settings:

* **test**: This gives webpack a regular expression to test filenames against. In the case above, it's looking for files ending in `.js` or `.js.erb`.
* **exclude**: Another regular expression, in this case it's telling webpack what files or directories to ignore. You definitely want to ignore the `node_modules/` directory.
* **loader**: what loader to use.
* **options**: configurations specific to the loader.

### Plugins

Loaders are what webpack uses to transform files prior to being bundled. Plugins, on the other hand, are what webpack uses to transform files after being bundled.

In the `production.js` file provided by Rails, it uses the `UglifyJsPlugin` and `CompressionPlugin` to first minify and then zip the final output file. 

```
// config/webpack/production.js

plugins: [
  new webpack.LoaderOptionsPlugin({
    minimize: true
  }),
  new webpack.optimize.UglifyJsPlugin(),
  new CompressionPlugin({
    asset: '[path].gz[query]',
    algorithm: 'gzip',
    test: /\.js$/
  })
]
```

### Bundling Webpack

As touched on under [Binstubs](#binstubs), there are two methods you'll use to bundle packs. The first method is to run webpack manually. You do this with the `bin/webpack` binstub. The other method starts a process which watches the `app/javascript/` directory and then attempts to bundle the files as they are changed. You can start this process with `bin/webpack-watcher`.

Remember, webpack starts its bundling process from the `app/javascript/packs/` directory. Make sure to only put files which are entry points in this directory/

### Using Packs

Once your packs have been created, you'll want to be able to use them in your views. The webpacker gem provides a helper to do that, `javascript_pack_tag`, and you can use it like this:

```
<%= javascript_pack_tag 'application' %>
```

## Odds 'n Ends

There are a few other things you'll likely have questions about. I'll answer a few of the most obvious, but as I think of others or as I get questions, I'll add to this list.

### The Asset Pipeline

What happened to the Asset Pipeline? Long story short: nothing. You can still use the asset pipeline the way you always have – "If you like your asset pipeline, you can keep your asset pipeline". That includes the `javascripts/` directory. You can even mix packaged files with "pipelined" files in your views. You just can't include your packaged files into your "pipelined" files; well, not easily.

### Babel by Default

The webpack configuration files generated by webpacker follow the ES6/2015 JavaScript syntax. As discussed in the [Loaders](#loaders) section above, this syntax gets transpiled into ES5 which is what most browsers safely understand. The transpilation is handled by the [Babel JavaScript Compiler](https://babeljs.io/). 

ES6 is quickly becoming the standard used by web developers. If you're familiar with ES5 JavaScript syntax and [CoffeeScript](http://coffeescript.org), learning the ES6 syntax will be trivial.

### jQuery

[jQuery](http://jquery.org/) is still included in Rails by default, but only in the Asset Pipeline. Even though [you might not need jquery](http://youmightnotneedjquery.com/), some of the packages you install might. These are the steps you'll need to take to make jQuery work for those packages.

1. **Install jQuery:** To be included in the bundle, jQuery first needs to be installed. We can do that with Yarn.

```
yarn add jquery
```

2. **Use the jQuery "src":** webpack prefers the original, unmodified source code of a library, rather than the packaged "dist" code. Add this section at the same level as the "entry" and "output" sections in the `shared.js` file.
 
```
// config/webpack/shared.js

resolve: {
  alias: {
    jquery: "jquery/src/jquery"
  }
},
```

3. **Make jQuery available to other modules:** "The ProvidePlugin makes a module available as a variable in every other module required by webpack."

```
// config/webpack/shared.js

plugins: [
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    jquery: 'jquery'
  })
]
```

4. **Require jQuery in your pack:** Lastly, you'll need to import jQuery into your pack.

```
// app/javascript/application.js

import jQuery from 'jquery'

window.jQuery = jQuery
```

### Deploying to Heroku

**Not currently working.** There are some workarounds, but according the [Richard Schneeman](https://github.com/schneems) at [Heroku](http://heroku.com), "We are working on adding yarn to the buildpack for Rails right now on Heroku, so it won't work yet because we don't have the binaries in place."

See [https://github.com/rails/webpacker/issues/45](https://github.com/rails/webpacker/issues/45) for more information.

**Update: March 23, 2017** We were able to deploy a dummy app with yarn
installed. It looks like Heroku is still working through the issues of making
this a smooth transition, and they have a workaround in their article [Ruby apps now get Yarn installed when the Webpacker gem is present](https://devcenter.heroku.com/changelog-items/1114)

I'm really excited about what the Rails team has been doing to ensure Rails remains competitive in the web framework space. While it's one thing to slap on a feature in the same way a hot-rodder might bolt on a spoiler to a Honda Civic, it's quite another to do so in a way that maintains the existing "feel" of a product.

With the inclusion of webpack and Yarn, the Rails team is showing a great deal of maturity and humility, recognizing that the web is no longer rendered only from the server, but also dynamically from the client. Not only has the team embraced these changes, but they are incorporating them in such a way as to make it feel like there's a "Rails Way" to do JavaScript.

Let the mockers mock. With these new changes, Rails isn't going anywhere for a very long time.
