---
title: Differences Between Elixir's Protocols and Behaviours
date: 2025-11-18T00:00-05:00
draft: false
description: "I kept mixing up Elixir Protocols and Behaviours—until I finally figured out the real difference. One is for data types, the other for modules. Here’s the explanation I wish I’d had years ago."
image: /assets/images/protocols_v_behaviours/protocols_v_behaviours.png
comments: false
post: true
categories: [elixir]
---

I second guess myself a lot about what I know, or what I think I know. It's even
worse when it comes to the names of people I don't normally interact with: "I'm
almost positive his name is Dave, but I don't want to get it wrong, so I'll just
wait until someone else says his name." It's a solution, but I'd rather be
certain about their names.

In my previous article, [Crawling the Web with Elixir's Broadway and
Wallaby](https://samuelmullen.com/articles/crawling-the-web-with-elixirs-broadway-and-wallaby),
I suggested that it might be "beneficial to use either a Protocol or Behaviour
to reduce code duplication," but when considering which to use for what I'm
working on, it left me second-guessing myself yet again. What's the difference?
When would you use one over the other? How do they actually help?

Because I don't think I'm alone in my confusion, I'm going to try to answer
these questions by first explaining what I thought I understood about both,
talking about what I got wrong, showing the differences, and then giving a
real-world&mdash;if contrived and incomplete&mdash;example for when you might
use both.

## What I Knew About Protocols

I thought I had a pretty good handle on protocols; I even wrote [an article
about them](https://samuelmullen.com/articles/elixir-protocols). I knew they
provided, "a mechanism to achieve polymorphism in Elixir." That is,

> by implementing functions specific to a protocol, we make sure our structs and
> built-in data types can take advantage of everything the implemented library
> has to offer.

I also knew they provided a way to extend a module's functionality without
having access to the module's source code.

## What I Thought I Knew About Behaviours

I'm embarrassed to admit it, but I thought behaviours were only used to define
what functions a module had to have. That's not entirely wrong, but it misses
the "why?". I came to this conclusion after reading José's article, [Mocks and
Explicit Contracts](https://dashbit.co/blog/mocks-and-explicit-contracts). In
that article he shows how to create mocks by switching out one module for
another in a test environment, but it only worked if both modules, the original
and the mock, conformed to the same contract, i.e. Behaviour. Because the
Behaviour example from the article did nothing other than define callbacks, I
concluded that that's all they were used for.

This conclusion was further solidified after hearing an Elixir podcast host
state that he thought Behaviours were best used in libraries rather than in your
project, because you have control over the modules in your own project. That's
probably not what he meant, but it's what I heard and it conformed to what I was
already thinking: Behaviours are kind of useless.

## What I Got Wrong

There were three things I got wrong about the Protocols and Behaviours.

### Protocols are Just Specialized Behaviours

The first misunderstanding I had was thinking Protocols were Behaviours with
added functionality. I came to that conclusion from the following quote:

> Protocol is a behaviour with the dispatching logic so you don't need to hand
> roll it nor impose a particular implementation in the user module.
>
> -- José Valim - [Google Group discussion](https://groups.google.com/g/elixir-lang-talk/c/S0NlOoc4ThM/m/J2aD2hKrtuoJ?pli=1)

It's true that "[a] protocol is indeed a behaviour + dispatching logic," but
what I misunderstood was thinking a Protocol was interchangeable with a
Behaviour. They are not.

### Behaviours Don't Provide Functionality

Maybe it's because I knew about behaviors in C# or because I had heard
"contract" used in relation to Behaviours, but for whatever reason, I had it in
my mind that Behaviours only _defined_ a module's functionality, but didn't
_provide_ any itself. I can't defend this misunderstanding. If I had taken five
minutes to think about how `GenServer` or `Plug` worked, I would have quickly
abandoned that idea: both Behaviours obviously provide lots of functionality.

### Behaviours Were Better Suited in Libraries

The idea that Behaviours are better suited in libraries than in your projects
came from a couple places. I first heard the argument on a podcast, (which shall
remain nameless) but I don't think it's what the speaker meant. And because I
already had the idea that Protocols were just specialized Behaviours, and
Behaviours didn't provide functionality, it was an easy, if erroneous,
conclusion to reach.

## What are the Differences

Protocols and Behaviours differ primarily by what they execute against.
Protocols work with data types, while Behaviours execute against modules. Every
other difference is based off these fundamental concepts.

> ...a behaviour is internal to a module–the module implements the behaviour.
> Protocols are different–you can place a protocol's implementation completely
> outside the module. This means you can extend modules functionality without
> having to add code to them..."
>
> -- Dave Thomas, _Programming Elixir_

### Protocols Don't Provide Functionality

The first thing to notice when working with Protocols&mdash;that is, if you are
creating one&mdash;is that they don't provide functionality, they define it.
Consider the `Enumerable` Protocol:

```elixir
defprotocol Enumerable do
  # documentation, type definitions, and specs have been removed
  def reduce(enumerable, acc, fun)

  def count(enumerable)

  def member?(enumerable, element)

  def slice(enumerable)
end
```

It's not until you _implement_ the Protocol, that you gain functionality.

Example:

```elixir
defmodule User do
  defstruct [:id, :name, :age]

  defimpl Inspect do
    def inspect(user, _opts_) do
      "#{user.name} (#{user.age})"
    end
  end
end

# iEX

iex :: 1 > IO.inspect %User{id: '10-289", name: "John Galt", age: 38}
John Galt (38)
```

### Protocols Work on Data Types

Unlike Behaviours which work at the Module level, Protocols work on data types.
In the previous example, where we implemented the `Inspect` protocol on `User`,
a `%User{}` struct is passed to `IO.inspect/2`. The `inspect/2` function is then
able to do something with it because `User` defines how `Inspect` should handle
it.

> Protocol is type/data based polymorphism. When I call Enum.each(foo, ...), the
> concrete enumeration is determined from the type of foo.
>
> -- Sasa Juric [StackOverflow answer](https://stackoverflow.com/questions/26215206/difference-between-protocol-behaviour-in-elixir)

At runtime, Protocols allow us to execute the appropriate logic against the
specific datatype. This is dynamic dispatching.

### Protocols Allow Polymorphism

In OOP, polymorphism allows objects of different classes to be treated as
instances of a common superclass. You get a similar behavior in Elixir when you
implement a Protocol in your datatypes.

> _Polymorphism_ is a runtime decision about which code to execute, based on
> the nature of the input data. In Elixir, the basic (but not the only) way of
> doing this is by using the language feature called _protocols_.
>
> -- Sasa Juric

As we saw when we implemented the `Inspect` Protocol in the `%User{}` struct
above, any datatype that implements the `Inspect` protocol can be passed to
functions like `Kernel.inspect/2` and `IO.inspect/2` and Elixir figures out how
to handle each at runtime based on the datatype implementation.

### Protocols Extend Module Behavior

If you've come to Elixir from another language like Ruby or JavaScript, you
might be familiar with the term, "monkey patching." Monkey patching allows us
to "open up" a class or object and add or overwrite functionality. While you
can't overwrite functions in Elixir, you can extend functionality through the
use of Protocols.

> protocols allow us to extend the original behavior for as many data types as
> we need. That’s because dispatching on a protocol is available to any data
> type that has implemented the protocol and a protocol can be implemented by
> anyone, at any time.
>
> -- Elixir Lang

As an example, if you had the following `Emptiness` protocol in your codebase...

```elixir
defprotocol Emptiness do
  @doc "Returns a boolean value based on the 'emptiness' of the term"
  @spec empty?(term) :: boolean()
  def empty?(t)
end
```

...you could extend any Elixir type with `Emptiness` regardless of whether or
not it was a 1st-party type or if it was included as a library.

```elixir
defimpl Emptiness, for: Plug.Conn do
  def empty?(%Plug.Conn{resp_body: nil}), do: true
  def empty?(%Plug.Conn{resp_body: body}), do: length(body) == 0
end
```

In this example, even though we didn't create `Plug.Conn`, we can still add new
functionality with the `Emptiness` Protocol.

### Behaviours Require Conformity

Protocols don't require you to implement every function definition, but if you
don't you may not get every available feature. For example, if you only
implement the `Enumerable.reduce/2` function in your module, you'll only be able
to pass your module type to some of `Enum`'s functions. With Behaviours, on the
other hand, you either implement every associated function or your application
doesn't run.

> A module that declares that it implements a particular behaviour must
> implement all of the associated functions. If it doesn't, Elixir will generate
> a compilation warning.
>
> -- Dave Thomas, _Programming Elixir_

And again...

> By declaring that our module implements that behaviour, we let the compiler
> validate that we have actually supplied the necessary interface. This reduces
> the chance of an unexpected runtime error."
>
> -- Dave Thomas, _Programming Elixir_

### Behaviours Execute Modules

As stated under [What are the Differences](what-are-the-differences), "Protocols
and Behaviours differ primarily by what they are executed against. Protocols
work with data types, while Behaviours execute against modules." In order for
this to work, modules must conform to the Behaviour by implementing the required
functions.

> Behaviour is a typeless plug-in mechanism. When I call
> `GenServer.start(MyModule)`, I explicitly pass MyModule as a plug-in, and the
> generic code from GenServer will call into this module when needed.
>
> -- Sasa Juric [StackOverflow answer](https://stackoverflow.com/questions/26215206/difference-between-protocol-behaviour-in-elixir)

### Behaviours Define and Implement Common Logic

Behaviours provide a way of abstracting away functionality that is common across
every module that would implement them. For example, when you create a module
using the `GenServer` Behaviour and implement `init/1` and `handle_cast/2`, you
don't think about the loop it runs in, or handling state. The `GenServer`
Behaviour provides that functionality. All you need to worry about is
implementing the required functions.

> A behaviour is a way to say: give me a module as argument and I will invoke
> the following callbacks on it, which these argument and so on. A more complex
> example for behaviours besides a GenServer are the Ecto adapters.
>
> -- José Valim [Google Group discussion](https://groups.google.com/g/elixir-lang-talk/c/S0NlOoc4ThM/m/J2aD2hKrtuoJ?pli=1)

Usually the provided functionality is accomplished through meta programming, and
you would `use` the specific Behaviour, but it's not required and there's no
reason you couldn't populate the Behaviour module with "normal" functions for
added utility.

## Conclusion

We get things wrong all the time. We miss meetings, include or exclude the wrong
features, work on the wrong tasks, and the list goes on. Sometimes these
mistakes are due to a misunderstanding, sometimes it's poor communication, and
sometimes it's failing to check your premises. With regard to Protocols and
Behaviours, for me it was a little bit of everything.

What I discovered, however, is that Behaviours and Protocols, while
superficially similar, serve very different roles in the Elixir ecosystem.
Protocols provide extensibility and polymorphism to your types, while Behaviours
provide functionality to and demand conformity from your modules. Behaviours are
about plugging in modules (`GenServer`, `Plug`, `Ecto.Repo`, etc.). Protocols
are about plugging in data types (`Enumerable`, `Jason.Encoder`, `String.Chars`,
etc.). Once you see it that way, you'll never second-guess yourself again.

## Example

What follows is a completely contrived and incomplete example of how one might
use Behaviours and Protocols together. The idea is that you might want to update
a local User's identity with information from a social network, and also update
the social network's information from that changed locally.

Here is both an example Behaviour and Protocol:

```elixir
# SocialProfile Behaviour

defmodule SocialProfile do
  @callback get_profile(Identity.t) :: {:ok, term} | {:error, atom}

  @callback update_profile(Profile.t) :: {:ok, term} | {:error, atom}

  @callback to_profile(Identity.t) :: term | {:error, atom}
end

# Identifier Protocol

defprotocol Identifier do
  def to_identity(profile)
end
```

Modules implementing the `SocialProfile` Behaviour are required to implement
the functions: `get_profile/1`, `update_profile/1`, `to_profile/1`, and
follow the TypeSpecs provided.

The `Identifier` Protocol requires that any module implementing it create the
`to_identity/1` function. You would use this to transform social media profiles
into local Identities.

Here are two Profiles you might create:

```elixir
# x_profile.ex

defmodule XProfile do
  @behaviour SocialProfile

  @impl SocialProfile
  def get_profile(identity) do
    # logic to retrieve profile based on provided identity
  end

  @impl SocialProfile
  def update_profile(profile) do
    # logic to update profile
  end

  @impl SocialProfile
  def to_profile(identity) do
    [first_name, last_name] = String.split(identity.name)
    %{
      first_name: first_name,
      last_name: last_name,
      email: identity.email,
      bio: identity.bio
    }
  end
end

# Protocol implemented outside of module
defimpl Identifier, for: XProfile do
  def to_identity(profile) do
    %Identity{
      name: "#{profile.first_name} #{profile.last_name}",
      email: profile.email,
      bio: profile.bio
    }
  end
end

# github_profile.ex

defmodule GitHubProfile do
  @behaviour SocialProfile

  @impl SocialProfile
  def get_profile(identity) do
    # logic to retrieve profile based on provided identity
  end

  @impl SocialProfile
  def update_profile(profile) do
    # logic to update profile
  end

  @impl SocialProfile
  def to_profile(identity) do
    %{
      name: identity.name,
      email: identity.email,
      description: identity.bio
    }
  end

  # Protocol implemented inside module
  defimpl Identifier do
    def to_identity(profile) do
      %Identity{
        name: profile.name,
        email: profile.email,
        bio: profile.description
      }
    end
  end
end
```

The main difference between the two is the use of `first_name` and `last_name`
on the `XProfile` versus just having a `name` in GitHub. Because of that, we
need a little extra logic in `to_identity/1` and `to_profile/1` in `XProfile`.

I didn't add example logic to either `get_profile/1` or `update_profile/1`
because it seemed like unnecessary effort. The purpose of both is clear.

Lastly, we have an example of how the above might be used:

```elixir
# Example Behaviour usage

identity = Users.get_identity_by_email("john@galtsgulch.co")

[GitHubProfile, XProfile]
|> Enum.each(fn social_profile ->
  identity
  |> social_profile.to_profile()
  |> social_profile.update_profile()
end)
```

In this usage example, we are retrieving the User's identity based on their
email. With that in hand, we are then able to update all of their social
profiles after first transforming the identity into the required profile.

In the next example, we retrieve the User's profile from GitHub, and then
transform it into an Identity in order to update our local copy.

```elixir
# Example Protocol usage

identity = Users.get_identity_by_email("john@galtsgulch.co")

profile = GitHubProfile.get_profile(identity)

identity = Identifier.to_identity(profile)

Users.update_identity(identity)
```
