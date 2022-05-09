--- 
title: Simple Integration Testing with Cucumber and OmniAuth
date: 2011-05-10
comments: false
post: true
categories: [omniauth, cucumber, TDD]
---
Authenticating and signing users up through OAuth and OpenID using Ruby on Rails hasn't always been straightforward. However, with the advent of Michael Bleigh's excellent [OmniAuth](https://github.com/intridea/omniauth) gem, what once was a painstaking chore has become a rather simple step in the initial configuration of your Rails project. And with the release of version 0.2.x of the gem, integration tests of your application have become equally straightforward .

The [OmniAuth Wiki](https://github.com/intridea/omniauth/wiki) points to an [excellent article](http://blog.zerosum.org/2011/03/19/easy-rails-outh-integration-testing.html) - and one which I lean heavily on for this post - which shows you how to set up integration tests with [RSpec](https://github.com/rspec/rspec)

You'll need to edit your Cucumber environment file stored under "features/support/env.rv" and follow these steps:

### Step 1: Set up your default host
``` ruby
Capybara.default_host = 'example.org'
```

This may be optional. I've successfully run my tests with and without this line, but I've seen several articles which include it. As always, experiment and see what works for you.

### Step 2: Set up OmniAuth for Testing
``` ruby
OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:twitter, {
  :uid => '12345',
  :nickname => 'fooman',
  :user_info => {
    :first_name => 'Foo',
    :last_name => 'Man'
  }
})
```

You can add more OAuth providers just by adding more "add_mock" lines, but this should be enough to get you started. Just add any extra "user_info" data you need to the hash above. See the [Auth Hash Schema](https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema) for what is available.

### Step 3: Adding a "Sign In" Step
Somewhere in your Cucumber step files - I name mine login_steps.rb - you'll want the following lines of code to handle sign ins:
``` ruby
Given /^I am signed in with provider "([^"]*)"$/ do |provider|
  visit "/auth/#{provider.downcase}"
end
```

Now you can "sign in" within your feature files just by adding a line like 'Given I am signed in with provider "Twitter"'.

Believe or not, OmniAuth takes care of mocking the authentication flow and redirecting your tests to the appropriate locations in your project. None of the calls actually leave your workstation.

OmniAuth just makes integration testing too easy not to do it.

### Further Reading
* [OmniAuth](https://github.com/intridea/omniauth)
* [OmniAuth Wiki](https://github.com/intridea/omniauth/wiki)
* [Easy Rails OAuth Integration Testing](http://blog.zerosum.org/2011/03/19/easy-rails-outh-integration-testing.html)
* [OAuth](http://oauth.net/)
* [OpenID](http://openid.net/)
