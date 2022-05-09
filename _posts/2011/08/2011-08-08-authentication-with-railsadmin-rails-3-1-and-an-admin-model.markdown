--- 
title: "Authentication with RailsAdmin, Rails 3.1, and an Admin Model"
date: 2011-08-08
comments: false
post: true
categories: [ruby on rails, RailsAdmin]
---
One of the requirements I have been given for a new web application - some are now calling it "cloud application" - is an admin section which would allow admin users to create and modify content. I decided to use [Erik Michaels-Ober's](http://twitter.com/#!/sferik) [rails_admin](https://github.com/sferik/rails_admin) gem/rails engine for the job.

Since the app I'm working on has a requirement of using an admins table rather than applying an admin boolean column to the users table, the normal setup didn't quite apply for me.

Here's what I had to do to set up RailsAdmin to use the Admin model.

### Installation
Installation is just like that shown in the rails_admin README file. Add the following line to your Gemfile and run "bundle install"

``` ruby
gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'
```

### Setup
Once the gem is installed, you have to run the "rails_admin:install" rake command with the "model_name" parameter. If you are using a model other than "Admin", substitute "admin" for that.

``` ruby
rake rails_admin:install model_name=admin
```

Running this command adds an entry in your routes.rb file which will allow you to go to "/admin" to administer your app. It will also add the "rails_admin.rb" initializer file ("config/initializers").

### Configuration
By default, anyone can access the /admin side of the app. To mitigate this, add the following lines to your rails_admin.rb config file.

``` ruby
RailsAdmin.config do |config|
  config.authenticate_with {} # leave it to authorize
  config.authorize_with do
    redirect_to main_app.new_admin_session_path unless current_admin
  end
end
```

The first line within the block ("authenticate_with {}") disables authentication - we'll let the authorize step handle it. The next piece redirects users to the admin login screen (new_admin_session_path) if they have not logged in (unless current_admin). Since rails_admin is an engine, we have to call "new_admin_session_path" through the main_app object.

After restarting your server, you should begin getting redirected to /admins/sign_in if you are not currently signed in.

## Further Reading
* [rails_admin](https://github.com/sferik/rails_admin)
* [RailsCasts #277](http://railscasts.com/episodes/277-mountable-engines)
* [Authentication in RailsAdmin with SimplestAuth](http://www.viget.com/extend/authentication-in-rails-admin-with-simplest-auth/)
