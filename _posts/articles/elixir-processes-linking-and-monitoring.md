---
title: "Elixir Processes: Linking and Monitoring"
date: 2020-04-16T06:48:29-05:00
draft: false
description: "Erlang's motto is \"Let it crash.\" But what then? What do you do with a dead process and how do you even know it's passed on? Linking and monitoring is the answer, but which one do you choose and when? Let's find out."
comments: false
post: true
categories: [elixir, concurrency, processes]
---

Sometimes processes die. Maybe they didn't have to; maybe we could have
accounted for the eventuality, but probably not. The truth is, programming's a
messy business. The data we work with is messy, the specs are messy, the
network's messy, and above all else, people are messy. And so, in spite of our
best intentions and best efforts, processes die.

In my article [Elixir Processes: Send and
Receive](https://samuelmullen.com/articles/elixir-processes-send-and-receive/)
we learned how to spawn new processes and use messages to communicate with them.
What was absent in the article, however, was any discussion about what to do
when a process dies. We didn't worry about it in the examples: the functions
were small, we were dealing with known data sets, and they where just examples
after all. But we live in a messy world. We work with complicated functions,
unknown data sets, and active, production code. When a process dies, it's not
okay to just "let it crash," we have to do something about it.

In that last article we saw how processes communicate by sending messages to
other processes or even to themselves. Once sent, messages wait in a process's
mailbox until "received". Unless spawned processes are alive and able to respond
with messages of their own, how is the caller supposed to know the target
process received the message or is even still alive?

You might answer with, "because it has the process's PID." Maybe, but try this:

```elixir
iex > pid = pid(0, 999, 0) # <- non-existent PID
#PID<0.999.0>

iex > Process.info(pid)
nil

iex > send(pid, :hello)
:hello
```

It looks like our IEx session was able to send a message to `#PID<0.999.0>`. We
even get the expected response, but the process doesn't exist. This proves we
can't rely on message passing to know if a process is still alive. Dead
processes tell no tales. Instead we need to either keep a watchful eye on the
process, or bind the watcher and watched together. We'll tackle this second idea
first.

Linking Processes
-----------------

In [Programming
Elixir](https://www.goodreads.com/book/show/40654424-programming-elixir-1-6),
Dave Thomas describes linking like this: "Linking joins the calling process and
another process–each receives notifications about the other." In reality,
linking processes together is more like binding them together in a death pact.
The pact says that if one process dies, all the processes linked to it will also
die. It also means that processes linked to processes linked to a dying process
die too. Pacts are not to be trifled with.

At first blush, linking processes seems like an extreme decision to make in your
application design; taking out all associated processes just because one messed
up is an extreme outcome. However, if you've ever used a GenServer, you've
already linked processes. To demonstrate what I mean, let's look at the world's
most useless GenServer:

```elixir
defmodule Useless do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_), do: {:ok, []}
end
```

Copy those nine lines into an IEx session and then make note of the IEx
session's PID:

```elixir
iex > self()
#PID<0.121.0>
```

Next, we'll start `Useless`, kill it, and check our IEx session's PID again.

```elixir
iex > {:ok, pid} = Useless.start_link([])
{:ok, #PID<0.126.0>}
iex > Process.exit(pid, :kill)
** (EXIT from #PID<0.121.0>) shell process exited with reason: killed

Interactive Elixir (1.9.1) - press Ctrl+C to exit (type h() ENTER for help)
iex > self()
#PID<0.128.0>
```

As you can see, when we start the `Useless` GenServer and kill it, it takes our
IEx session with it, because the two were linked. This should give you pause the
next time you start a GenServer outside of anything other than a supervisor.

### Why Would You Link Processes?

The question remains: why would you link processes together? Elixir is a
concurrent programming language. We often use many processes to perform a larger
computation. If one of those processes behaves badly, "We don't [want to] make
matters _worse_ by performing additional computations after we know that things
have gone wrong" ([Programming
Erlang](https://www.goodreads.com/book/show/17800216-programming-erlang))

### Linking Primitives

The two function primitives for linking processes are `spawn_link/1,3` and
`Process.link/1`. The former takes arguments to launch a new process and link to
it at the same time, while the latter accepts a PID to perfrom the link. In both
cases, "Linking joins the calling process and another process–each receives
notifications about the other." ([Programming
Elixir](https://www.goodreads.com/book/show/40654424-programming-elixir-1-6))
Let's look at each in turn.

#### `spawn_link/1,3`

`spawn_link/1,3` is an atomic function: it both spawns a process and links to it
at the same time. This ensures the spawned process can't die before it and the
calling process are linked. Like `spawn/1,3` it can be called two different
ways: by passing it a function or by passing an MFA (module, function,
arguments). Let's look at `spawn_link/1` first:

```elixir
iex > pid = spawn_link(fn -> receive do :crash -> 1 / 0 end end)
#PID<0.131.0>

iex > send(pid, :crash)
:crash
```

The anonymous function we provide `spawn_link/1` does nothing except wait for a
specific message: `:crash`. All other messages are stored safely in its mailbox,
but when a `:crash` message is sent, it matches against it and attempts to
divide 1 by 0, summarily throwing an `ArithmeticError` exception. The exception
kills the process and the linked IEx process with it.

We can do something similar with `spawn_link/3`.

```elixir
iex > defmodule Crashy do
... >   def run do
... >     receive do
... >       :crash -> 1 / 0
... >     end
... >   end
... > end

iex > pid = spawn_link(Crashy, :run, [])
#PID<0.148.0>

iex > send pid, :crash
:crash
```

In both cases, when we send the linked process the `:crash` message it throws an
exception, exiting the process, and taking our IEx session with it.

#### `Process.link/1`

Unlike `spawn_link/1,3`, `Process.link/1` accepts the PID of an existing
process, which by definition cannot be atomic: the process already existed. It
is much more common to both see and use `Process.link/1` than either of the
`spawn_link` variants. Even the Elixir docs warn against using `spawn_link`:
"Typically developers do not use the spawn functions, instead they use
abstractions such as Task, GenServer and Agent, built on top of spawn, that
spawns processes with more conveniences in terms of introspection and
debugging." [Elixir - spawn_link
docs](https://hexdocs.pm/elixir/1.10.2/Kernel.html#spawn_link/1)

To demonstrate how to use `Process.link/1`, spawn a new process similar to what
we did above with `spawn_link/1`:

```elixir
iex > pid = spawn(fn -> receive do :crash -> raise "boom" end end)
#PID<0.129.0>
```

If we were to send `:crash` to our spawned process, it would raise an exception
and die, but our existing IEx process would be fine. If we called
`Process.link(pid)` _before_ sending the `:crash` message, however, we'll see
output much like what we saw with `spawn_link/1,3`.

```elixir
iex > Process.link(pid)
true

iex > send pid, :crash
** (EXIT from #PID<0.127.0>) shell process exited with reason: an exception was
raised:
    ** (RuntimeError) boom
        (stdlib) erl_eval.erl:678: :erl_eval.do_apply/6
```

### Trapping Exits

<aside class="panel panel-default pull-right col-md-4">
  <h3>Well, actually...</h3>
  <p>There are rare instances where you want to take down an entire collection
of processes and not start them back up. The first thing I can think of is in a
test suite. If you spawn processes prior to your assertions, you may
want them to die and take the test suite with it if they can't set up the
test properly. You can see an example of this in <a
href="https://github.com/hexpm/hexpm/blob/ff427bdb7069578c37312910858c70bff81439ce/test/hexpm/throttle_test.exs">Hex's
API</a></p>
</aside>

So far linking processes has been a useless exercise. There are no instances I
can think of where you'd want to terminate linked processes with no ability
to recover. Erlang's mantra, "Let it crash," concerns individual processes
within an application, not the entire application itself. Even then, the idea is
to allow a supervisor to restart the process from a clean slate. But how does a
supervisor know when a child process dies and when to restart it? Simple,
the supervisor and the child process are linked. The next question then is, "why
doesn't the supervisor die along with the child when it dies?" The answer is
because the supervisor traps the exit signal.

When processes are linked, "If [any] process terminates for whatever reason, an
_exit signal_ is propagated to all the processes it's linked to." [The Little
Elixir & OTP Guidebook](https://www.goodreads.com/book/show/25563811-the-little-elixir-otp-guidebook). Elixir allows us to "trap" that exit signal, converting it to a three-tuple message instead.

> When `trap_exit` is set to "true", exit signals arriving to a process are
> converted to `{'EXIT', From, Reason}` messages, which can be received as
> ordinary messages.  If `trap_exit` is set to "false", the process exits if it
> receives an exit signal other than normal and the exit signal is propagated to
> its linked processes.  Application processes are normally not to trap exits.
>
> – [Erlang - process_flag/2](http://erlang.org/doc/man/erlang.html#process_flag-2)

Let's see how this works:

```elixir
defmodule Crashy do
  def run do
    Process.flag(:trap_exit, true)
    spawn_link(Crashy, :splode, [])

    receive do
      {signal, pid, msg} ->
        IO.inspect signal
        IO.inspect pid
        IO.inspect msg
    end
  end

  def splode do
    exit :kaboom
  end
end
```

Try running this in an IEx session with `Crashy.run`. The output will look
similar to this:

```elixir
iex > Crashy.run
:EXIT
#PID<0.178.0>
:kaboom
```

Instead of the exception messages we've seen so far in our examples, we're now
able to capture the exit signal and do something about it. We do
this by first telling our process we want to trap exit signals with
`Process.flag(:trap_exit, true)`. The next line spawns the `splode/0` function
as a linked process which immediate exits. Finally, we use the `receive` block
in the `run/0` function to match against the exit signal and output the
information returned.

If Crashy were a supervising process, you can imagine how you could use this
information to start up a new process, terminate associated processes, or
something else.

### Listing and Unlinking

In [Elixir Processes: Send and
Receive](https://samuelmullen.com/articles/elixir-processes-send-and-receive/),
we used `Process.info/2` to see how much memory spawned processes take up and
also how many messages were waiting in a process's mailbox. Now, we'll use
`Process.info/2` to display the PIDs linked to a process. Instead of passing
`:memory` or `:messages` with the PID, we'll send `:links` (surprising, I know.)

```elixir
# View the console's current links
iex > Process.info(self(), :links)
{:links, []}

# Spawn a process and view the link it creates to the console
iex > spawn_link(fn -> IO.inspect Process.info(self, :links) end)
{:links, [#PID<0.138.0>]}
```

Once you have a process's links, you can do something with them. One use might
be to unlink them. `Process.unlink/1` "[r]emoves the link between the calling
process and the given item." Let's see this in action:

```elixir
iex > self()
#PID<0.157.0>

iex > pid = spawn_link(fn -> receive do :crash -> exit :wheres_the_kaboom end end)
#PID<0.161.0>

iex > Process.info(self(), :links)
{:links, [#PID<0.161.0>]}

iex > Process.unlink(pid)
true

iex > send(pid, :crash)
:crash

iex > self()
#PID<0.157.0>

iex > Process.info(self(), :links)
{:links, []}
```

At this point in the article you probably understand everything that's going on
above, but just in case, let's take it a step at a time. To begin, we use
`self()` to determine our console's PID to ensure the process we start with is
the same one we end with. Next, we spawn a "crashy" process linking it to our
IEx session. Just for clarity's sake, we use `Process.info/2` to prove we are
linked to it. Next, we unlink the process and send it a `:crash` message.
Finally, we call `self/0` to prove our console is the same process we started
with and then show that we no longer have linked processes associated with it.

Monitoring Processes
-------------------

If linking processes is like a couple who've grown old together and can't live
without the other, monitoring processes is like reading the obituaries: you know
who's died and you might feel bad about it, but it doesn't affect you much
beyond that.

With the exception of the return values and function name, there's very little
difference between linking to a process and monitoring one. Just replace "link"
in `spawn_link/1,3` and `Process.link` with "monitor" and you're almost done.
The _real_ difference between linking and monitoring is how processes handle the
death of processes to which they're connected.

The goal of _linking_ processes is to ensure every linked process dies if any
_one_ dies. The goal of _monitoring_ processes is to ensure a process knows
about the termination of another process. If linking ensures all linked
processes die unless the exit signals are trapped, the question then arises,
"Why not always use monitors instead?"

Imagine we had two hand-rolled supervisor processes: one linking to its
children, and the other using monitor. In each scenario the "supervisor" will be
notified if a child exits and will be able to restart it. But what happens if
the supervisor dies? For the children that are linked to their supervisor, they
will exit along with their supervisor. The children which were being monitored,
however, will not even know their supervisor is gone. "...monitoring lets a
process spawn another and be notified of its termination, but without the
reverse notification–it is one-way only." ([Programming
Elixir](https://www.goodreads.com/book/show/40654424-programming-elixir-1-6))
This latter scenario isn't what you want when it comes to supervisors.

### Monitoring Primitives

As with linking processes, there are two function primitives for monitoring
processes: `spawn_monitor/1,3` and `Process.monitor/1`. `spawn_monitor/1,3`
accepts either a function or MFA, while `Process.monitor/1` accepts the PID of
an existing process. Unlike the link functions, the monitor functions also
include a "reference" in their return value.

#### `spawn_monitor/1,3`

Like its cousin, `spawn_link/1,3`, `spawn_monitor/1,3` is atomic in its
execution. Also, like its cousin, it can be called by either passing a function
or an MFA. Unlike `spawn_link`, however, `spawn_monitor` returns a two-element
tuple containing the PID and reference to the spawned process.

```elixir
iex > {pid, ref} = spawn_monitor(fn -> receive do :crash -> exit :kaboom end end)
{#PID<0.110.0>, #Reference<0.3864886318.2185232385.215284>}
```

Having spawned and begun monitoring the process, let's see what happens when the
process is killed:

```
iex > send(pid, :crash)
:crash

iex > flush
{:DOWN, #Reference<0.3864886318.2185232385.215284>, :process, #PID<0.110.0>,
 :kaboom}
:ok
```

If you were to check the PID of the IEx session before and after, you would see
it was the same. `spawn_monitor/3` is much the same

```
iex > defmodule Crashy do
iex >   def run do
iex >     receive do
iex >       :crash -> exit :kaboom
iex >     end
iex >   end
iex > end

iex > {pid, ref} = spawn_monitor(Crashy, :run, [])
{#PID<0.124.0>, #Reference<0.3864886318.2185232385.215530>}

iex > send(pid, :crash)
:crash

iex > flush
{:DOWN, #Reference<0.3864886318.2185232385.215530>, :process, #PID<0.124.0>,
 :kaboom}
:ok
```

#### `Process.monitor/1`

Like `Process.link/1`, `Process.monitor/1` accepts the PID of an existing
process. Instead of returning `true`, however, `Process.monitor/1` returns a
reference to the monitored process.

```elixir
iex > pid = spawn(fn -> receive do :add -> IO.puts 1 + 2 end end)
#PID<0.137.0>

iex > ref = Process.monitor(pid)
#Reference<0.3439345400.1300496390.106497>

iex > send(pid, :add)
3
:add

iex > flush
{:DOWN, #Reference<0.3439345400.1300496390.106497>, :process, #PID<0.137.0>,
 :normal}
:ok
```

In the above example, we launch a simple function to add two numbers and return
the PID. Monitoring the PID, we can then send an `:add` message to it, executing
the contained logic. Because the function terminates at the end of its
execution, it send any monitoring processes a message about its demise (the
four-element :DOWN tuple.)

### Listing and Demonitoring

To retrieve information about a process's links, you pass `:links` along with
the PID to `Process.info/2`. It doesn't matter which of the linked PIDs you
provide; as far as the BEAM is concerned, they're all linked processes and
caller is indistinguishable from the called. For monitored processes, however,
it _does_ matter. Therefore, instead of a single option to return all associated
PIDs, you need to pass either `:monitors` or `:monitored_by` to
`Process.info/2`.

`Process.info(pid, :monitors)` will return a list of PIDs a process monitors,
while `Process.info(pid, :monitored_by)` will return the PIDs monitoring the
process.

```elixir
iex > pid = spawn(fn -> receive do :doit -> IO.puts "did it" end end)
#PID<0.151.0>

iex > ref = Process.monitor(pid)
#Reference<0.491563884.3751280642.219239>

iex > Process.info(self, :monitors)
{:monitors, [process: #PID<0.151.0>]}

iex > Process.info(pid, :monitored_by)
{:monitored_by, [#PID<0.134.0>]}
```

Demonitoring a process performs a function similar to unlinking one. By passing
a reference to the `Process.demonitor/2` function, you remove that process from
the list of monitored processes.

If we continue where we left off in our previous IEx session:

```elixir
iex > Process.demonitor(ref)
true

iex > Process.info(self, :monitors)
{:monitors, []}

iex > Process.info(pid, :monitored_by)
{:monitored_by, []}
```

## Conclusion

If you are doing anything mildly complicated with Elixir, that is to say, if
you're working with real data, third party services, networks, or humanity, you
will have processes die. There's no escape. And while there is no escaping
process death, there are alternatives to "letting them crash."

In Elixir, as in Erlang, processes can be either linked together or set up to be
monitored. When processes are linked, they all share the same fate. If one dies,
they all die&mdash;unless they trap the exit message. On the other hand, when
processes are monitored, they notify their monitor of their demise. In each
case, you can put logic in place to to handle the termination intelligently. But
which should you choose: links or monitors? "If the intent is that a failure in
one process should terminate another, then you need links. If instead you need
to know when some other process exits for any reason, choose monitors."
([Programming
Elixir](https://www.goodreads.com/book/show/40654424-programming-elixir-1-6)(PE
209))

For processes, death is not the end, or at least it doesn't have to be. "[Ladies
and gentlemen], we can rebuild [them]. We have the technology. We have the
capability..." Maybe that's a conversation for the future.
