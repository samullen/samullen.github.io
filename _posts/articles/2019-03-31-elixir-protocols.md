---
title: Elixir Protocols
date: 2019-03-31T17:02:18-05:00
draft: false
description: "A look into what Elixir protocols are, why we should use them, how to implement a protocol on a struct or type, and finally how to create our own."
comments: false
post: true
categories: [elixir, programming]
---

> **Uncle Owen:** I suppose you're programmed for etiquette and protocol.  
> **C-3PO:** Protocol? It's my primary function, sir. I am well-versed in all the customs...  
> **Uncle Owen:** I have no need for a protocol droid.  
>
> – Star Wars

For many Elixir developers, protocols evince in us the same response and
attitude as Uncle Owen gives C-3PO in the exchange above. We've read about
protocols, we kind of understand what they are and how they're used, but we've
never explored them beyond the surface, because we're more focused on getting
work done. There's another name for the word, "surface": "boundary". A boundary
is something which stops us, limits us, or holds us back.

My guess is you're not someone who likes boundaries, and I bet it bothers you
knowing that protocols are an area in Elixir you don't have nailed down yet.
We're going to change that. By the end of this article, you'll understand what
protocols are, why you should be using them, how to implement them, and finally,
how to create your own.

## What Are Elixir Protocols?

The [Elixir Guides](https://elixir-lang.org/getting-started/protocols.html) tell
us that, "Protocols are a mechanism to achieve polymorphism in Elixir." While
accurate, the definition seems to have been written by and for someone who
already knows what they are. What the definition means is that by implementing
functions specific to a protocol, we make sure our structs and built-in data
types can take advantage of everything the implemented library has to offer.

Think of it like this, imagine you've developed a new type of fastener for
joining pieces of wood. If you implement the `StandardWrench` protocol for your
fastener, then you will be able to use standard wrenches and sockets with your
new fastener to attach or take apart the wooden objects. If you don't implement
any protocols, then you will need to build your own tools to work with the
fastener. In effect, protocols allow us to take advantage of entire toolsets
merely by implementing one or more required functions.

We can see how this works in more detail by implementing the `Inspect` protocol
in an example:

```elixir
defmodule Droid do
  defstruct designation: nil, maker: nil, owner: nil, duties: []
end

defimpl Inspect, for: Droid do
  def inspect(droid, _opts) do
    """
    Droid Specification:
      Designation: #{droid.designation}
      Maker: #{droid.maker}
      Current Owner: #{droid.owner}
      Duties: #{Enum.join(droid.duties, ", ")}
    """
  end
end
```

In this example, we are creating a new struct called, `Droid`, and then
implement the `Inspect` protocol for it. In so doing, we alter the how `Droid`
responds to functions such as `Kernel.inspect/2`, `IO.inspect/2`. In this case,
it now prints out the details of a `%Droid{}` in a nicely formatted manner.

```elixir
iex> %Droid{designation: "C-3PO", maker: "Anakin Skywalker", owner: "Luke Skywalker", duties: ["Etiquette", "Protocol"] }
Droid Specification:
  Designation: C-3PO
  Maker: Anakin Skywalker
  Current Owner: Luke Skywalker
  Duties: Etiquette, Protocol

iex>
```

The above example serves as a good introduction and how-to for implementing
protocols in your own projects. Setting it aside for the moment, let's turn our
attention to why we should use protocols.

## 3 Reasons You Should Use Protocols

You've read this far into the article, which suggests you believe you should
be using protocols. Aside from that, what other reasons are there to take
advantage of this feature of Elixir?

### Reason 1: Protocols are in your toolbox

Imagine a mechanic who refused to use a pneumatic drill, or a tailor who didn't
want to use a sewing machine. Sure they can still get their work done with a
tire iron or needle and thread, but are they as productive as they could be?

What about this? What would you think of a woodworker who had her shop filled
with every tool she could ever need, but didn't know how to use a 10% of
them? You'd probably doubt her competence.

What then does it say about us when we don't bother to understand all the tools
in our programming toolbox? For that matter, why would we want to limit
ourselves to just part of the Elixir toolset?

### Reason 2: Protocols are powerups for your modules

I mentioned this earlier, but it bears repeating: protocols allow us to take
advantage of toolsets merely by implementing one or more required
functions. How's that for an ROI? By implementing at most 5 functions, you get
easier access to the `Enum` module _and_ it eliminates countless anonymous
functions you would otherwise need to write.

Notice, because you're abstracting that logic out into an implementation, it
also makes your code easier to read and understand, providing an "elegant weapon
for a more civilized age."

### Reason 3: Protocols simplify the lives of your library users

We are not limited to only those protocols provided in the standard library. On
the contrary, we can create protocols for our own libraries. By doing so, it
gives your users an easy way to take full advantage of everything your library
has to offer. Let's look at an example.

The authorization library, [`canada`](https://github.com/jarednorman/canada)
provides a simple solution for role-based authorization. What makes it so
simple? All you have to do is implement one function: `can?`.

Here's an example of a basic `User` implementation:

```elixir
defimpl Canada.Can, for: Droids.User do
  alias Droids.User

  def can?(%User{role: "admin"}, _action, _resource), do: true

  # Active users
  def can?(%User{role: "active"}, :read, :report), do: true
  def can?(%User{role: "active", id: id}, _action, %Droid{user_id: user_id}) do
    id == user_id
  end
  def can?(%User{role: "active"}, :read, %Droid{public: true}), do: true
  def can?(%User{role: "active"}, :read, %Droid{}), do: false

  def can?(%User{role: "active"}, _action, _resource), do: false
end
```

Just by implementing this one function for `%Droids.User` struct, we now have
complete control over what our users have access to.

## Elixir's Built In Protocols

Having seen an initial example of implementing a protocol and some reasons for
why we should take advantage of them, let's take a closer look at what we have
to work with from the Elixir standard library.

### Collectable

One of my favorite functions in Elixir is `Enum.into/2`. It enables you do
transform one enumerable into another with zero effort. Check this out:

```elixir
iex> Enum.into([a: 1, b: 2], %{})
%{a: 1, b: 2}

iex> Enum.into(%{a: 1}, %{b: 2})
%{a: 1, b: 2}

iex> Enum.into([a: 1, a: 2], %{})
%{a: 2}
```

Wouldn't it be great to take advantage of that in your own modules? You can by
implementing `Collectable.into/1` in your modules. We'll see an example of how
to do this later in the article.

### Enumerable

If you've used Elixir, you know the `Enum` module. For the low, low price of
implementing one to four of the Enumerable protocol's functions, you get full
access to not just `Enum`, but `Stream` too! How's that for a bargain.

### IEx.Info

This protocol will be useful for developers who understand that some of us love
working in IEx. By implementing this protocol, you add information to what's
already provided by the `i` command in IEx.

```elixir
iex> i "foo"
Term
  "foo"
Data type
  BitString
Byte size
  3
Description
  This is a string: a UTF-8 encoded binary. It's printed surrounded by
  "double quotes" because all UTF-8 encoded codepoints in it are printable.
Raw representation
  <<102, 111, 111>>
Reference modules
  String, :binary
Implemented protocols
  Collectable, IEx.Info, Inspect, List.Chars, String.Chars
```

Unfortunately, there's no documentation on how to implement this protocol, but
looking in the elixir-lang's code, you can see all we need to do is return a
list of tuples from `IEx.Info.info/1`. When we do this, we expand on what's
provided by default.

```elixir
defimpl IEx.Info, for: Droid do
  def info(droid) do
    [
      {"Duties", Enum.join(droid.duties, ", ")}
    ]
  end
end
```

In IEx
```elixir
iex> droid = %Droid{designation: "C-3PO", maker: "Anakin Skywalker", owner: "Luke Skywalker", duties: ["Etiquette", "Protocol"] }

...

iex> i droid
Term
  Droid Specification:
    Designation: C-3PO
    Maker: Anakin Skywalker
    Current Owner: Luke Skywalker
    Duties: Etiquette, Protocol
Duties
  Etiquette, Protocol
Implemented protocols
  IEx.Info, Inspect
```

### Inspect

As we've already seen, implementing the `Inspect` protocol allows us greater
control over how or structs are displayed in both `Kernel.inspect/2` and
`IO.inspect/2`.

### List.Chars

I have yet to use charlists for anything outside of programming exercises,
(which probably means I should write an article about them). But just because
I've never had a need for them doesn't mean you don't. If you would like to use
`Kernel.to_charlist/1` with your structs, you'll need to implement
`List.Chars.to_charlist/1`.

### String.Chars

When you implement the `String.Chars` protocol for your structs, you define how
you want your structs to be displayed when passed as an argument to
`Kernel.to_string/1`. Elixir's own `URI` library implements `String.Char` to
transform a `%URI{}` to a string.

```elixir
iex> %URI{
  authority: "samuelmullen.com",
  fragment: nil,
  host: "samuelmullen.com",
  path: "/articles",
  port: 443,
  query: nil,
  scheme: "https",
  userinfo: nil
}
|> to_string
"https://samuelmullen.com/articles"
```

## Implementing Protocols

When we talk about "implementing" a protocol, we don't mean we are creating a
new protocol, but rather taking advantage of an existing protocol. We use the
word "implement", because that's the macro (`defimpl/3`) used to state that our
struct is using the protocol.

```elixir
defimpl Inspect, for: Droid do
  ...
end
```

This statement says that we are implementing the `Inspect` protocol for our
`Droid` struct. Behind the scenes, it's adding `Droid` and the function
defined within the `do` block to the `Inspect` module.

```elixir
iex> Inspect.Droid.inspect(%Droid{}, [])

"Droid Specification:\n  Designation: \n  Maker: \n  Current Owner: \n  Duties: \n"
```

Let's look at an example of implementing the `Collectable` protocol – remember,
implementing the `Collectable` protocol allows us to take advantage of
`Enum.into/2`. Since we've already defined a `%Droid{}` struct, it makes sense
that we would want to collect our droids somewhere. How about in a Jawa's
sandcrawler?

The first thing to do is define the `Sandcrawler`. We'll kept it as simple as
possible to avoid distracting from what's important:

```elixir
defmodule Sandcrawler do
  defstruct droids: []
end
```

In the same file, we'll add our `Collectable` implementation:

```elxir
defimpl Collectable, for: Sandcrawler do
  def into(droids) do
    collector_fun = fn
      sandcrawler, {:cont, elem} ->
        sandcrawler
        |> Map.put(:droids, [elem|sandcrawler.droids])

      sandcrawler, :done ->
        sandcrawler

      _sandcrawler, :halt ->
        :ok
    end

    {droids, collector_fun}
  end
end
```

Before explaining what's going on here, let's first see how we would use this:

```elixir
iex> droids = [
  %Droid{designation: "C-3PO", maker: "Anakin Skywalker", owner: "Luke Skywalker"},
  %Droid{designation: "R2-D2", maker: "Unknown" , owner: "Luke Skywalker"}
]

iex> Enum.into(droids, %Sandcrawler{})

%Sandcrawler{
  droids: [
    %Droid{
      designation: "R2-D2",
      duties: [],
      maker: "Unknown",
      owner: "Luke Skywalker"
    },
    %Droid{
      designation: "C-3PO",
      duties: [],
      maker: "Anakin Skywalker",
      owner: "Luke Skywalker"
    }
  ]
}
```

Looking back at our implementation, we see it's returning a tuple of two
elements: the original list and a collector function. On each iteration of the
enumerable (i.e. the list of droids), the caller passes the "collector function"
two arguments: an accumulator and one of three "commands".

- `:cont` :: Runs the collectable function and informs the caller that there are
  more items to process.
- `:done` :: Iteration is complete
- `:halt` :: Something bad has happened and you probably need to debug it.

Notice in our implementation we are returning a `%Sandcrawler}` rather than
an `Enumerable`. In order to pass a `%Sandcrawler{}` to an `Enumerable`
function, however, we would need to also implement the necessary `Enumerable`
functions.  This is a great opportunity to experiment with what you've learned
so far.

## Creating Your Own Protocol

While only providing six protocols, the standard library covers most use cases
developers will to run into. Still, as you explore protocols you will become
aware of opportunities to create your own. Thankfully, creating your own
protocol couldn't be simpler.

To demonstrate how to do this, we'll create a new protocol named `Emptiness`
which will by used to show if a type or struct is "empty".

```elixir
defprotocol Emptiness do
  @doc "Returns a boolean value based on the 'emptiness' of the term"
  @spec empty?(term) :: boolean()
  def empty?(t)
end
```

That's all there is to it. It would be even simpler if we didn't include the
`@doc` and `@spec` lines, but many structs and types will use the protocols you
create and you should ensure they are documented and provide the expected inputs
and outputs.

Notice that creating a protocol doesn't add any logic, it's just a method
signature.

With the new protocol defined, we can implement it in our modules:

```elixir
defimpl Emptiness, for: Droid do
  def empty?(droid) do
    is_nil(droid.designation) &&
      is_nil(droid.maker) &&
      is_nil(droid.owner) &&
      Enum.empty?(droid.duties)
  end
end

defimpl Emptiness, for: Sandcrawler do
  def empty?(sandcrawler) do
    Enum.empty?(sandcrawler.droids)
  end
end
```

And here's how we might use it:

```elixir
iex> %Droid{} |> Emptiness.empty?
true

iex> droid = %Droid{designation: "R2-D2} |> Emptiness.empty?
false

iex> %Sandcrawler{} |> Emptiness.empty?
true

iex> %Sandcrawler{droids: [%Droid{designation: "R2-D2"}]} |> Emptiness.empty?
false
```

As alluded to already, protocols are not limited to structs you develop. You can
implement them for built in types as well.

> you can place a protocol's implementation completely outside the module. This
> means you can extend modules' functionality without having to add code to
> them–in fact, you can extend the functionality even if you don't have the
> modules' source code."
>
> – Dave Thomas, _Programming Elixir_

This means "it's possible to implement protocols for all Elixir data types:"
(The Elixir Guides), not just those we create. Here's how we would implement
`Emptiness` for strings:

```elixir
defimpl Emptiness, for: BitString do
  def empty?(string) do
    byte_size(string) == 0
  end
end
```

When you create your own protocols, consider also which types and structs should
implement it. For instance, enumerable types like `List`, `Map`, and `MapSet`
are a perfect use cases for the `Emptiness` protocol, while other types, such as
`Integer` or `Atom`, will make less sense. In these latter cases, you have a
couple choices: allow the type to "error out", or create a "catch-all"
implementation.

If you decide your protocol should be able to handle any type or struct, create
an implementation on the `Any` type like this:

```elixir
defimpl Emptiness, for: Any do
  def empty?(_), do: "¯\_(ツ)_/¯" # <- KCElixir members will understand
end
```

With this implementation, any struct or type passed to the `Emptiness.empty?/1`
function will at least return something, even if it's just a shrug.

## Don't be Like Uncle Owen

In the movie, _Star Wars_, Uncle Owen is depicted as a man of the earth (or
rather, Tatooine), focused on the job at hand, with little curiosity or interest
in improving his station. He accepted his lot in life and you can be sure that
if there was ever a call to adventure, he quickly hung up.

Don't be like Uncle Owen. Do you have work to do and projects to finish? Of
course. But that doesn't mean you have to learn just enough to do your job; to
check off the tasks and check out your mind. While Elixir is still a young
language it has a rich ecosystem and a myriad of nooks and crannies to
investigate and explore. Protocols are just one of the many areas to explore.

In this article, we've looked at what protocols are, three reasons to use them,
how to implement, and how to create our own. There is still more to explore and
more to learn about them beyond what I've written here, but you can only do that
by experimenting with them yourself.
