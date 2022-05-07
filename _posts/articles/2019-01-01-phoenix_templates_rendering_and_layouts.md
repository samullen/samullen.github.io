---
title: "Phoenix Templates: Rendering and Layouts"
date: 2019-01-01T11:00:34-06:00
draft: false
description: "In this article we look at how to render templates from within Views, Controllers, and even other Templates. We also look at how to work with Layouts and Nested Layouts."
comments: false
post: true
categories: [phoenix, elixir, templates]
---

In the last article,
[Phoenix Templates](//samuelmullen.com/articles/phoenix-templates/),
we discovered that one of the reasons Phoenix templates are so fast is because
they are transformed into actual functions at compile time. Not only does this
help us create better applications, but thinking about templates as functions
helps us reason about how to build better applications. As you know, functions
accept parameters and produce output in response to those parameters, they can
be called by other functions, and finally functions help reduce complexity.
Templates do the same thing.

In this article, we'll look at the different ways to render templates, how to
render templates from within other templates, best practices for when to do
that, and lastly we'll look at how to work with "layouts".

## Rendering Templates

If templates are a kind of function, then it stands to reason that there must be ways to
both "call" them and pass information to them. In Phoenix we do that with the
`render/n` functions. While the base function resides in the `Phoenix.View`
module, `Phoenix.Controller` has its own version, and of course, templates have
access to the `render/3` function provided by their _View_.

### Rendering: Views

When either _Views_ or _Controllers_ render a template, there are always three
parameters associated with the render: the _View_, the _Template_, and the
"assigns". In both cases, the _View_ will be defined with either the view or
controller is `use`-ed. In cases where you need to render a template in the
scope of an alternate view, you'll need to provide that view as the first
argument to `render/3`.

``` elixir
# Rendering the default view
render("index.html", name: "Wintermute")

# Specifying the View
render(SprawlWeb.PageView, "index.html", name: "Wintermute")
```

Unlike rendering from controllers, templates provided to views must include
the file type as part of the name (e.g. "index.html", "show.json", "list.txt").
Phoenix will pattern match against a `render` function in the view, or
failing that find the matching template located in the directory matching the
view's name. Unless you use an alternative rendering engine, all templates must
also have a `.eex` appended to their filenames in their respective template
directory.

For example, the following code snippet would look for the file `show.json.eex`
in the `lib/sprawl_web/templates/ai/` directory in order to render it:

``` elixir
# Providing the file type in the template
render("show.json", id: 2112, name: "Wintermute")
```

The last parameter is the "assigns" Map. This parameter is what Phoenix
(technically EEx) uses to get variables from the calling function into the
template. When you "assign" values to keys in the assigns Map, they will be
available as variables in the template with the key as then name and with a
prepended `@`.

``` elixir
# View
render("show.html", id: 2112, name: "Wintermute")

# The %{ } is optional
render("show.html", %{id: 2112, name: "Wintermute"})

# Template

<dl>
  <dt>ID<dt>
  <dd><%= @id %></dd>

  <dt>Name<dt>
  <dd><%= @name %></dd>
<dl>
```

### Rendering: Controllers

Rendering from a _Controller_ isn't much different from rendering from a _View_.
The only difference is that the `%Plug.Conn{}` struct plays a significant role.
Because of that, the `conn` variable needs to be provided to the `render/n`
function, and changing the view must be handled with the `put_view/2` function
prior to calling `render`. Other than that, the render format is very similar.

``` elixir
defmodule SprawlWeb.PageController do
  # Provide the `conn`
  def index(conn, _params) do
    render conn, :index, users: list_of_users
  end

  # Change the view
  def show(conn, _params) do
    conn
    |> put_view(SprawlWeb.UserView)
    |> render :show, name: "Maelcum", title: "Pilot"
  end
end
```

**Just a note:** when you render a template from a controller, the controller's
version of render sets the `conn` value in the _assigns_. This isn't done when
rendering from views: you must manually assign the `conn` value yourself.

## Rendering Templates from within Templates

It doesn't take long for a single webpage to become too cumbersome to deal with
as a single file. Certainly some of that comes just from the logic for when,
how, and to whom to display the appropriate blocks and components, but even
displaying raw HTML can make a file to too large and unwieldy to work with
effectively. Even the simplest web application can have several pages that are
too complex to house all the logic in a single file. In cases like this it makes
sense to break up page components into smaller templates to be rendered as
needed. In Phoenix we do this by `render`-ing a template from within the
template we're working with.

> Templates are just function calls, so like regular code, composing your
> greater template by small, purpose-built functions can lead to clearer design.
>
> [Phoenix Templates Documentation](https://hexdocs.pm/phoenix/1.4.0/templates.html)

### Rendering Templates

Rendering templates from within a template is almost exactly like rendering from
a _View_, and you will use either `render/2` or `render/3` to do it: the former
defaults to the current view, while the latter requires specifying the view.
Using these functions from within a template looks like this:

```elixir
<%# Using the default View %>
<%= render "show.html", name: "Case", occupation: "Hacker" %>
<%= render "index.html" %>

<%# Specifying a View %>
<%= render SprawlWeb.SharedView, "sidebar.html", ai_list: ais %>
```

To provide a clearer explanation of the circumstances you might render nested
templates and how that might look, let's look at a simple example. Our example
will provide a table of Artificial Intelligences used in books, and a "shared"
side bar for navigation. Here's our _Controller_:

```elixir
# lib/sprawl_web/controllers/ai_controller.ex

defmodule SprawlWeb.AIController do
  use SprawlWeb, :controller

  def index(conn, _params) do
    ais = [
      %{name: "Wintermute", book: "Neuromancer"},
      %{name: "Neuromancer", book: "Neuromancer"},
      %{name: "R. Daneel Olivaw", book: "Caves of Steel"},
      %{name: "HAL 9000", book: "2001: A Space Odyssey"},
      %{name: "Marvin", book: "Hitchhiker's Guide to the Galaxy"},
    ]

    render conn, :index, ais: ais
  end
end
```

The controller is pretty basic. It has a `List` called "ais" made up of
`Map`s containing the name of the AI and the book where it is found. Next, we
`render` the index and assign the "ais" list.

We'll also need a _View_, but it just has to meet the bare minimum for a view.

```elixir
# lib/sprawl_web/views/ai_view.ex

defmodule SprawlWeb.AIView do
  use SprawlWeb, :view
end
```

Finally, we get to the initial version of the template. In it, we have two
sections: a section to list the AIs, and one to provide navigation.

```elixir
# lib/sprawl_web/templates/ai/index.html.eex

<section class="column-9">
  <table>
    <tr>
      <th>AI Name</th>
      <th>Book</th>
    </tr>

    <%= for ai <- @ais do %>
      <tr>
        <td><%= ai.name %></td>
        <td><%= ai.book %></td>
      </tr>
    <% end %>
  </table>
</section>

<section class="column-3 panel">
  <h3>Navigation</h3>

  <ul>
    <li><%= link "Users", to: "/users" %></li>
    <li><%= link "AIs", to: "/ais" %></li>
    <li><%= link "Books", to: "/books" %></li>
  </ul>
</section>
```

To break this up into smaller templates, we'll extract the AIs table into its
own template file and also do the same for the navigation, and then we'll render
those templates from the original file.

```elixir
# lib/sprawl_web/templates/ai/index.html.eex

<section class="column-9">
  <%= render "ai_table.html", ais: @ais %>
</section>

<section class="column-3 panel">
  <%= render "side_nav.html" %>
</section>

# lib/sprawl_web/templates/ai/ai_table.html.eex
<table>
  <tr>
    <th>AI Name</th>
    <th>Book</th>
  </tr>

  <%= for ai <- @ais do %>
    <tr>
      <td><%= ai.name %></td>
      <td><%= ai.book %></td>
    </tr>
  <% end %>
</table>

# lib/sprawl_web/templates/ai/side_nav.html.eex
<h3>Navigation</h3>

<ul>
  <li><%= link "Users", to: "/users" %></li>
  <li><%= link "AIs", to: "/ais" %></li>
  <li><%= link "Books", to: "/books" %></li>
</ul>
```

We can imagine that there might be more cells in our table and maybe even some
amount of logic for how to display each row. In that case, it might make sense
to even break out each row from the table. Let's do that now:

```elixir
# lib/sprawl_web/templates/ai/ai_table.html.eex
<table>
  <tr>
    <th>AI Name</th>
    <th>Book</th>
  </tr>

  <%= for ai <- @ais do %>
    <%= render "ai_record.html", ai: ai %>
  <% end %>
</table>

# lib/sprawl_web/templates/ai/ai_record.html.eex
<tr>
  <td><%= @ai.name %></td>
  <td><%= @ai.book %></td>
</tr>
```

Finally, we might want to use the side navigation from more than just within
the AIs resource. Let's extract it out to a "shared" _View_.

First, we'll create the view:

```elixir
# lib/sprawl_web/views/shared_view.ex

defmodule SprawlWeb.SharedView do
  use SprawlWeb, :view
end
```

Next, we'll move the template from `lib/sprawl_web/templates/ai` to
`lib/sprawl_web/templates/shared`. Lastly, we'll update the `index.html.eex` to
reflect the new state of our application:

```elixir
# lib/sprawl_web/templates/ai/index.html.eex

<section class="column-9">
  <%= render "ai_table.html", ais: ais %>
</section>

<section class="column-3 panel">
  <%= render SprawlWeb.SharedView, "side_nav.html" %>
</section>
```

Now that we know _how_ to break up templates into smaller "sub" templates, let's
examine _why_ and _when_ we might want to do that.

### When Should You Extract Templates?

What follows are four reasons for _when_ and _why_ you will want to break up a
template into smaller component templates. These are not four _rules_. There are
no right or wrong times to do this. My advice to you is to not break up a
template immediately, but rather wait until working with a template causes some
sort of pain for you. That will differ between applications and between
developers.

With that disclaimer out of the way, here are the four reasons you will want
to extract templates.

**1. To Share Templates**

There will always be components that need to be shown in more than one place.
Navigation, top-n lists, and summary charts are just a few of the many types of
components you will display on multiple pages. Extract these "sharable" blocks
out into their own templates and simplify your project. Sometimes it will make
sense to extract these into a "shared" resource, but many times you will just
leave them where they are and access them through the current _View_.

**2. To Improve Readability**

HTML is a verbose language and tends toward deeply nested elements. Because of
this, template files quickly become bloated and unwieldy. Breaking up templates
into smaller, composable units is a simple and elegant way to improve the
readability of the template you're editing. Breaking out a larger template into
smaller, well-named blocks of HTML is an easy way to reign in an unruly webpage.

You don't need to _see_ the contents of the header, navigation bar, and footer,
you just need to know they're there. Break those components out into their own
files and focus on the content that matters.

**3. To Encapsulate (i.e. Hide) Logic**

Templates are just functions, and as Uncle Bob states in [_Clean
Code_](https://www.goodreads.com/book/show/3735293-clean-code), "The reason we
write functions is to decompose a larger concept into a set of steps at the next
level of abstraction." When you have large areas of complicated logic in your
templates, break those out into templates of their own to better see the flow of
logic. This has two benefits: 1) it makes the original file easier to read; 2)
it isolates the logic in its own location to make it easier to grapple with in a
confined space.

**4. To Simplify Responsibility**

If templates are functions, then we should treat them the same way we would
treat functions in a module and limit it to a single responsibility.

> Functions should do one thing. They should do it well. They should do it only.
>
> -- Uncle Bob, [_Clean Code_](https://www.goodreads.com/book/show/3735293-clean-code)

Be warned, this can be taken to far. Remember what I said at the beginning of
this section about when to break out templates: "...wait until working with a
template causes some sort of pain..."

## Layouts

The [Phoenix documentation](https://hexdocs.pm/phoenix/1.4.0/templates.html)
tells us that "Layouts are templates into which regular templates are rendered."
On one hand this tells us almost nothing because there is no difference between
a layout and a template. On the other hand, it tells us a great deal: layouts
are just templates and we can work with them in the same way as any other
template.

For the uninitiated, a layout is merely a wrapper or container template for the
majority of the pages your application renders. Oftentimes this file will
contain the opening and closing `html` tag, the `head` section, the opening and
closing `body` tag, maybe navigation areas such as the primary nav and footer,
and any other component which will be common across most, if not all, pages.
You'll keep your layouts – and similarly-used templates – in the
`lib/app_web/templates/layout/` directory.

A typical layout looks like this, (in fact this is what Phoenix starts you off
with):

```elixir
# lib/sprawl_web/templates/layout/app.html.eex

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Sprawl · Phoenix Framework</title>
    <link rel="stylesheet" href="<%= Routes.static_path(@conn, "/css/app.css") %>"/>
  </head>

  <body>
    <header>
      <section class="container">
        <nav role="navigation">
          <ul>
            <li><a href="https://hexdocs.pm/phoenix/overview.html">Get Started</a></li>
          </ul>
        </nav>

        <a href="http://phoenixframework.org/" class="phx-logo">
          <img src="<%= Routes.static_path(@conn, "/images/phoenix.png") %>" alt="Phoenix Framework Logo"/>
        </a>
      </section>
    </header>

    <main role="main" class="container">
      <p class="alert alert-info" role="alert"><%= get_flash(@conn, :info) %></p>
      <p class="alert alert-danger" role="alert"><%= get_flash(@conn, :error) %></p>
      <%= render @view_module, @view_template, assigns %>
    </main>

    <script type="text/javascript" src="<%= Routes.static_path(@conn, "/js/app.js") %>"></script>
  </body>
</html>
```

You may have noticed in your own Phoenix project that the layout doesn't appear
to get set anywhere. It's not defined in a config file, the `Endpoint`, or even
in the controller or view. As discussed in the last article, the layout is set
when you `use` the `controller` function for your app. We also saw that the
layout is just an attribute applied to the `%Plug.Conn{}` struct, so it's a
simple matter to override it for those resources that need a different layout.
To change which layout in your controller action, use the
`Phoenix.Controller.put_layout/2` function.

```elixir
defmodule SprawlWeb.Admin.UserController do
  use SprawlWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout({AdminView, "admin.html"})
    |> render :index
  end
end
```

**Note:** `put_layout/2` requires both the template _and_ the view as a tuple.

### Nested Layouts

You will find that at different places in your application you need to render
things just a bit differently from the main layout. It could be a change in
navigation that is only visible in one resource, or maybe CSS or JavaScript
that is specific to a page. When this occurs, you might be tempted to create
yet another branch of logic to handle it, but in these cases Phoenix provides an
alternative solution: `render_existing/3`.

`Phoenix.view.render_existing/3` "renders a template only if it exists" and is
"Useful for dynamically rendering templates in the layout that may or may not be
implemented by the `@view_module` view."

Consider the case of adding JavaScript specific to a page. You could add
a check in the main `app.js` file which looks for a specific element to
determine if the JS should fire, but what I've found to be the simplest solution
– and the one which is used as an example in the Phoenix docs – is to add the
following line to the `lib/app_web/templates/layout/app.html.eex` file:

``` elixir
    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>

    <%= render_existing @view_module, "scripts.html", assigns %>
    <%# ^^^ add this line ^^^ %>
  </body>
</html>
```

By adding the `render_existing` line we inform the layout that it should render
the `scripts.html.eex` file under the current _View_ context, but only if that
file is there or if the _View_ can handle rendering it.

## Summary

Knowing Phoenix templates are compiled into functions not only explains why
they perform so well, but it also provides us with a useful framework by which
to think about web development. Since rendering templates is – mostly – the same
whether they are rendered from the _View_, _Controller_, and even from within
other templates, (including layouts) we can focus more on how to best to
organize the templates into functional components.

In the next article, we'll focus on forms in Phoenix: how to build them, using
Phoenix's built-in helpers, and working with nested forms.

## References

- [Phoenix Templates](//samuelmullen.com/articles/phoenix-templates/)
- [Phoenix Documentation: Templates](https://hexdocs.pm/phoenix/1.4.0/templates.html)
