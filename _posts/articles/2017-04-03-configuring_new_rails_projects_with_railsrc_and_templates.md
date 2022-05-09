---
title: "Configuring New Rails Projects With .railsrc and Templates"
author: "Samuel Mullen"
description: "Templates and .railsrc files have been around since Rails 3.x, but somehow I'm just finding this out now. Learn from my ignorance and simplify setting up all your future rails projects."
date: "2017-04-03T06:57:37-05:00"
tags: [ "howto", "rails" ]
---

If you've used Unix/Linux for any length of time, you're famililar with dotfiles. They're those files begining with a `.` and usually ending with `rc`: `.bashrc`, `.vimrc`, and `.psqlrc` being familiar examples. Modifying these files allows you to configure the behavior of the assocated program, and can be a neverending quest for some to get the "perfect" setup.

This past week I discovered Rails has a dotfile as well, `.railsrc` (Yes, that's right. I'm just learning this now after a decade of working with Ruby on Rails.) Not only does it have a dotfile, but it also accept a "template" of commands to be run after the new Rails project has been created. These files only come into play when starting new Rails projects.

# .railsrc

When you create a new Rails project with `rails new <projectname>` you can
additionally pass along a number of "flags" which will provide some initial
customizations for the new project. You can declare which database to use,
whether or not to run bundler at the start, or even if you want to [avoid the use of the asset pipeline](//samuelmullen.com/articles/replacing-the-rails-asset-pipeline-with-webpack-and-yarn/).

Alternatively, you can put those flags in a `.railsrc` file located in your `$HOME` directory and avoid typing them in altogether. For a complete list of available flags and their definitions, just type `rails` at the command line (you must do this outside of a rails project).

This is my current `.railsrc` file:

```unix
# ~/dotfiles/.railsrc

--database=postgresql
--webpack
--skip-action-cable
--skip-spring
--skip-coffee
--skip-turbolinks
--template=~/dotfiles/rails_template.rb
```

# Template

The last line of my `.railsrc` file specifies a "template" to use. Template files are used to further set up an initial project by specifying gems, setting up resources, and get your project to a solid initial state. Furthermore, template files have the same features and abilities of a [generator file](http://guides.rubyonrails.org/generators.html), which means they also include [Thor's actions](http://www.rubydoc.info/github/erikhuda/thor/master/Thor/Actions.html) as well.

This is my current template file, which is inspired from both [Ivan Storck's gist](https://gist.github.com/ivanoats/8480833) and [Richard Campbell's blog article](https://richonrails.com/articles/customizing-the-rails-app-generator). A short description is provided afterward.

```ruby
gem_group :development, :test do
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem "minitest-rails-capybara"
  gem "factory_girl_rails"
  gem "pry-rails"
end

gem_group :development do
  gem 'guard', "~> 2.14", require: false
  gem 'guard-minitest', "~> 2.4", require: false
end

gem_group :test do
  gem "launchy"
end

run "bundle install"

if yes? 'Do you wish to generate a root controller? (y/n)'
  name = ask('What do you want to call it?').to_s.underscore
  generate :controller, "#{name} show"
  route "root to: '#{name}\#show'"
  route "resource :#{name}, controller: :#{name}, only: [:show]"
end

generate "minitest:install"

guardfile = <<-EOL
  guard :minitest, :all_on_start => false do
    watch(%r{^test/(.*)_test\.rb$})
    watch(%r{^lib/(.+)\.rb$})         { |m| "test/lib/\#{m[1]}_test.rb" }
    watch(%r{^test/test_helper\.rb$}) { 'test' }

    watch(%r{^app/(models|mailers|helpers)/(.+)\.rb$}) { |m|
      "test/\#{m[1]}/\#{m[2]}_test.rb"
    }
    watch(%r{^app/controllers/api/(.+)_controller\.rb$}) { |m| "test/requests/\#{m[1]}_test.rb" }
  end
EOL

create_file "Guardfile", guardfile
```

The template is broken up into three areas: gems, a base controller, and a basic minitest setup.

For the gem areas, you can see that I've used `gem_group` instead of just `group` as you would in your `Gemfile`. Once the gems have been defined, we `bundle install` with the `run` command.

The next area sets up a "root" controller. `yes?` is a command in Thor which pauses execution of the script, waiting for a yes/no response from the user. If the script receives a "yes" or "y", it then `ask`s for a name for the controller. Once that's receives it finishes off the resource by creating the controller and adding the routes.

The last piece is setting up minitest, and that just "generates" the `minitest:install` and creates a basic file for use by [Guard](https://github.com/guard/guard).

I'll continue to tweak these files as new projects come in and patterns emerge. I'm still kicking myself for not having found this sooner.
