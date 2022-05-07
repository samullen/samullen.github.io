---
title: "Elixir Processes: Spawn, Send, and Receive"
date: 2019-12-08T15:15:21-06:00
draft: false
description: "All of OTP is built on a handful of process primitives. In this article, we'll explore three in particular – spawn, send, and receive – to see how they work together."
comments: false
post: true
categories: [elixir, processes, otp]
---

I love reading science fiction. It doesn't matter if it strictly adheres to
science or if it's a romp with laser sword wielding space wizards. I read it for
the stories, the ideas, the possibilities of what could be, and to get a glimpse
of something truly alien. One oft-recurring theme in sci-fi is that of the [hive
mind](https://en.wikipedia.org/wiki/Group_mind_(science_fiction)). In these
stories, the protagonist spends the bulk of the adventure trying to understand
why attempts to interact with an alien species continually fail ("interact"
usually means, "blast the alien scum into space goo"). Eventually our intrepid
hero or heroine discovers the aliens operate collectively and then proceeds to
have a successful interaction with the "queen" and save the day.

In the book, [_Ender's
Game_](https://www.goodreads.com/book/show/375802.Ender_s_Game), humanity is
facing off against one such species, affectionately known as "Buggers".
Both species are able to communicate across vast distances with their respective
fleets in near real-time efficacy, but the difference is in _what_ gets
communicated. In the case of the Buggers, the queen communicates to direct and
control each of her drones. Humanity, on the other hand, communicates
instructions, allowing each ship to determine how best to carry out those
instructions.

If we were to draw similarities between the two species in _Ender's Game_ and
programming concurrency models, we could imagine how the Buggers might represent
the traditional concurrency model, while humanity would represent the [actor
model](https://en.wikipedia.org/wiki/Actor_model). In the former, shared memory
is that central mind which thread and processes depend on, and which if
corrupted in some way would result in serious problems for every associated
thread. On the other hand, just like humanity's starships, nothing is shared
between processes in the actor model. This allows each to operate independently,
without concern for affecting other processes.

Benjamin Tan Wei Hao simplifies the behavior of the actor model – used by Erlang
and Elixir – in these five points:

> - Each _actor_ is a _process_.
> - Each process performs a _specific task_.
> - To tell a process to do something, you need to _send it a message_. The
>   process can reply by _sending back another message_.
> - The kinds of messages the process can act on are specific to the process
>   itself. In other words, messages are _pattern-matched_.
> - Other than that, processes _don't share any information_ with other
>   processes.
>
> [The Little Elixir & OTP Guidebook](https://www.goodreads.com/book/show/25563811-the-little-elixir-otp-guidebook)

With this in mind let's explore Elixir's concurrency primitives.

## Processes

The basic unit of concurrency in Elixir is the process. If you're not already
familiar with processes in Elixir or Erlang, they operate differently than other
languages you may have experience with.

> ...when we talk about processes in Elixir, we are not talking about native
> operating-system processes. These are too slow and bulky. Instead, Elixir uses
> process support in Erlang. These processes will run across all your CPUs (just
> like native processes), but they have very little overhead."
>
> [Programming Elixir](https://www.goodreads.com/book/show/17971957-programming-elixir)

The BEAM accomplishes this by running in a single OS process. From there, it
creates a "scheduler" for each available CPU core – each running in its own
thread. It's these schedulers which manage the creation and execution of Elixir
processes.

> It takes only a couple of microseconds to create a single process, and its
> initial memory footprint is a few kilobytes. By comparison, OS threads usually
> use a couple of megabytes just for the stack. Therefore you can create a large
> number of processes: the theoretical limit imposed by the VM is roughly 134
> million!
>
> [Elixir in Action](https://www.goodreads.com/book/show/38732242-elixir-in-action-second-edition)

See for yourself:

```elixir
spawn(fn -> IO.puts "Hello, World!" end)
|> Process.info(:memory)
```

On my machine, this returns the tuple: `{:memory, 2688}`. 2,668 is
"...the size in **bytes** of the process. This includes call stack, heap, and
internal structures." [Erlang - process_info](http://www.erlang.org/doc/man/erlang.html#process_info-1)

Let's look closer at creating processes.

### Spawn

Creating an Elixir process requires the use of `spawn/1` or `spawn/3`. The
former accepts an anonymous function as its argument (as we've just seen), while
the latter takes a Module, function name, and a list of arguments (MFA). In both
cases, `spawn` returns the PID (Process ID) to the calling process.

Let's look at a couple examples. Open up IEx and type in the following:

```elixir
iex > spawn(fn -> IO.puts("Hello, Alpha Centauri!") end)
```

You'll see something like this output to the screen:

```
#PID<0.2866.0>
Hello, World!
```

We'll see a similar response using `spawn/3`:

```elixir
iex > spawn(IO, :puts, ["Hello, Alpha Centauri!"])
```

In both cases, Elixir spawns a new process and executes the specified function
inside it, but that's all it does. There's no return value beside the PID;
there's no success or failure message; the child process can only perform its
given task; and once started, the parent process has no idea what's going on
inside the child process (to which I can completely relate).

Thankfully, as part of the actor model, processes are able to communicate with
other processes via "messages". The receiving processes can return
messages in kind or send messages to still other processes.

### Sending and Receiving Messages

Sending messages to processes in Elixir is easy. All we need is the process ID
(PID) and a message to send. We can try this out in IEx:

```elixir
iex > send(self(), :hi)
:hi
```

What we've done here is send the message, `:hi`, to our current IEx session. The
`send/2` function returns the message we sent, but nothing else
_appears_ to have happened. Where did the message go? Did it disappear into the
void? Was it sent to `/dev/null`? Did it "run down the curtain and [join] the
bleedin' choir invisible"? Or is it stored somewhere? The answer, as you may
have guessed, is that messages are stored in the process mailbox until the
process "receives" them. We can see that using `Process.info/2`.

```elixir
iex > Process.info(self(), :messages)
{:messages, [:hi]}
```

To retrieve the message from the IEx process's mailbox, we need to "receive" it,
with the `receive/1` macro:

```elixir
iex > receive do :hi -> IO.puts "Hello." end
Hello.
:ok
iex > Process.info(self(), :messages)
{:messages, []}
```

The `receive/1` function matches against the `:hi` atom, and, once matched,
executes the corresponding function. What do you think would happen if we tried
running our `receive` function again?

If you were to run the `receive` function again, your IEx session would hang
until terminated, which is why it's a good idea to include an `after` clause
when working with `receive/1`.

```elixir
receive do
  :hi ->
    IO.puts "Hello!"
after
  0 ->
    IO.puts "Message not found"
end
```

The `after` clause takes a timeout value of either `:infinity` or an integer
between 0 and 4,294,967,295 (49.7 days). Setting the value to 0 allows the receive block to
return immediately, while any other value will wait that amount of milliseconds.

With the basics out of the way, let's see how we would use `spawn/3`, `send/2`,
and `receive/1` together. We'll start with a simple module to print a salutation
to the screen:

```elixir
defmodule Salutator do
  def run do
    receive do
      {:hi, name} ->
        IO.puts "Hi, #{name}"
      {_, name} ->
        IO.puts "Hello, #{name}"
    end
  end
end
```

By including a `receive` block, we've primed the `Salutator` module for use
as a process. We just need to `spawn/3` it:

```elxiir
iex > pid = spawn(Salutator, :run, [])
```

With `Salutator` running, we are now free to send it messages:

```elixir
iex > send(pid, {:hi, "Mark"})
{:hi, "Mark"}
Hi, Mark
iex > send(pid, {:hello, "Suzie"})
{:hello, "Suzie"}
```

Notice that the second time we sent `Salutator` a message, it didn't return the
expected results. Remember, `receive/1` is a normal function (well, macro). Once
it's run, it's done. To get `run/0` to receive more than one message, we'll have
to call it again. We can do that with recursion. Here's our new module and
function:

```elixir
defmodule Salutator do
  def run do
    receive do
      {:hi, name} ->
        IO.puts "Hi, #{name}"
      {_, name} ->
        IO.puts "Hello, #{name}"
    end

    run() # <- Recursion FTW!
  end
end
```

Now we can create an unlimited number of (fairly uninteresting) salutations.
What we haven't seen is how our spawned process can communicate back to the
calling process, or to any other process. We'll look at that shortly, but first,
let's look more closely at the mailbox.

### The Process Mailbox

We saw previously that messages are stored in a process's mailbox until it's
able to `receive` them. But why send messages to a process's mailbox instead of
calling the function directly? According to the [Elixir guide on
processes](https://elixir-lang.org/getting-started/processes.html), "The process
that sends the message does not block on `send/2`, it puts the message in the
recipient’s mailbox and continues." The receiving process is then able to
process messages from its mailbox according to its capacity, without needing to
communicate its progress to the originating process, and without hindering the
caller's progress.

> The receive expression works as follows
>
> 1. Take the first message from the mailbox.
> 2. Try to match it against any of the provided patterns, going from top to
>    bottom.
> 3. If a pattern matches the message, run the corresponding code.
> 4. If no pattern matches, put the message back into the mailbox at the same
>    position it originally occupied. Then try the next message.
> 5. If there are no more messages in the queue, wait for a new one to arrive.
>    When a new message arrives, start from step 1, inspecting the first message
> in the mailbox.
> 6. If the after clause is specified and no message is matched in the given
>    amount of time, run the code from the after block.
>
> Saša Jurić, _[Elixir in Action](https://www.goodreads.com/book/show/38732242-elixir-in-action-second-edition)_

Each process has its own mailbox which is limited only by the available memory.
This gives you a lot of room to play with, but it also gives you an ample amount
of rope with which to shoot yourself in the foot.

## Putting It All Together

So far, we've looked at spawning processes, sending and receiving messages in
isolation, and the process mailbox. Let's take what we've learned so far and
build something to demonstrate how each piece can work together. What we'll
build is a tool to take a dictionary of words, group those which are anagrams of
each other, and return a list of those matching three or more words. The output
will look like this:

```elixir
...
{"elmno", ["monel", "Monel", "melon", "lemon"]}
{"denopru", ["unroped", "repound", "pounder"]}
{"adegiillnntu", ["linguidental", "indulgential", "dentilingual"]}
{"aeelrs", ["sealer", "reseal", "resale", "reales", "leaser", "alerse"]}
{"aceilnp", ["pinacle", "pelican", "panicle", "capelin", "calepin"]}
...
```

The first element of the tuple is an alphabetical sorting of the anagrams
letters, and the second element list of those words which are anagrams of one
another.

To begin, we'll create a process to accumulate and group anagrammatical words.
Next, we'll create a module which will read words from the dictionary, create a
process for each word (235,886 words on my system, so that's 235,886 processes)
to parse and store the results in the accumulator. Here's the accumulator:

```elixir
defmodule Accumulator do
  def loop(anagrams \\ %{}) do
    receive do
      {from, {:add, {letters, word}}} ->
        anagrams = add_word(anagrams, letters, word)
        send(from, :ok)
        loop(anagrams) # must put loop/0 inside each match

      {from, :list} ->
        send(from, {:ok, list_anagrams(anagrams)})
        loop(anagrams)
    end
  end

  defp add_word(anagrams, letters, word) do
    words = Map.get(anagrams, letters, [])

    anagrams
    |> Map.put(letters, [word|words])
  end

  defp list_anagrams(anagrams) do
    anagrams
    |> Enum.filter(fn {k, v} -> length(v) >= 3 end)
  end
end
```

Our accumulator has two responsibilities: to add anagrams to the list and to
return the list when requested. These responsibilities are laid out in the
`receive` (lines 3-12) clause of the `loop/1` function. In both cases, the
`Accumulator` responds to the calling process via `send/2` (lines 6 and 10).
When adding words, it responds with `:ok`, while `:list` responds with a tuple
of `:ok` and the list of anagrams. The private functions, `add_word/3` and
`list_anagrams/1`, do exactly what their names suggest.

We start the `Accumulator` by spawning it:

```elixir
pid = spawn Accumulator, :loop, []
```

Our next module, `Anagrammar`, is the interface to `Accumulator`.

```elixir
defmodule Anagrammar do
  @dictionary "/usr/share/dict/words"

  def build_list(accumulator_pid) do
    words
    |> Enum.each(&(add_anagram(accumulator_pid, &1)))
  end

  def get_list(accumulator_pid) do
    send(accumulator_pid, {self, :list})

    receive do
      {:ok, list} ->
        list
        |> Enum.each(&IO.inspect/1)
    end
  end

  defp words do
    File.read!(@dictionary)
    |> String.split("\n")
  end

  defp add_anagram(accumulator_pid, word) do
    spawn(fn -> _add_anagram(accumulator_pid, word) end)
  end

  defp _add_anagram(accumulator_pid, word) do
    send(accumulator_pid, {self, {:add, parse(word)}})

    receive do
      :ok -> :ok
    end
  end

  defp parse(word) do
    letters =
      word
      |> String.downcase()
      |> String.split("")
      |> Enum.sort(&(&1 <= &2))
      |> Enum.join()

    {letters, word}
  end
end
```

There's a lot going on here, so let's break it down piece by piece. The
`build_list/1` function (line 4-7) is responsible for taking the words (lines
23-26) from our system's dictionary, parsing them (lines 40-49), and then
loading them into the accumulator (lines 32-38). It does this by creating a new
process for each word (lines 28-30). Note that when we send a message to our
accumulator on line 33, we expect an `:ok` response (lines 35-37) shortly
thereafter.

Getting a list is much easier; we provide `get_list/1` (line 9) with the
accumulator's PID. `get_list/1` then sends a message to the accumulator (line
10) and `recieve`s the response (lines 12-16).

Let's try it out. We already have the PID from our accumulator. All we need to
do is load the dictionary and get the list:

```
Anagrammar.build_list(pid)
Anagrammar.get_list(pid)
```

<aside class="panel panel-default pull-right col-md-6">
<h3>Well, actually...</h3>
<p>"1.2 seconds is slower than if you just did..."</p>

<p>"Yes, you're very smart. Shut up."<br>
- <small><i>Grandpa, <a href="https://www.imdb.com/title/tt0093779/">The Princess Bride</a></i></small>
</aside>

Executing both of those commands in sequence takes my system approximately 1.2
seconds. Not too shabby.

## Understand, but Don't Use.

Compared to other languages, working with processes in Elixir is a little
more difficult than adding a new function: they're small and fast, process
memory is isolated, and they're easy to reason about. But here's the thing,
"Typically developers do not use the spawn functions, instead they use
abstractions such as Task, GenServer and Agent, built on top of spawn, that
spawns processes with more conveniences in terms of introspection and
debugging." ([Elixir docs](https://hexdocs.pm/elixir/Kernel.html#spawn/1))

There are reasons to forego the use of GenServer, Task, and Agent, and Miriam
Pena goes into some of those reasons in her 2019 ElixirConf talk, ["Beam
Extreme: Don't Do This At Home"](https://www.youtube.com/watch?v=-1j36z8SllI).
In most circumstances, however, these modules are enough. Yes, by using process
primitives you can improve performance by 80%, but you do so at the expense
– and, arguably, your peril – of re-building what's already included in
GenServer, Task, and Agent.

The OTP abstractions are built on process primitives. By understanding how to
use the primitives, we begin to understand how OTP modules such as GenServer and
Task are built and what their limitations are. Of course, `spawn`, `send`, and `receive` aren't the only primitives available to us. In a future article, we'll
look at the other primitives and how we can use them to understand supervision.
