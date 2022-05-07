---
title: "Elixir Processes: Observability"
date: 2020-05-29T18:21:24-05:00
draft: false
description: "Observability in most programming languages is really just guesswork, but Elixir gives you the tools to know exactly what's happening in your processes and applications. This article shows you how."
comments: false
post: true
categories: [elixir, processes, observability, instrumentation]
---

The puzzle game, [Black Box][], "simulates shooting rays into a black box to
deduce the locations of "atoms" hidden inside." Gameplay takes place using a
grid and by selecting rows and columns to "shoot rays" through.  With each shot,
a ray can pass through to the other side, hit an atom, or reflect off in a
different direction. Each ray and subsequent output provides clues to where the
atoms lie. The objective, of course, is to figure out where the atoms are.

Observability in most programming languages is similar to playing Black Box.
Instead of shooting rays into a grid to locate atoms, however, we are reduced to
watching logs, deciphering stack traces, caveman debugging, and guesswork to try
and find memory leaks, bottlenecks, and [Heisenbugs][]. It's tedious and
frustrating work, and nowhere near as fun as playing the puzzle game.

But observability in Elixir is a vastly different experience than that of "most
programming languages", because Elixir comes with observability built in.
Questions such as "how much memory is a process consuming?", "how many child
processes does the parent have?", and "what's the internal state of a
process?" are all easily answered with a few keystrokes.

## Basic Tools

While it's not uncommon to use what's described in the remainder of this article
from within the modules of your application, you're far more likely to use them
in the REPL – either during development or attached to a production application.
As such, you need to know how to start a new process or connect to an existing
one. You'll also want to know a couple IEx shortcuts.

You should already know you can start and connect an IEx session to your
application with `iex -S mix`. In the case of a Phoenix application, you can
use `iex -S mix phx.server`. For production releases using [Distillery][] or
[Mix Releases][] you can connect a console to the running application with
`bin/my_app remote_console` (Distillery) or `bin/my_app remote` (Mix Release)
from your app's deployment directory.

When dealing with processes, you need to know the process' name, the PID
(Process ID), or the reference; the last being most often used with
monitored processes. You can build either a PID or a reference with `pid/1,3` or
`ref/1,4` respectively. For example, if the PID you're interested in is
`#PID<0.100.0>`, but you don't have it assigned to a variable, you can do the
following in IEx:

```elixir
iex 1> pid = pid(0, 100, 0)
#PID<0.100.0>
```

You can do something similar for references.

```elixir
iex 1> ref = ref(0, 0, 1, 0)
#Reference<0.0.1.0>
```

In our haste to test out ideas, we often forget to assign variables to the
experiments we run. Because of this, the `v/1` IEx helper is an invaluable tool.
If you execute a function without assigning the result to a variable,
you can retrieve and assign the result immediately afterward:

```elixir
iex 1> pid(0, 100, 0)
#PID<0.100.0>

iex 2> pid = v
#PID<0.100.0>
```

If the output is further back in the IEx history, provide the history index to
`v/1` to retrieve that value:

```elixir
iex 1> 2 + 2
4

iex 2> pid(0, 100, 0)
#PID<0.100.0>

iex 3> cuatro = v(1)
4
```

As you see, we set `cuatro` to `4` from the first IEx line rather than the PID
from the previous line.

With these basic tools at our fingertips, we're ready to start observing our
applications and systems.

## Finding Processes

The first step to finding any solution is knowing what the problem is. In the
case of observing Elixir processes, it's knowing which process to look at. We
already know how to build a PID from scratch, now let's see how to find PIDs for
our processes.

### `Process.whereis/1`

If you're fortunate enough to know the name of the process you want to observe,
you can find its PID with `Process.whereis/1`. This function takes an atom as
argument and returns the PID (or `nil`) of the associated process.

As an example, a typical IEx session runs many processes, including `IEx.Pry`
and `Logger`. With those names in hand, it's a simple matter to discover their
PIDs.

```elixir
iex 1> Process.whereis(Logger)
#PID<0.103.0>

iex 2> Process.whereis(IEx.Pry)
#PID<0.95.0>
```

Now that you see how easy it is to find the PID of a named process (i.e.
registered name), you can understand why it's important to give names to your
GenServer processes. Without a name, where do you start looking?

### `Process.list`

If you're not sure of the exact name of the process you're looking for, you can
get a list of all the processes running with `Process.list/0`. This function
lists all running PIDs. By itself, it isn't terribly helpful, but when paired
with other functions it's useful in tracking down processes.

Here's an example of listing PIDs along with their registered name if available:

```elixir
iex 1> for pid <- Process.list, do: {pid, Process.info(pid, :registered_name)}
[
  {#PID<0.0.0>, {:registered_name, :init}},
  {#PID<0.1.0>, {:registered_name, :erts_code_purger}},
  {#PID<0.2.0>, {:registered_name, []}},
  {#PID<0.3.0>, {:registered_name, []}},
  {#PID<0.4.0>, {:registered_name, []}},
  {#PID<0.5.0>, {:registered_name, []}},
  {#PID<0.6.0>, {:registered_name, []}},
  {#PID<0.9.0>, {:registered_name, :erl_prim_loader}},
  {#PID<0.41.0>, {:registered_name, :logger}},
  {#PID<0.43.0>, {:registered_name, :application_controller}},
...
]
```

We'll see a better way to organize this data later, but this is a good starting
point.

### Related Processes

It's not always the case that the process you're looking has a name or is even
recognizable. In those cases, it may be that it's linked to or monitored by
another process. Knowing _that_ process's name can help you narrow down your
search.

As an example, let's pretend one of `Logger`'s processes is causing problems for
us. If we use the `for` comprehension above to find Logger related processes,
we see the following:

```elixir
iex 1> for pid <- Process.list, do: {pid, Process.info(pid, :registered_name)}
[
  ...
  {#PID<0.41.0>, {:registered_name, :logger}},
  ...
  {#PID<0.68.0>, {:registered_name, :logger_sup}},
  {#PID<0.69.0>, {:registered_name, :logger_handler_watcher}},
  {#PID<0.70.0>, {:registered_name, :logger_proxy}},
  ...
  {#PID<0.99.0>, {:registered_name, []}},
  {#PID<0.100.0>, {:registered_name, Logger.Supervisor}},
  {#PID<0.101.0>, {:registered_name, Logger}},
  {#PID<0.102.0>, {:registered_name, []}},
  {#PID<0.103.0>, {:registered_name, Logger.BackendSupervisor}},
  ...
]
```

If we don't see any problems with any of the named processes for `Logger`, we
can take it a step further by looking at any processes which are linked
or being monitoring. Given our understanding of the system we might guess that
`Logger.Supervisor` is either linked to or monitoring the processes causing
us problems.

```elixir
iex 1> pid = pid(0, 100, 0) # build Logger.Supervisor's pid
#PID<0.100.0>

iex 2> {:links, pids} = Process.info(pid, :links)
{:links, [#PID<0.101.0>, #PID<0.102.0>, #PID<0.103.0>, #PID<0.99.0>]}
```

From our earlier list of `pids`, we see that PIDs 101 and 103 have names (and
so already viewed). However, we haven't looked at the unnamed PIDs, 99 and
102. With that information in hand, we can continue our analysis.

With both the tools and the ability to find specific processes, we can now turn
our attention to the investigation.

## Observing Processes

Observability, like so many words in this industry, is a loaded term, referring
to everything from monitoring an individual function or process to tracing its
interactions with other components within _and_ outside the system.  While
tracing is certainly an important component to observability, its one which
deserves its own treatment. For now, we will focus on inspecting individual
processes.

### Process.info/1,2

The most useful tool for Elixir process observability is `Process.info/1,2`.
It's a wrapper around `:erlang.process_info/1,2`, and returns a wealth of
information about any given process. To see what I mean, run it against an
existing IEx process with `Process.info(self())`. If your session is anything
like mine, the output will exceed your screen and maybe even your terminal
buffer.

Even though `Process.info` provides a wealth of information, not all of it is
always useful. Let's look at some of the more valuable pieces of information
returned:

- `:links`: A list of PIDs linked to this process
- `:memory`: The total amount of memory in bytes to process is consuming. "This
  includes call stack, heap, and internal structures."
- `:message_queue_len`: A count of the messages in the process mailbox.
- `:messages`: A list of messages in the process mailbox.
- `:observed_by`: A list of PIDs which are monitoring the process.
- `:observes`: A list of PIDs monitored by the process.
- `:registered_name`: The name the given to the process. If it doesn't
  have a name, an empty list (`[]`) is returned.
- `:status`: The current state of the process. It can fall into one of the
  following:
    - "exiting"
    - "garbage_collecting"
    - "waiting" (for a message)
    - "running"
    - "runnable" (ready to run, but another process is running)
    - "suspended" (suspended on a "busy" port or by the BIF erlang:suspend_process/1,2)
- `:reductions`: "represent an arbitrary number of work actions. Every function
  call, including BIFs, will increment a process reduction counter. After a given
  number of reductions, the process gets descheduled....The reduction count has
  a direct link to function calls in Erlang, and a high count is usually the
  synonym of a high amount of CPU usage." [Erlang in Anger][]

Since these are the most useful indicators for a process, it makes sense to
request only those you need. You can do that with the two-argument version of
`Process.info.`

```elixir
iex 1> Process.info(self(), [:registered_name, :memory, :messages, :links])
[registered_name: [], memory: 142836, messages: [], links: []]
```

The [Erlang documentation for
`process_info/2`](http://erlang.org/doc/man/erlang.html#process_info-2) has all
the possible atoms you can pass as arguments.

### The `:sys` Module

The `:sys` module, as stated in the documentation, "contains functions for
sending system messages used by programs, and messages used for debugging
purposes." Of the many functions provided by the module, we're concerned
with three.

#### `:sys.get_state` and `:sys.replace_state`

Both `:sys.get_state` and `:sys.replace_state` are only useful with `GenServer`
processes. The former returns the current value of "state" as it's passed around
within the server, while the latter enables you to replace it.

In the case of both of these functions, be aware of the caution set forth in the
Erlang documentation, particularly for `:sys.replace_state`:

> These functions are intended only to help with debugging, and are not to be
> called from normal code. They are provided for convenience, allowing
> developers to avoid having to create their own custom state replacement
> functions.

Let's look at how to use both of these functions with an simple GenServer:

```elixir
iex 1 > defmodule Useless do
... 1 >   use GenServer
... 1 >
... 1 >   def start_link() do
... 1 >     GenServer.start_link(__MODULE__, [])
... 1 >   end
... 1 >
... 1 >   def init(_), do: {:ok, []}
... 1 > end
{:module, Useless, "...", {:init, 1}}

iex 2 > {:ok, pid} = Useless.start_link
{:ok, #PID<0.122.0>}

iex 3 > :sys.get_state(pid)
[]

iex 4 > :sys.replace_state(pid, fn state -> [1, 2, 3] end)
[1, 2, 3]

iex 5 > :sys.get_state(pid)
[1, 2, 3]

iex 6 > :sys.replace_state(pid, fn state -> state ++ [4, 5, 6] end)
[1, 2, 3, 4, 5, 6]

iex 7 > :sys.get_state(pid)
[1, 2, 3, 4, 5, 6]
```

What you see in the above IEx session is straightforward. On lines 1 and 2 we
declare and start the `Useless` GenServer. In the remaining exchanges, we either
retrieve or replace the GenServer's state. `:sys.get_state/1` is easy enough to
understand: it accepts either a PID or registered name and returns the server's
current state. `:sys.replace_state/2`, on the other hand, expects both a PID and
a single arity function, the output of which updates the server state.

#### `:sys.statistics`

The last observability tool we'll look at is `:sys.statistics/2,3`. Like
`:sys.get_state/1` and `:sys.replace_state/2`, it's only useful with GenServers.
The `statistics` function has limited use, but with it, we can monitor messages
as they pass in and out of a server, as well as track the increase in
reductions.

To use `:sys.statistics`, you must first start it. After that, you can `:get`
the current measurements. Here's an example of how you might use it with the
`Logger` process:

{% raw %}
```elixir
iex 1> require Logger
Logger

iex 2> :sys.statistics Logger, true
:ok

iex 3> :sys.statistics Logger, :get
{:ok,
 [
   start_time: {{2020, 5, 26}, {21, 4, 9}},
   current_time: {{2020, 5, 26}, {21, 4, 14}},
   reductions: 30,
   messages_in: 0,
   messages_out: 0
 ]}

iex 4> Logger.info "Lorem ipsum dolor"

21:04:20.555 [info]  Lorem ipsum dolor
:ok

iex 5> :sys.statistics Logger, :get
{:ok,
 [
   start_time: {{2020, 5, 26}, {21, 4, 9}},
   current_time: {{2020, 5, 26}, {21, 4, 24}},
   reductions: 260,
   messages_in: 2,
   messages_out: 0
 ]}

iex 6> :sys.statistics Logger, false
:ok

iex 7> :sys.statistics Logger, :get
{:ok, :no_statistics}
```
{% endraw %}

In this exchange, we begin by first `require`ing `Logger` and then begin
capturing statistics with `:sys.statistics Logger, true`. On line 3, we output
the statistics which show `Logger` is at 30 reductions and has had no messages
in or out. Then, on line 4 we output a message to `Logger.info` which results in
a spike in reductions and an increase of `:messages_in` by 2. Finally, we turn
off statistics gathering on line 6, which we show proof of on line 7.

## IEx Tooling

If you've followed along with the examples in IEx, you'll have noticed that the
output is often unwieldy. It doesn't have to be that way. Below is the
beginnings of an observability module you can include in your IEx session. With
it, you can simplify gathering some of the information we've discussed in this
article.

```elixir
defmodule Beholder do
  defstruct memory: 0,
            reductions: 0,
            links: [],
            monitors: [],
            monitored_by: [],
            registered_name: nil,
            message_queue_len: 0,
            messages: [],
            status: nil

  @base_fields [
    :memory,
    :reductions,
    :links,
    :monitors,
    :monitored_by,
    :registered_name,
    :message_queue_len,
    :messages,
    :status
  ]

  def look(pid) when is_pid(pid) do
    pid
    |> Process.info(@base_fields)
    |> Enum.into(%Beholder{})
  end

  def look(name) when not is_nil(name) and is_atom(name) do
    name
    |> Process.whereis()
    |> look()
  end

  def look(_), do: nil

  def named_pids do
    Process.list
    |> Enum.map(fn pid ->
      {_, module} = Process.info(pid, :registered_name);
      {pid, module}
    end)
    |> Enum.filter(fn {_pid, name} -> name != [] end)
  end

  def processes_by_memory do
    Process.list
    |> Enum.map(fn pid ->
      [registered_name: name, memory: memory] = Process.info(pid, [:registered_name, :memory])
      {pid, memory, name}
    end)
    |> Enum.sort_by(&(elem(&1, 1)))
  end

  defimpl Collectable do
    def into(list) do
      collector = fn
        beholder, {:cont, {key, value}} ->
          Map.put(beholder, key, value)

        beholder, :done ->
          beholder

        _beholder, :halt ->
          :ok
      end

      {list, collector}
    end
  end
end
```

The `Beholder` module lets you get a quick peek at a process with `look/1`, list
those processes with names with `named_processes/0, and list processes along
with their memory consumption using `processes_by_memory/0`. Although useful,
there are still more ideas you could include to expand your process
observability. Here are a few ideas:

- Search for processes with names like a given string (i.e. RegEx)
- List processes with memory or reductions above a certain threshold
- Find processes whose reductions are growing faster than a given rate
- Color code memory values from the `processes_by_memory/0` function
- List processes whose mailbox never shrinks
- Output a limited process graph like what you might see in `:observer`

If you like this module, you can either copy it directly into a `.iex.exs`
file or read it in from another location. I like to keep mine in `$HOME/.iex`
and use the following line in my `.iex.exs` file.

```
File.exists?(Path.expand("~/.iex/beholder.exs")) && import_file("~/.iex/beholder.exs")
```

## Conclusion

For most languages, observing objects and processes is like playing Black Box.
If you shoot enough "rays" into the box, the hope is you'll have an idea of
what's going on inside. Elixir, on the other hand, is like playing Black Box
with cheat codes. You can see exactly what's going on: how much memory each
process consumes, how many messages are passed, when garbage collection will
take place, and even which processes relate to which.

Erlang's creators had observability in mind when they wrote the language, and
Elixir inherits those same capabilities. Because of this, all the tools we need
to observe our systems are always within reach, existing primarily in the
`Process` and `:sys` modules. Not only are the tools always close at hand, but
we can use those tools on live systems simply by connecting to those systems
with a console. That's real observability.


[Black Box]: https://en.wikipedia.org/wiki/Black_Box_(game)
[Heisenbugs]: https://en.wikipedia.org/wiki/Heisenbug
[Erlang in Anger]: https://erlang-in-anger.com/
[Distillery]: https://github.com/bitwalker/distillery
[Mix Releases]: https://elixir-lang.org/getting-started/mix-otp/config-and-releases.html
