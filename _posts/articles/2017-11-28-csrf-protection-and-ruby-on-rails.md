---
title: CSRF Protection and Ruby on Rails
date: "2017-11-28T06:16:16-06:00"
description: "CSRF errors can be a pain to work with. Rather than skipping them, learn how to avoid the errors and ensure the security of your site."
comments: false
post: true
categories: [rails, security]
---

If you've worked with any number of Ruby on Rails projects you'll know that people put a lot of effort into getting around Rails' conventions. You'll usually see this when the developers came from other frameworks, refuse to do things the Rails Way&trade;, or when they were facing pressure to "just get things done."

One of the work-arounds I've seen most frequently is bypassing CSRF protection altogether with the following line in the controller(s):

```
skip_before_action :verify_authenticity_token
```

This shouldn't come as a surprise. The error messages can be cryptic, and the only place in the Rails Guides CSRF is mentioned is in the [Ruby on Rails Security Guide](http://guides.rubyonrails.org/security.html) and briefly in the [`csrf_meta_tags`](http://api.rubyonrails.org/classes/ActionView/Helpers/CsrfHelper.html) page. You'd think it would be covered in [Working with JavaScript in Rails](http://guides.rubyonrails.org/working_with_javascript_in_rails.html), but there isn't a single mention of it. Based on some of the "answers" I've seen in the past, you might even conclude that skipping the authenticity token was standard practice when handling JavaScript requests. Of course, that's not the case. 

## What is CSRF?

CSRF (Cross-Site Request Forgery) is a method of attack that "works by including malicious code or a link in a page that accesses a web application the user is believed to have authenticated. If the session for that web application has not timed out, an attacker may execute unauthorized commands." ([Cross-Site Request Forgery (CSRF)](http://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf))

The idea is that because a user remains "signed in" even after leaving a site, a "black hat" site can make requests to the signed in site as if it was the user.

The Rails Guides has an excellent example scenario:

> * Bob browses a message board and views a post from a hacker where there is a crafted HTML image element. The element references a command in Bob's project management application, rather than an image file: `<img src="http://www.webapp.com/project/1/destroy">`
> * Bob's session at `www.webapp.com` is still alive, because he didn't log out a few minutes ago.
> * By viewing the post, the browser finds an image tag. It tries to load the suspected image from `www.webapp.com`. As explained before, it will also send along the cookie with the valid session ID.
> * The web application at `www.webapp.com` verifies the user information in the corresponding session hash and destroys the project with the ID 1. It then returns a result page which is an unexpected result for the browser, so it will not display the image.
> * Bob doesn't notice the attack - but a few days later he finds out that project number one is gone.  

Notice in the above scenario that the attack comes from a "GET" request in the `img` tag. While we might laugh thinking no one would have a route like the one above, I have seen enough Rails projects to know that it's common to see "GET" routes in place of what should be "POST", "PUT", or even "DELETE" actions.

The problem with using a "GET" requests for actions other than retrieving data is that Rails only checks CSRF tokens for non-"GET" requests.

## How Rails Protects Against CSRF Attacks?

Rails, like most modern frameworks, comes with CSRF protection baked in. It does so by setting the CSRF token in the session, in the `meta` tags in your site's `<head />` area, and as a hidden field in each form.

Alex Taylor explains how this works: 

> There are two components to CSRF. First, a unique token is embedded in your site's HTML. That same token is also stored in the session cookie. When a user makes a POST request, the CSRF token from the HTML gets sent with that request. Rails compares the token from the page with the token from the session cookie to ensure they match. — [A Deep Dive into CSRF Protection in Rails](https://medium.com/rubyinside/a-deep-dive-into-csrf-protection-in-rails-19fa0a42c0ef)

Without any intervention on your part, Rails sets the session cookie and — if you're using `form_for` or `form_tag` — adds the hidden form field with the name, `authenticity_token`. Even the "csrf-token" `meta` tag is inserted for you as long as you leave the `csrf_meta_tags` line in your `application.html.erb` layout file.

When a request is made, Rails ensures both the session cookie and the form parameter match up. It does this with the `protect_from_forgery` line in your `ApplicationController`. All controllers subclassed from `ApplicationController` inherit the same protection.

Let's face it, you have to try pretty hard to get Rails not to use CSRF protection.

## Working With CSRF

If you're working with traditional forms which require a full page refresh after submission, there isn't much more to talk about. Rails takes care of everything for you. If you're using `remote: true` in your forms, Rails again takes care of everything for you thanks to the `jquery-rails` gem.

Many sites don't use traditional forms anymore. They're either juiced up with a little jQuery AJAX magic or are completely generated with a JavaScript framework like [React.js](http://reactjs.org) or [Vue.js](https://vuejs.org). In these instances, the forms are either not submitted in toto or the forms are being generated by the frameworks themselves.

In these instances, PUTs, PATCHes, POSTs, and DELETEs need to send along the CSRF token. To do that, your code must first retrieve the token from the header. Next, it needs to send it along with the form submission.

### Retrieving the CSRF Token

As already discussed, Rails includes the CSRF token in the `head` of your `application.html.erb` layout file with the `csrf_meta_tags` helper. All you need to do is retrieve it.

Retrieving the CSRF token with jQuery:

```javascript
var token = $('meta[name=csrf-token]').attr('content');
```

Retrieving the CSRF token with JavaScript

```javascript
var token = document.getElementsByName('csrf-token')[0].content
```

### Attaching the CSRF Token to the Form Submission

Once the token is retrieved, you need to include it in the headers when you send data to the server. Below are examples of how to do this with both jQuery and JavaScript's `fetch`.

Using jQuery's `ajax` method:

```javascript
var token = $('meta[name=csrf-token]').attr('content');
var data = { post: { title: "some title", content: "Lorem ipsum dolor" } }

$.ajax({
  url: '/api/v1/posts',
  type: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': token) 
  },
  data: data,
  success: function(response) {
    doSomething(response);
  }
});
```

Using JavaScript's `fetch` method:

```javascript
var token = $('meta[name=csrf-token]').attr('content');
var data = { post: { title: "some title", content: "Lorem ipsum dolor" } }

fetch('/api/v1/posts', {
  method: 'POST',
  body: JSON.stringify(data),
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': token
  },
  credentials: 'same-origin'
}).then(function(response) {
  return response.json();
}).then(function(data) {
  console.log(data);
});
```

## When You Don't Need CSRF

By default, Rails applies CSRF protection to all controllers that subclass from `ApplicationController` using the following line:

```ruby
protect_from_forgery with: :exception
```

But are there instances where you'd want to respond differently, or even ignore CSRF protection altogether? The answer, of course, is "yes".

If your project or a portion of your project uses an alternative method for authentication such as API tokens or any other "stateless" authentication, then you can safely remove the `protect_from_forgery` line from whatever base class those controllers inherit.

On the other hand, if your project uses stateful authentication *and* APIs, such as those projects with lots of AJAX requests, it can be advantageous to use `:null_session` with `protect_from_forgery` like so:

```ruby
protect_from_forgery with: :null_session
```

> That means the user won’t be logged in anymore for that action and can’t perform the change (if the action requires a signed in user). However, after the action the session values will be back and the session ID will be the same, so the user will be logged in.  
> — [Ruby on Rails Security Project](https://rorsecurity.info/portfolio/cross-site-request-forgery-and-rails)

Rather than throwing an exception, which your JavaScript may not be able to handle, it instead sets the session value to `nil` for the duration of the action. By doing this, any authorization or action scoped to the current user will result in errors which your JavaScript can more easily work with.

## Conclusion

In the "bad old days" of web development, we didn't concern ourselves with security features such as CSRF—or even password hashing, but let's not talk about that. It wasn't out of laziness or even carelessness that we didn't; it just wasn't common knowledge. Unless you knew what to look for, you usually didn't know what to look for.

Thankfully, today's frameworks come with many of these "features" built in. While they are there to simplify security and protect us from our ignorance, they can be difficult to navigate around. By working with the framework and taking the time to understand why these "roadblocks" are put in place, we protect ourselves and only make our work better.
