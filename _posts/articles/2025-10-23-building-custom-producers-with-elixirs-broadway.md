---
title: "Building Custom Producers with Elixir's Broadway"
date: 2025-10-23T00:00-05:00
draft: false
description: "A practical guide to building custom Broadway producers in Elixir using GenStage. Understand how demand works, how to prevent your pipeline from stalling, and how to use Process.send_after/3 to keep data flowing between your producer and Broadway consumer."
image: /assets/images/custom_broadway_producers/broadway_flow.png
comments: false
post: true
categories: [elixir, broadway]
---

<aside class="panel panel-default pull-right col-md-4">
If you're not familiar with Broadway, you should read my article,
<a href="https://samuelmullen.com/articles/understanding-elixirs-broadway">Understanding Elixir's Broadway</a> first.
</aside>

The thing about [Elixir](https://github.com/elixir-lang/elixir)'s
[Broadway](https://github.com/dashbitco/broadway) is that once you've used it,
you start seeing opportunities to use everywhere. We used it heavily at my
previous job, and it was my go-to tool for any continuous stream of data that
required concurrent processing.

Recently I decided to build a web crawler/scraper to pull in data for my side
project, [Makerplans](https://makerplans.io). I'd been using
[Crawly](https://github.com/elixir-crawly/crawly) with some success, but so many
sites are SPAs that it makes libraries like Crawly, which rely on full page
reloads, less useful.

I'll write more about building my crawler/scraper,
[Glutton](https://github.com/samullen/glutton), in a future article. For now, I want to focus on the first problem I ran into: getting custom Broadway producers to work.

## v1

The [Dashbit](https://dashbit.co) team did a great job documenting Broadway, and
they even have a page describing how to build
[Custom Producers](https://hexdocs.pm/broadway/custom-producers.html). It's what
I referenced while building the first version of Glutton's Producer (shown
below). On the surface, this appears to be doing everything the custom Producer
example is doing, but as we'll see, there's a problem.

```elixir
defmodule MyApp.URLProducer do
  use GenStage

  alias MyApp.URLQueue

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  @impl GenStage
  def init(_args), do: {:producer, []}

  @impl GenStage
  def handle_demand(demand, state) when demand > 0 do
    urls = URLQueue.pop(demand)

    {:noreply, urls, []}
  end
end
```

You'll notice first that the `URLProducer` uses the
[GenStage](https://github.com/elixir-lang/gen_stage) behavior. It's very
similar to the `GenServer` behavior with the exception of `init/1`'s return
value and the `handle_demand/2` functions. Whereas a `GenServer`'s `init/1` will
return an `{:ok, state}` tuple, Broadway expects its producers to return
`{:producer, state}`, which is what we do above.

`handle_demand/2` is very similar to `GenServer`'s `handle_call/3` or
`handle_cast/2` functions, except it, uh...handles...demand from consumers,
which is what your main Broadway module is.

Speaking of the Broadway consumer, let's make that:

```elixir
defmodule MyApp.Pipeline do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {MyApp.URLProducer, []},
        transformer: {__MODULE__, :transform, []},
        concurrency: 1
      ],
      processors: [
        default: [
          concurrency: 2,
          min_demand: 1,
          max_demand: 2
        ]
      ]
    )
  end

  def handle_message(:default, %Message{data: url} = message, _context) do
    message
    |> IO.inspect
  end

  def transform(url, _opts) do
    %Broadway.Message{
      data: url,
      acknowledger: Broadway.NoopAcknowledger.init()
    }
  end

  def ack(_ref, _successes, _failures) do
    :ok
  end
end
```

<aside class="panel panel-default pull-right col-md-4">
  ProTip: Not setting concurrency will default to <code>System.schedulers_online()
  * 2</code>. On my machine that's 16 and it absolutely crushed it as a web
  crawler once I had everything running.

  <img src="{{ site.url }}/assets/images/custom_broadway_producers/load.png" class="img-thumbnail img-responsive" alt="load" title="Load">
</aside>

This is a standard Broadway consumer, so if you've used Broadway before, this
should look familiar. I kept the concurrency and demand low because each Glutton
process runs a headless Chrome browser, and processing is already slow enough
that higher demand isn't necessary.

Lastly, we need a "queue" from which our custom producer can draw. We can do
that with a simple `GenServer`.

<div class="clearfix"></div>

```elixir
defmodule MyApp.URLQueue do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def push(url) do
    GenServer.cast(__MODULE__, {:push, url})
  end

  def pop(count) do
    GenServer.call(__MODULE__, {:pop, count})
  end

  def list() do
    GenServer.call(__MODULE__, :list)
  end

  @impl GenServer
  def init(_args), do: {:ok, []}

  @impl GenServer
  def handle_cast({:push, url}, state) do
    {:noreply, [url | state]}
  end

  @impl GenServer
  def handle_call({:pop, count}, _from, state) do
    {urls, new_state} = Enum.split(state, count)
    {:reply, urls, new_state}
  end

  @impl GenServer
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end
end
```

<aside class="panel panel-default pull-right col-md-4">
  ProTip: In a real-world project, you'd want to use Erlang's
  <code>:queue</code> module instead of a <code>List</code>.
</aside>

It's a straightforward `GenServer`. `state` is just a list to which we can add
URLs (`push/1`), remove the next one (`pop/0`), or get the current contents of
the queue (`list/0`).

<div class="clearfix"></div>

### Running v1

If you were to start these processes up...

```
iex(1)> MyApp.URLQueue.start_link([])
{:ok, #PID<0.196.0>}
iex(2)> MyApp.Pipeline.start_link([])
{:ok, #PID<0.198.0>}
```

...and add items to the queue...

```
iex(3)> MyApp.URLQueue.push("http://example.com")
:ok
iex(4)> MyApp.URLQueue.push("http://example.com")
:ok
iex(5)> MyApp.URLQueue.push("http://example.com")
:ok
iex(6)> MyApp.URLQueue.push("http://example.com")
:ok
iex(7)> MyApp.URLQueue.push("http://example.com")
:ok
```

...you'd notice that...uh...nothing happens.

Hmmm. Okay. What happens if you add items to the queue before starting the
Broadway consumer?

```elixir
iex(1)> MyApp.URLQueue.start_link([])
{:ok, #PID<0.196.0>}
iex(2)> MyApp.URLQueue.push("http://example.com")
:ok
iex(3)> MyApp.URLQueue.push("http://example.com")
:ok
iex(4)> MyApp.Pipeline.start_link([])
{:ok, #PID<0.198.0>}
```

Now you'll see...

```elixir
%Broadway.Message{
  data: "http://example.com",
  metadata: %{},
  acknowledger: {Broadway.NoopAcknowledger, nil, nil},
  batcher: :default,
  batch_key: :default,
  batch_mode: :bulk,
  status: :ok
}
%Broadway.Message{
  data: "http://example.com",
  metadata: %{},
  acknowledger: {Broadway.NoopAcknowledger, nil, nil},
  batcher: :default,
  batch_key: :default,
  batch_mode: :bulk,
  status: :ok
}
```

...but if you were to add more URLs to the queue, nothing else happens. What
gives?

### The Problem in v1

As mentioned at the beginning of this section, there was a problem in the way
I initially wrote the producer: I followed the documentation. While the Broadway
documentation for
[Custom Producers](https://hexdocs.pm/broadway/custom-producers.html) is useful,
it falls short in describing how to handle instances where data isn't always
available to retrieve (i.e. what happens when you've processed everything?) In
their `Counter` example, they provided the following function for handling
demand from the Broadway Consumer:

```elixir
def handle_demand(demand, counter) when demand > 0 do
  events = Enum.to_list(counter..counter+demand-1)
  {:noreply, events, counter + demand}
end
```

Notice that when there is demand, this function returns both a list of
integers&mdash;which is always available since it generates the list
itself&mdash;and updates state. There's never a scenario when this function
won't be able to handle demand. But in our app, it's likely, and even expected,
to run out of URLs to crawl. What's going on?

In response to this very problem brought up in
[a GenStage issue](https://github.com/elixir-lang/gen_stage/issues/80), José
explained that if a consumer (our `Pipeline`) sends demand and the producer
(`URLProducer`) can't serve that demand immediately, the producer should "store"
that demand until it's able to fulfill it.

The mistake I made was thinking the consumer would continually ask its producers
for data. It doesn't. It asks once and expects its producers to fulfill that
demand whenever they’re able. Because our `handle_demand/2` function only runs
when a request is made from the consumer, and the consumer is only going to ask
once until demand is fulfilled, our app stalled out.

The way to fix that is to make our `URLProducer` keep checking the `URLQueue`
for data.

## v2

Here's the second version of `URLProducer`.

```elixir
defmodule MyApp.URLProducer do
  use GenStage

  alias MyApp.URLQueue

  @receive_interval 5_000

  def start_link(args) do
    GenStage.start_link(__MODULE__, args)
  end

  @impl GenStage
  def init(_args), do: {:producer, %{demand: 0}}

  @impl GenStage
  def handle_demand(incoming_demand, state) when incoming_demand > 0 do
    schedule_receive_messages(0)

    {:noreply, [], %{state | demand: state.demand + incoming_demand}}
  end

  @impl GenStage
  def handle_info(:receive_messages, state) do
    case URLQueue.pop(state.demand) do
      urls when is_list(urls) and length(urls) > 0 ->
        {:noreply, urls, %{demand: state.demand - length(urls)}}

      [] ->
        schedule_receive_messages(@receive_interval)
        {:noreply, [], state}
    end

  end

  defp schedule_receive_messages(interval) do
    Process.send_after(self(), :receive_messages, interval)
  end
end
```

There are several changes of which to take note. The first is state. Previously,
we were just passing around an empty list, because we were completely handling
demand on each request. Now we want to keep track of demand and to do so, we'll
store it in a map. We could keep track of it as an integer, but in most cases,
you'll also want to keep track of a buffer of data. For example:

```elixir
%{urls: [], demand: 2}
```

The next thing to notice is that instead of retrieving URLs from the queue in
`handle_demand/2`, we're calling `schedule_receive_messages/1`. This
function&mdash; along with `handle_info/2` which handles the sent message,
`:receive_messages`&mdash; sets up an asynchronous loop to continually pull data from
`URLQueue`. It responds with data if it's able to fulfill demand; otherwise, it
schedules itself to check again in five seconds (`@receive_interval`.) Without
`schedule_receive_messages/1`, and `Process.send_after/3`, our producer would
stay idle after the first time it was unable to address demand. Using it allows
the producer to continuously check for new work asynchronously.

Everything else remains the same. If we were to launch our app again and add
URLs to the queue, we'd see that our `Pipeline` consumer outputs data within
five seconds of data getting added to the `URLQueue`.

```elixir
iex(1)> MyApp.URLQueue.start_link([])
{:ok, #PID<0.196.0>}
iex(2)> MyApp.Pipeline.start_link([])
{:ok, #PID<0.198.0>}
iex(3)> MyApp.URLQueue.push("http://example.com")
:ok
iex(4)> MyApp.URLQueue.push("http://example.com")
:ok

%Broadway.Message{
  data: "http://example.com",
  metadata: %{},
  acknowledger: {Broadway.NoopAcknowledger, nil, nil},
  batcher: :default,
  batch_key: :default,
  batch_mode: :bulk,
  status: :ok
}
%Broadway.Message{
  data: "http://example.com",
  metadata: %{},
  acknowledger: {Broadway.NoopAcknowledger, nil, nil},
  batcher: :default,
  batch_key: :default,
  batch_mode: :bulk,
  status: :ok
}
```

The Broadway library is one of Elixir's unsung heroes. It's lightweight, easy to
use, and its processing capabilities are unparalleled (Because they run
concurrently. Get it? Ugh, that was so dumb.) Once you've figured out how to use
it to solve one problem, you start seeing lots of places where Broadway is a
good fit, but some of those problems are going to require a custom Producer.

As we've seen, custom producers are easy to build, but unless they themselves
are the data generators, it can be a little tricky to keep them providing data
to the Broadway consumer. To get around that, we used a combination of
`Process.send_after/3` and `GenStage`'s `handle_info/2`.

I kept the code in this article as simple as possible. To see examples of more
robust solutions, I encourage you to look at the code for both the
["Official" and "Off-Broadway" producers](https://hexdocs.pm/broadway/introduction.html#official-producers).

In the next article, we'll build on this foundation and use Wallaby to start crawling websites.
