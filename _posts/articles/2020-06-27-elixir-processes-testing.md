---
title: "Elixir Processes: Testing"
date: 2020-06-27T10:08:15-05:00
draft: false
description: "Thinking in processes is already difficult; writing automated tests for those processes shouldn't make it worse. Elixir provides the necessary tooling to ensure your processes are rock solid. This article explains how to use them."
comments: false
post: true
categories: [elixir, processes, concurrency, testing]
---

Testing is easy. It's so easy, in fact, that every developer does it. Not only
that, but every developer ever has been practicing TDD since they began
programming. TDD, after all, is having an expectation and writing code to meet
those expectations. And if that's true, tests can amount to working in a REPL
to make sure your work performs the way you expect, having a scratch file you
use to test your changes against, or even building the whole application each
time you make changes and observing the results. Without those expectations, how
would you know what to do? And without those "tests", how would you know if your
expectations were met?

So, yes, testing is easy. What's hard, is writing _automated_ tests. It's
harder, because it demands you to be precise in how you define your
expectations. It's harder, because it forces you to think clearly about how all
the components fit together ahead of time. It's harder, because automated tests
are easier to write when functions are small, requiring you to write more of
them. It's harder, because it "feels" slower. Then you start a refactor with
automated tests and it dawns on you: it's easier.

Getting to the point where you see that TDD is faster than your previous habits
requires a fundamental shift in your understanding about development. It's much
the same as learning Object Oriented Programming, Functional Programming, or –
as in the case of Elixir – Concurrent Programming. When you first began writing
Elixir, you most likely found yourself mimicking articles, books, and videos –
and probably slipping back into your last language – rather than programming
from your own understanding. It's only with time and effort that you began to
learn to think in processes. Thankfully, it doesn't take nearly the amount of
work to learn how to test processes.

## Starting and Stopping Processes for Testing

The first problem you'll meet testing processes is starting and stopping
them within tests. Your initial inclination might be to start them as you would
in your application with `spawn`, `start_link`, or some other method, but can
you guarantee that the process in one test won't interfere with that same
process in another? To combat that eventuallity, ExUnit comes with the
`start_supervised/2` function which you should use instead of manually starting
your testable processes.

> The advantage of using start_supervised! is that ExUnit will guarantee that
> the registry process will be shutdown before the next test starts. In other
> words, it helps guarantee that the state of one test is not going to interfere
> with the next one in case they depend on shared resources.
> – [Elixir
> Guides](https://elixir-lang.org/getting-started/mix-otp/genserver.html#testing-a-genserver)

This is the "rundown of the life-cycle of the test process:"
([ExUnit](https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html))

1. the test process is spawned
2. it runs setup/2 callbacks
3. it runs the test itself
4. it stops all supervised processes
5. the test process exits with reason :shutdown
6. on_exit/2 callbacks are executed in a separate process

When you start your process using `start_supervised/2`, you'll do it in steps 2
or 3. `start_supervised` then attaches your process to ExUnit's test supervisor.
Once your test has run, ExUnit ensures the–now supervised–process is properly
shut down (step 4).

Let's look at an example of how this might work.

### `ExUnit.Callbacks.start_supervised/2`

Below you'll find a basic GenServer which returns its state, an empty list
`[]`. It doesn't need to do anything more, because we're interested in how
`start_supervised/2` works. As you can see, it has a single public function in
its API, `list/0`, to return the state. It does this by sending the `:list`
message to the `handle_call/3` function.

```elixir
defmodule Listless do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end
end
```

And here's how we might test this.

```elixir
defmodule ListlessTest do
  use ExUnit.Case, async: true

  test "Listless.list/0 returns an empty list" do
    start_supervised(Listless)

    assert Listless.list == []
  end
end
```

In this simple test, we pass `Listless` to `start_supervised/2`, but it also
accepts the same arguments you would give to a Supervisor:

- Module: `start_supervised` attempts to call `start_link` with an empty list.
- Module/Value tuple: `start_supervised/2` calls `start_link` with the provided
  value.
- `Supervisor.child_spec()`: By providing a complete `child_spec`, you give the
  id, name, initialization function, and arguments to initialize your process.

What's most interesting to note here is that we don't need to stop the
`Listless` process at the end of the test. ExUnit handles that for us.

Because `start_supervised/2` places the process under supervision, we can test
how our processes handle unexpected exits and how they recover. In this next
test, we kill our supervised process – which is then restarted – and we're still
able to test against it.

```elixir
defmodule ListlessTest do
  use ExUnit.Case, async: true

  test "Listless.list/0 returns an empty list" do
    {:ok, pid} = start_supervised(Listless)

    Process.exit(pid, :normal)

    assert Listless.list == []
  end
end
```

This is all great, but what would happen if the Listless GenServer was part the
main application supervision tree? Would the `start_supervised/2` function work?
And if it did (which it won't), would you be testing the process from the test
or the one from the main supervision tree? To that end, it's always a good idea
to allow your GenServers to be named. You can do so like this:

```elixir
defmodule Listless do
  use GenServer

  def start_link(arg, opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, arg, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def list(name \\ __MODULE__) do
    GenServer.call(name, :list)
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end
end
```

We're naming the GenServer process with a provided value or defaulting to
the module name (Listless). We've also updated the `list/0` function to accept
an optional name. With the above changes we could start Listless with a new
name like this:

```elixir
Listless.start_link([], name: Unlisted)
```

More importantly, we can give a `Supervisor.child_spec()` in our tests and
avoid conflicting with the Listless process running in our main supervision
tree. Here's our test with the new changes:

```elixir
defmodule ListlessTest do
  use ExUnit.Case, async: true

  test "Listless.list/0" do
    child_spec = %{
      id: Unlisted,
      start: {Listless, :start_link, [[], [name: Unlisted]]}
    }

    pid = start_supervised!(child_spec)

    assert Listless.list(Unlisted) == []

    # -- or -- #

    assert Listless.list(pid) == []
  end
end
```

With the changes made, we must now give more information to
`start_supervised/2`, including an `:id` and the `:start` specification, but we
no longer need to worry about conflicts.

### When Not to Use `start_supervised/2`

You don't always need test your processes under a supervisor, because you don't
always need to run processes to test their functions. We needed to start a
process for the `Listless.list/0` test, because `list/0` had no other means to
access the "state" of the GenServer. If we were to test the `handle_call`
function, however, would the same be true? It wouldn't. Because `handle_call/3
accepts state as an argument, we can test it like this:

```elixir
defmodule ListlessTest do
  use ExUnit.Case, async: true

  test "Listless.handle_call/3 :: :list" do
    state = [1, 2, 3]
    response = Listless.handle_call(:list, nil, state)

    assert {:reply, state, state} = response
  end
end
```

As you can see, we're providing the "state" to the function in the test, so
starting the GenServer doesn't help us do anything beyond what we're already
doing. Your tests should require as little integration as possible in order to
pass.  These are the only times you need to start a process for testing:

- You can't give the function under test the necessary state
- The process initialization does something which is not easy or desirable to
  duplicate in the test, but which is necessary for the test to pass

Now that we've seen how to start processes under supervision during tests, it's
time to turn our attention to removing them from supervision.

### `ExUnit.Callbacks.stop_supervised/1`

Going on name alone, you would think you would use `stop_supervised/1` at the
end of tests to make sure processes are, well, stopped. However, we've already
discussed how "ExUnit ensures the–now supervised–process is properly
shut down (step 4)." If we don't need `stop_supervised/1` to stop processes,
what does it do?

> You only need to use stop_supervised/1 if you want to remove a process from
> the supervision tree in the middle of a test, as simply shutting down the
> process would cause it to be restarted according to its :restart value.
> - https://hexdocs.pm/ex_unit/ExUnit.Callbacks.html#start_supervised/2

From this, it's clear that `stop_supervised/1` both removes a process from the
supervision tree and causes it to exit. The question, then, is why or when would
you use this?

After looking through the code bases of Elixir, Ecto, Phoenix, Absinth, and then
doing a more general search of GitHub itself, it's clear that you almost
never will. The one instance I can think of where you would use this is working
with multiple processes. In this instance you may wish to test the durability of
your system by being able to terminating one those processes, ensuring the
remaining one behaves appropriately.

## Assertions for Processes

Elixir uses the [Actor Model](https://en.wikipedia.org/wiki/Actor_model) for
concurrency. Rather than sharing memory between processes, it shares nothing and
instead relies on message passing. Until now, we've looked at how to start and
stop processes for testing and discussed when it's suitable to start a process
to test it. Now we can look at the tools
[ExUnit](https://hexdocs.pm/ex_unit/master/ExUnit.html) provides us for testing
message passing between processes, namely `assert_receive/3` and
`assert_received/2`.

These assertions are nearly identical, with the exception that
`assert_receive/3` accepts an optional timeout value (it defaults to 100ms). But
it's this timeout which distinguishes these two functions from one another, and
more specifically, when and how you should use them.

### `assert_received/2`

The `assert_received/2` macro "[a]sserts that a message matching pattern was
received and is in the current process' mailbox." ([ExUnit
Assertions](https://hexdocs.pm/ex_unit/ExUnit.Assertions.html#assert_received/2))
The implication here is that the function sending the message must finish,
having either sent the correct message or failed. The way to make sure functions
send messages _before_ we test them is for those functions to do their work
synchronously. Examples of this would be functions which call out to
`GenServer.handle_call/2` or simply functions which send messages back to the
calling process.

### `assert_receive/3`

If `assert_received/2` is designed to work with synchronous functions, it stands
to reason that `assert_receive/3` is best suited to asynchronous functions.
This explains why `assert_received` comes equipped with a timeout argument. With
this argument the idea is that the function under test will respond with a
message at some time in the future. `assert_receive/3` waits on that message for
the amount of time specified by the timeout or the default 100ms.

### Assertion Examples

To show the use of `assert_received/2` and `assert_receive/3`, let's
create a new – albeit useless – GenServer. It will have two externally facing
functions, `sync_message/2` and `async_message/2`, which send messages to the
GenServer functions, `handle_call/3` and `handle_cast/2` respectively. The
"handle" functions in turn send messages back to the calling process values of
either `:synchronous` or `:asynchronous`. Here's our `Unsyncable` GenServer:

```elixir
defmodule Unsyncable do
  use GenServer

  @me __MODULE__

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: @me)
  end

  def init(state) do
    {:ok, state}
  end

  def sync_message(pid) do
    GenServer.call(@me, {pid, :sync_message})
  end

  def async_message(pid) do
    GenServer.cast(@me, {pid, :async_message})
  end

  def handle_call({pid, :sync_message}, _from, state) do
    send pid, :synchronous

    {:reply, state, state}
  end

  def handle_cast({pid, :async_message}, state) do
    Process.sleep 100

    send pid, :asynchronous

    {:noreply, state}
  end
end
```

Our two externally facing functions take a single argument, `pid`, which our
module will use to know where to send messages. The "handle" functions both send
a message back to the calling process; `handle_cast/2` doing so after waiting
100 milliseconds.

Let's look at the tests.

```elixir
defmodule UnsyncableTest do
  use ExUnit.Case
  doctest Useless

  setup do
    start_supervised!(Unsyncable)

    :ok
  end

  test "Unsyncable.sync_message/1" do
    Unsyncable.sync_message(self())

    assert_received :synchronous
  end

  test "Unsyncable.async_message/1" do
    Unsyncable.async_message(self())

    assert_receive :asynchronous, 200
  end
end
```

Because we're testing the functions which make up the API, we need to start our
Genserver for each test. We can do that with the `start_supervised!/2` function
we learned about earlier.

In our first test, we send the test process's PID to `Unsyncable.sync_message/1`
and test that we received it. The function returns when the message is finally
sent back to the test process, and so our assertion is guaranteed to be
truthy. If we had called `async_message/2` instead, our assertion would be
false, because the `handle_cast/2` function wouldn't have had been able to send
a message back quickly enough. Even without using `Process.sleep/1`, the test
would have failed.

Our second test is similar to the first, with the exception that we are giving
ourselves a 200 millisecond grace period to make sure our function has time to
respond.

Note that unlike our first test, if we instead tested `sync_message/1` using
`assert_receive/3`, it would still pass. The question the arises: why not always
use `assert_receive/3`? The answer is that our assertions should align with our
expectations. You could still use `assert_receive/2`, but you should define the
timeout to be `0` to communicate your expections: that you expect the response
to by synchronous.

Since we're testing message passing you don't need to use either
`assert_receive/3` or `assert_received/2`, you could, instead, wrap an assertion
in a `receive` block:

```elixir
  test "Unsyncable.sync_message/1" do
    Unsyncable.sync_message(self())

    receive do
      :synchronous -> true
      _ -> false
    end
  end

  test "Unsyncable.async_message/1" do
    Unsyncable.async_message(self())

    receive do
      :asynchronous -> true
      _ -> false
    after
      200 -> false
    end
  end
```

You _could_ do that, but don't.

## Conclusion

You don't always have to do things the hard way. It's difficult enough to
program with processes in mind. It's even harder if you're trying to write tests
first. So don't. You know what you want to happen, so program against those
expectations. Then, when you have things working, go back and write your tests
to cover what you've done. Later, once you're gained a process-oriented mindset,
writing tests first will be easier.

Thankfully, the actor model makes it easier to think about processes, and Elixir
provides the necessary functions and macros to simplify testing those processes.
With `start_supervised/2` and `stop_supervised/1` we make sure our processes are
properly shut down, avoid conflicts, and give us finer control over when they
stop. The "assert" macros, `assert_received/2` and `assert_receive/3`, give us
simple tools to work with messages sent by processes; whether they're sent
synchronously or asynchronously. The only "hard" thing left to do is being
consistent about writing tests, but you're already doing that, right?
