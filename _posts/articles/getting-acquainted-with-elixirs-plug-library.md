---
title: Getting Acquainted With Elixir's Plug Library
date: 2018-11-19T15:30:23-06:00
draft: false
description: "At first glance, web development seems overwhelmingly complex. Elixir's Plug library's simplicity reveals just how simple the web really is."
comments: false
post: true
categories: [elixir, plug, web\_development]
---

It's easy to get lost in the enormity of the Internet. As web developers, we
know (or at least think we do) better than anyone the complexity not only of
the applications we create, but also of the systems, standards, protocols, and
technology stacks that support it. We get caught up thinking about what our
application must do to handle any given request – the HTML and CSS, how the
JavaScript should behave, interacting with the backend database, caching, and
more – that we forget about how simple both the web request and response
actually are.

There is no better way to see how simple this interaction is than by looking at
Elixir's Plug library.

> Think of the Plug library as a specification for building applications that
> connect to the web. Each plug consumes and produces a common data structure
> called `Plug.Conn`. Remember, that struct represents _the whole universe for a
> given request_, because it has things that web applications need: the inbound
> request, the protocol, the parsed parameters, and so on.
>
> – Chris McCord, _Programming Phoenix_

With the Plug library, web requests are handled very much like an assembly line,
with each "station" in the line being a "plug". When a request is received, an
initial `%Plug.Conn{}` struct (called a connection) is created and is sent down
the line. As the `%Plug.Conn{}` struct passes through each plug, it is built up
and refined until it's finally ready be sent back to the requester.

## Plug 'n Play

To see just how simple it is to work with plugs, let's create a sandbox app.
This will allow us to see exactly what's going on in each step of a assembly
line and also provide you with a place to experiment.

First, start by creating a new supervised app:

``` unix
$ mix new sandbox --sup
```

Next, we need to add a plug library that interacts with an HTTP server. For our
purposes, the Cowboy plug, `plug_cowboy` is an easy choice. Go ahead and add
that to the `deps` function in the `mix.exs` file of the project.

``` elixir
# mix.exs

def deps do
  [
    {:plug_cowboy, "~> 2.0"}
  ]
end
```

`plug_cowboy` runs in its own supervised process, so we'll want to ensure it's
included in our applications list of dependencies by adding it to the
`application` function in our `mix.exs` file.

``` elixir
# mix.exs

def application do
  [
    extra_applications: [
      :plug_cowboy
    ]
  ]
end
```

With `plug_cowboy` added to our project, we just need to download and install
the package. You know what to do:

``` unix
$ mix deps.get
```

With the preliminary setup steps out of the way, we can now focus on building
our first plug. When finished, we'll be able to visit `http://localhost:4000`
and see the results of our work.

Open up a new file named `sandbox_plug.ex` under the `lib/sandbox` directory in
your project and add the following contents:

``` elixir
# lib/sandbox/sandbox_plug.ex

defmodule SandboxPlug do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> resp(200, "Hello, World!")
    |> send_resp()
  end
end
```

Once you've saved the file, open up a new IEx session within the project:

``` unix
$ iex -S mix
```

At the IEx prompt, enter the following command to start up a new Cowboy server
which will use our newly created `SandboxPlug` to handle requests:

``` elixir
{:ok, _} = Plug.Cowboy.http SandboxPlug, []
```

If you've done everything correctly, you can now visit `http://localhost:4000`
and see the results of your work. It will look like this:

<img src="//samuelmullen.com/images/getting_acquianted_with_elixirs_plug_library/hello_world.png" class="img-thumbnail img-responsive img-right" alt="Screenshot of Hello, World!" title="Screenshot of Hello, World!">

## The `%Plug.Conn{}` Struct

<aside class="panel panel-default pull-right col-md-5">
<h3>Well actually...</h3>
<p>Because Elixir is a (mostly) functional language, the connection struct
isn't "modified", but rather each function in the pipeline returns a copy of the
struct with the modifications.</p>
</aside>

`SandboxPlug` is an example of a "module plug", (discussed in more detail
below). In the `call/2` function, a `%Plug.Conn{}` struct is taken as an
argument and then passed through a series of functions. At each step, the
connection struct is provided as the first argument and modified slightly as
it passes through each function of the pipeline. You can see this in action by
tweaking the `call/2` function to inspect the struct after each function:

<div class="clearfix"></div>

``` elixir
  def call(conn, _opts) do
    conn
    |> IO.inspect
    |> put_resp_content_type("text/plain")
    |> IO.inspect
    |> resp(200, "Hello, World!")
    |> IO.inspect
    |> send_resp()
    |> IO.inspect
  end
```

As you can see, after the `put_resp_content_type/3` function is called, the
`%Plug.Conn{}` struct now has the following line added to its `resp_headers:`
list:

``` elixir
{"content-type", "text/plain; charset=utf-8"}
```

When the `resp/3` function returns, it has added "200" to the `status:` field,
added "Hello, World!" to the `resp_body:` field, and changed the `state:` field
to `:set`.

With the state ready to by sent, we finally call `send_resp/1`, which sends
the response and again modifies the `%Plug.Conn{}` struct, setting the `state:`
to `:sent` and the `resp_body:` to `nil`.

> ...keep in mind that a connection is a direct interface to the
> underlying web server. When you call `send_resp/3` above, it will immediately
> send the given status and body back to the client. This makes features like
> streaming a breeze to work with.
>
> – [Plug Documentation](http://hexdocs.pm/plug/)

The idea of starting with a struct – a token if you will – and modifying it as
it is passed through a series of functions is an emerging pattern in the Elixir
community, and one which is quickly gaining traction. If you'd like to learn
more about this pattern, I highly recommend watching René Föhring's talk from
Elixir 2018, [Architecting Flow in Elixir From Leveraging Pipes...](https://www.youtube.com/watch?v=ycpNi701aCs).

## Plug Types

As mentioned previously, there are two types of plugs: _function plugs_ and
_module plugs_. We will discuss each type here and where and how they are most
commonly used.

### Function Plugs

As its name implies, a _function plug_ is a function that manipulates the
`%Plug.Conn{}` struct. Like all plugs, it takes connection object as its first
argument, a set of "options' as its second argument, and provides a connection
as its return value. In general, function plugs are used within the module in
which they are defined.

Let's modify the `SandboxPlug` to see how function plugs work:

``` elixir
# lib/sandbox/sandbox_plug.ex

defmodule SandboxPlug do
  use Plug.Builder

  plug :set_header
  plug :set_content_type
  plug :add_content
  plug :respond

  def set_header(conn, _opts) do
    put_resp_header(conn, "x-token", "$up3r$3cr3770k3n")
  end

  def set_content_type(conn, opts) do
    put_resp_content_type(conn, "text/plain")
  end

  def add_content(conn, _opts) do
    resp(conn, 200, "Hello, World!")
  end

  def respond(conn, _opts) do
    send_resp(conn)
  end
end
```

If we restart our IEx session, start up our plug, and reload
`http://localhost:4000`, we'll see the same output as before; this time with
the addition of the `x-token` header:

``` unix
$ curl -i localhost:4000
HTTP/1.1 200 OK
cache-control: max-age=0, private, must-revalidate
content-length: 13
content-type: text/plain; charset=utf-8
date: Mon, 12 Nov 2018 16:11:55 GMT
server: Cowboy
x-token: $up3r$3cr3770k3n

Hello, World!
```

### Module Plugs

Module plugs are used when you want to share a plug in more than one module.
We've already seen an example of a _module plug_ in our first iteration of
`SandboxPlug`. As we saw that example, a module must implement both the
`init/1` and `call/2` functions in order to fulfill the Plug specification.
Although not required, it's useful to `include` the `Plug.Conn` module to 1)
ensure you've accurate implemented the behavior, and 2) have easy access to all
the `Plug.Conn` functions.

The `init/1` function is used to pattern match against and transform options
which are passed in to the plug. The return value is then passed on as the
second argument to `call/2`. As you might imagine, this functionality can be
used to sanitize or set default options, provide alternate logic paths, and
more. For example, an authorization plug might accept `authorized: true` to
allow all users to access a certain page, while not providing the options might
default to its normal behavior.

## Routing

If you played around much with the `SandboxPlug` we wrote, you'll have noticed
that regardless of the path you visit, you always receive the same pleasant
output: "Hello, World!". Go ahead, try going to
`http://localhost:4000/foo/bar/baz`.  Entertaining as that may be, it's not
terribly useful. Ideally, we would like to provide more utility to our users.
That's where `Plug.Router` comes in.

`Plug.Router` provides us with a DSL to define routes by which we can direct
our app's traffic. Let's see how this works by refactoring our app to use
routes. Create the file `lib/sandboxy/router.ex` and add the following content:

``` elixir
# lib/sandbox/router.ex 

defmodule Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/", to: SandboxPlug

  get "/hi" do
    send_resp(conn, 200, "Hi, World!")
  end

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
```

Go ahead and restart your IEx session and start the Cowboy server using `Router`
instead of `SandboxPlug`.

``` elixir
{:ok, pid} = Plug.Cowboy.http Router, []
```

Now when we visit `http://localhost:4000/` we'll still see the expected "Hello,
World!" output, but we're also handling `/hi` by responding with "Hi, World!",
and returning a 404 for everything else. Let's examine our new `Router` more
closely.

On the second line of the module, we're bringing in the `Plug.Router` which
provides us with a nice assortment of macros we can use in our `Router`. It also
brings in `Plug.Builder` which allows us to create a "plug pipeline". With the
exception of `forward/2`, all the macros brought in allow us to "match" against
the HTTP request methods: `get/3` matches `GET` requests, `post/3` matches
`POST` requests, and so on.

Next, notice we're calling two plugs, `:match` and then `:dispatch`:

> `match` is responsible for finding a matching route which is then forwarded to
> `dispatch`. This means users can easily hook into the router mechanism and add
> behaviour before match, before `dispatch` or after both.
>
> [Plug.Router](https://hexdocs.pm/plug/1.7.1/Plug.Router.html)

The last section of our `Router` module is dedicated to defining our routes.
Here we've defined two routes which will only match `GET` requests, and a
catch-all route which will respond with a 404 HTTP status and a short message
for every other path a user attempts to go to.

### Pipelines

As you've already begun to see, the power of the Plug library is in its
pipelines. From the initial request to the final response, the connection object
is built up incrementally as it passes through each plug. Because each step in
the process is orthogonal to the others, it allows us to easily inject new
functionality or redirect the flow of the pipeline at any point in the process.

It's the `Plug.Builder` module which allows us to build these pipelines. When
`use`-d in a module, we get all the power of `Plug.Conn` and also have access to
the `plug/2` macro. As we already saw in our `Router` module, plug macros are
used to execute plugs in the order they're listed.

Lets tweak our `SandboxPlug` module to `use Plug.Builder` to incorporate the
`Plug.Logger` module plug and an imaginary `Authentication` module plug.

``` elixir
# lib/sandbox/sandbox_plug.ex

defmodule SandboxPlug do
  use Plug.Builder

  plug Plug.Logger
  plug Sandbox.Authentication

  def init(options), do: options

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("text/plain")
    |> resp(200, "Hello, World!")
    |> send_resp()
  end
end
```

If we were to visit `http://localhost:4000` again – and if
`Sandbox.Authentication` were an actual thing – we would see that the request
shows up in the logging output, and if we were authenticated we would see the
expected results. If not, maybe we would be redirected to a sign in page.

### Forwarding

As it stands, our `Router` is very simple. Requests come in, progress neatly
through each of the plugs, and then out the other end depending on the route
they hit. This is all well and good for an example app, but what if we have
routes that require authentication, other routes that don't, and still other
routes that are only going to deal with API requests? With each plug we write,
we could include all the necessary plugs required, but that is repetitive and
prone to error. What if we could group routes by pipeline? By using the
`forward/2` macro provided by `Plug.Router`, we can do just that!

Let's look at an example:

``` elixir
# lib/sandbox/router.ex

defmodule Router do
  use Plug.Router

  plug :match
  plug :dispatch

  forward "/admin", to: AuthorizedRouter
  forward "/api", to: ApiRouter
  forward "/", to: SandboxPlug

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end

# lib/sandbox/api_router.ex

defmodule APIRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/secret" do
    send_resp(conn, 200, "{backdoor: 'reindeer flotilla'}")
  end

  get "/open" do
    send_resp(conn, 200, "{frontdoor: 'Now that is a big door'}")
  end

  match _ do
    send_resp(conn, 404, "{error: 'No route round', status: 404}")
  end
end

# lib/sandboxy/authorized_router.ex

defmodule AuthorizedRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/authorized" do
    send_resp(conn, 200, "Greetings, Program!")
  end

  get "/unauthorized" do
    send_resp(conn, 403, "End of line")
  end

  match _ do
    send_resp(conn, 404, "No authorized route")
  end
end
```

There are a handful of things to notice about our example. To start, notice the
order of the `forward`s. Like the `plug` macro, order matters. If we listed the
`forward "/", to: SandboxPlug` line before the other forwarded routes,
`SandboxPlug` would receive every request. Nothing would ever get past `/`.

The next thing to notice is that both the `AuthorizedRouter` and the `APIRouter`
have their own catch-all route. Contrary to what I had expected, forwarded
routes will not fall back to the calling module for the catch-all route.

With our existing setup, our routes now look like this:

``` elixir
/
/admin/authorized
/admin/unauthorized
/api/secret
/api/open

# any other route is met with a 404 of some sort
```

## Testing

The last thing to look at is how to test our plugs. Unlike integration
testing in other languages or frameworks, testing Plug modules and routers
is more akin to unit testing than integration testing. Why is that? Again, all
the Plug library does is manipulate the `%Plug.Conn{}` struct as it passes
through each plug. Because of that, our tests merely need to ascertain the
result of the connection as it passes through each plug. No web server required!

``` elixir
test/lib/sandbox/sandbox_plug_test.exs

defmodule SandboxPlugTest do
  use ExUnit.Case, async: true
  use Plug.Test

  test "returns hello world" do
    options = SandboxPlug.init([])

    conn =
      conn(:get, "/hello")
      |> SandboxPlug.call(options)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Hello, World!"
  end
end
```

The first requirement of writing Plug tests is to `use Plug.Test`. This imports
all the functions from `Plug.Test` as well as those from the `Plug.Conn` module.
The most important of these functions is the `conn/3` function which "creates a
test connection" against which we can test. With that test connection, we call
out to our plug and then test against the response.

## Summary

For all the sound and fury the web seems to offer, loading websites boils
down to making a request and receiving a rather basic response. This is seen in
fewer places more clearly than in the Plug library for Elixir. With Plug,
as requests are received, they are passed through a pipeline of plugs, each
modifying the eventual result, until it finally reaches the end of the pipeline
and is able to be sent back to the requester.

Plugs come in two types: _function plugs_ which are primarily used with the
defining module; and _module plugs_ which are designed to be included in other
modules. When used with `Plug.Router`, plugs allow you to easily create and
manage vast paths of logic to handle any request your users may have.
