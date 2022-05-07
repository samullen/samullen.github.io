---
title: Phoenix Templates
date: 2018-12-16T15:57:48-06:00
draft: false
description: "A look at why Phoenix templates are so performant and an introduction into how to build them."
comments: false
post: true
categories: [phoenix, elixir, templates]
---

If you are coming to the [Phoenix Framework](http://phoenixframework.org/) from
another framework such as [Ruby on Rails](https://rubyonrails.org/), Python's
[Django](https://www.djangoproject.com/), or PHP's
[Laravel](https://laravel.com/), you will notice many similarities
between your current framework and Phoenix. Many of these commonalities are very
strong, such as breaking up a project into _Models_, _Views_, and _Controllers_
(i.e. MVC), while others will have you scratching your head asking if the
developers are even from the same planet. There will still be other areas of
Phoenix which will appear very familiar, but only as long as you don't look
below the surface. Phoenix Templates are an example of this latter group.

As in most web frameworks, Phoenix templates are files containing a mixture of
static markup and the framework's underlying code; in the case of Phoenix, the
underlying code is Elixir. These templates can take the form of HTML, XML, JSON,
plain text, or any other textual file type. Where Phoenix templates differ,
however, is that they are actually compiled into functions. While this alone
would be enough to surpass the performance of other frameworks, Phoenix has yet
another trick up its sleeve:

> After compilation, templates are functions. Since Phoenix builds templates
> using linked lists rather than string concatenation the way many imperative
> languages do, one of the traditional bottlenecks of many web frameworks goes
> away. Phoenix doesn't have to make huge copies of giant strings.
>
> -- Chris McCord, _Programming Phoenix 1.4_

We'll see more about how this works shortly, but for now it's enough to know
that Phoenix templates are performant and memory friendly.

## Template Location and Naming

Phoenix templates are kept under the "templates" directory of your project's
web directory, and are grouped by the _View_ to which they are associated. For
example, if you have a `PageView.ex` in your app named "Sprawl", the templates
would be located in `lib/sprawl_web/templates/page/`. Other frameworks might
break this down by _Controller_ rather than _View_, but in Phoenix, _Templates_
and _Views_ are completely different.

Templates follow this naming convention: `<action>.<content_type>.eex`. "action"
usually, but not always, corresponds to the _Controller_ action, while
"content_type" is the requested content type of the data: HTML, JSON, XML, etc.
Lastly, `.eex` refers to Elixir's EEx library which handles transforming
the template files into their final form. A typical HTML request hitting the
`index` action of a `PageController` would result in a page being generated from
the `templates/page/index.html.eex` file.

## Generating Output

Before turning our attention to building templates, the syntax, and working
with variables and helpers, it's useful to understand what happens between the
initial call to the controller action and producing the final output. You've
likely deduced the high-level flow. It looks something like this:

``` elixir
web_request
|> router
|> controller
|> view
|> template
```

At this height, however, you miss certain details such as where the layout is
set, how the view is determined, and why Phoenix templates are so amazingly
fast. We can answer those first two questions by zooming in on a typical
controller:

``` elixir
# lib/sprawl_app/controllers/page_controller.ex

defmodule SprawlWeb.PageController do
  use SprawlWeb, :controller

  def index(conn, _params) do
    render(conn, :index, name: "Molly")
  end
end
```

In this example controller, notice that the first thing the controller does is
`use` the `controller` function from the `SprawlWeb` module. This module is
generated at the time of project creation and can be found at
`lib/sprawl_web.ex`. If we look at that file, we see we're entering the world of
macros (the `quote` macro gives it away). Don't worry though, we're only going
deep enough to understand the flow:

``` elixir
defmodule SprawlWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: SprawlWeb

      import Plug.Conn
      import SprawlWeb.Gettext
      alias SprawlWeb.Router.Helpers, as: Routes
    end
  end

  ...
end
```

Like our `PageController` above, the first thing the `controller` function does
is `use` another module, `Phoenix.Controller`. Let's take a peek at that:

``` elixir
defmodule Phoenix.Controller do

  ...

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Phoenix.Controller

      # TODO v2: No longer automatically import dependencies
      import Plug.Conn

      use Phoenix.Controller.Pipeline, opts

      plug :put_new_layout, {Phoenix.Controller.__layout__(__MODULE__, opts), :app}
      plug :put_new_view, Phoenix.Controller.__view__(__MODULE__)
    end

  ...

end
```

This module is...less straightforward, but the important part – at least as far
as we're concerned – is the last two lines. The first of those two lines sets
the initial layout to be `app` (i.e. `templates/layouts/app.html.eex`. The
second line sets the view to be one matching the calling Controller's name. Both
lines use the `plug/2` macro, which tells us they're just setting a field in the
`%Plug.Conn{}` struct. It also tells us that we're free to change the layout and
view in the actions we define.

Once our `PageController` has `use`-ed the `Phoenix.Controller` module, it's
finally able to `render` the index action. There are two things that might
surprise you when it comes to what Phoenix does when rendering a template: 1) it
stores the entire HTML document in the `:resp_body` field of the `%Plug.Conn{}`
struct; 2) it stores that HTML document as an IO List, not as a _String_. An IO
List is just "a list of things suitable for input/output operations." We can
get a glimpse of what that looks like by rendering a template with
a View.

Here's an example template:

``` elixir
# lib/sprawl_app/templates/page/index.html.eex

<h1>Hi, <%= @name %></h1>
```

If we render that in the console, it will look something like this:

``` elixir
iex > Phoenix.View.render_to_iodata(SprawlWeb.PageView, "index.html", conn: %Plug.Conn{}, name: "Wintermute")

[[["" | "<h1>Hi, "] | "Wintermute"] | "</h1>\n"]
```

The result is just a nested _List_ (technically an improper list) which Phoenix
sends directly to the I/O stream. Because Phoenix responds in this manner, there
is no need to concatenate the file into one large string, consuming
needless memory. On top of that, handling I/O this way allows the BEAM to use
the same memory address for duplicate strings, further reducing the server's
memory needs:

> ...the function that Phoenix compiles to render that template will use the
> same strings in memory every time, simply adding the dynamic parts as needed
> to the IO list. This is, in effect, a kind of view caching.
>
> [Elixir and IO Lists, Part 2: IO Lists in Phoenix](https://www.bignerdranch.com/blog/elixir-and-io-lists-part-2-io-lists-in-phoenix/)

That's a bit of "why" Phoenix templates can be so much faster and performant
than other frameworks. Now it's time to look at how to build them.

## EEx

By default, Phoenix templates use Elixir's built in templating engine, _EEx_.
EEx stands for "Embedded Elixir" and as you might expect , "it allows you
to embed Elixir Code inside a string." If you are familiar with Ruby's _ERB_
templating system, you'll already be familiar with EEx's syntax. An example HTML
file using the EEx templating system looks like this:

``` elixir
<h1>Users</h1>

<%= link "New User", to: new_user_path(@conn, :index) %>

<ul>
  <%= for user <- @users do %>
    <li><%= user.name %> (<%= user.age %>)</li>
  <% end %>
</ul>
```

There are four different EEx tags, two of which are used above.

### `<% %>`: Inline

Use the inline tag when you need to perform some bit of logic without displaying
the results in the output. Examples might be calculating a result or setting a
variable. More often, however, you'll use the tag to end blocks of code or the
like.

``` elixir
# <% %> example

<% fullname = user.first_name <> " " <> user.last_name %>

Hi, <%= fullname %>!

<%= if true do %>
  Greetings, Program!
<% end %> # <- end
```

### `<%= %>`: Output capture

Unlike the inline tag, the output capture tag displays the output of the
embedded elixir code, doing so even across multiple lines. Unlike Ruby's ERB
syntax, you will use output capture tags with `if`, `case`, and other logic
structures, because these elements are functions which have return values.

``` elixir
# <%= %> example

<%= if true do %>
  this line will be output
<% else %>
  this line never will
<% end %>

<%= case response do %>
  <%= {:ok, response} -> %>
    something worked!

  <%= {:error, :whoops} -> %>
    that didn't work.

  <%= _ -> %>
    I have no idea what happened
<% end %>
```

### `<%# %>`: Comment

The comment tag is used – to no one's great surprise – to add comments. More
often, however, it's used to temporarily comment out code within the template.
Unlike HTML comments `<!-- -->`, EEx comments are never output into the final
product.

``` elixir
# <%# %> example

<%# if true do %>
  this will always be output
<%# else %>
  So will this as long as the "if" is commented out
<%# end %>
```

### `<%% %>`: Quotation

Quotation tags are used when you need to display EEx syntax in the output
without actually processing the code within the tag. An example might be to show
an example of Elixir's EEx template on a webpage. More likely, however, you'll
use HTML's built in character entities.

``` elixir
# <%% %> example

<p>Check out this whizbang elixir code!</p>

<code>
<%% String.reverse("!edoc rixile gnabzihw") %>
</code>
```

## Variables

Templates wouldn't be very useful if there wasn't a way to get data from
_Models_ and _Controllers_ to the _View_ layer. To that end, we can "assign"
values to variables when we render templates in our controllers, views, or even
other templates.

```
# Variable assignment example

# lib/sprawl_web/controllers/page_controller.ex
defmodule SprawlWeb.PageController do
  use SprawlWeb, :controller

  def index(conn, _params) do
    render(conn, :index, name: "Wintermute")
  end
end

# lib/sprawl_web/templates/page/index.html.eex

<h1>Hi, <%= @name %></h1>
```

<aside class="panel panel-default pull-right col-md-5">
<h4>Well actually...</h4>

<p class="small">Although `@name` appears to be a variable with a funny looking
character prepended to it, in actuality the `@` character is a macro that
expands `@name` to `Map.get(assigns, :name)`.</p>

<p class="small">Like most things in Phoenix, the "magic" turns out to be little
more than smoke and mirrors, and barely even that.</p>
</aside>

In this example we are "assigning" the value "Wintermute" to the key `name`. We
are then able to access the `name` variable in our template by prepending the
`@` character to it. In this case, `name` is just a string, but we could just as
easily assign a _List_, _Map_, or a more complex data structure. Furthermore, we
are only assigning a single variable in the example, but multiple values can be
set here as well.

<div class="clearfix"></div>

## Helper functions (Phoenix.HTML)

HTML isn't a complex language. There's no logic, the syntax is simple, and a
person can learn the basics in less than an hour. Why then does Phoenix provide
a handful of tools deemed "Helper functions" to write HTML and aid in the
creation of web pages? There are three primary reasons:

### Helper Functions Simplify Tag Creation

Tags such as `<a>` and `<img>` are used frequently enough in webpages that not
only is it simpler to use a helper function, but their usage makes reading the
HTML easier. Judge for yourself, which do you find easier to read?

``` eex
# Interpolated
<a href="<%= page_path(@conn) %>">Home</a>
<img src="<%= static_path("logo.png") %>">

# Helper function
<%= link "home", to: page_path(@conn) %>
<%= img_tag static_path("logo.png") %>
```

Not only do these helper functions make the code easier to read, but the helper
functions return an IO List which we've already seen is more memory friendly.
It makes sense for `link/2` and `img_tag/2` to be helper functions because it
mitigates string interpolation and the likelihood of mistyping the syntax, but
why have a function like `button/2`?

### Helper Functions Automate Security

Both `button/2` and `link/2` accept a `method:` attribute to define what type of
HTTP call should be made when the user clicks on the respective tag. If that
method is anything other than `get`, these functions include a `data-csrf`
attribute and token in the HTML tag, which hinder CSRF attacks.

Furthermore, when you use any of Phoenix's helper functions, they sanitize
any attributes and content which are set programmatically. This is
especially useful when presenting user-provided data.

``` elixir
# Potentially evil JavaScript
user_data = ~s["><script>alert("Evil script!")</script>]

# l
Phoenix.HTML.Tag.content_tag(:p, user_data)

# outputs to

{:safe,
 [
   60,
   "p",
   [],
   62,
   [
     [
       [
         [
           [[[[[] | "&quot;"] | "&gt;"] | "&lt;"], "script" | "&gt;"],
           "alert(" |
           "&quot;"
         ],
         "Evil script!" |
         "&quot;"
       ],
       ")" |
       "&lt;"
     ],
     "/script" |
     "&gt;"
   ],
   60,
   47,
   "p",
   62
 ]}
```

As you can make out, the potentially damaging script has been neutralized.

### Helper Functions Allow Programmatic HTML Creation

The last reason to use Phoenix's helper functions is to give you the ability to
programmatically create HTML, such as from _View_ functions. In this case, you
want to make sure the generated HTML is safe. Phoenix's helper functions ensure
that it will be.

``` elixir
defmodule PageView do
  def component do
    content_tag(:div,
      content_tag(:p, "The sky above the port was the color of television, tuned to a dead channel."),
    class: "card")
  end
end
```

The output of the above results in the following:

``` elixir
{:safe,
 [
   60,
   "div",
   [[32, "class", 61, 34, "card", 34]],
   62,
   [60, "p", [], 62,
    "The sky above the port was the color of television, tuned to a dead channel.",
    60, 47, "p", 62],
   60,
   47,
   "div",
   62
 ]}
```

Although this is a possible use case, it's not commonly used, nor is it
generally recommended. Instead, it's usually better to render smaller templates,
which I'll discuss in a future article.

## Summary

Every web framework has its own ideas about how templates should behave, and
Phoenix is no different. Where Phoenix differs is in how it outputs
the final results. Rather than relying on concatenating a myriad of strings
together into a final form before sending it off, Phoenix relies on Erlang's
_IO Lists_ to both increase its responsiveness and limit memory usage.

By default Phoenix uses Elixir's built in _EEx_ (Embedded Elixir) library to
handle template compilation. With only a handful of tags and helper functions to
learn, EEx makes working with HTML and other textual file types eminently
approachable to both practiced developers and novices alike.

In the next article, we'll look more closely at how to render smaller templates
within the larger context, the best practices in doing so, and also how to work
with layouts.

## Further Reading

- [EEx Documentation](https://hexdocs.pm/eex/EEx.html)
- [Phoenix Template Documentation](https://hexdocs.pm/phoenix/1.4.0/templates.html)
- [Elixir and IO Lists, Part 1: Building Output Efficiently](https://www.bignerdranch.com/blog/elixir-and-io-lists-part-1-building-output-efficiently/)
- [Elixir and IO Lists, Part 2: IO Lists in Phoenix](https://www.bignerdranch.com/blog/elixir-and-io-lists-part-2-io-lists-in-phoenix/)
