---
title: "Elixir Telemetry: Metrics and Reporters"
date: 2019-09-02T15:52:18-05:00
draft: false
description: "For measurements to be valuable, they must be collated into metrics. Elixir's Telemetry.Metrics library enables us to aggregate measurements from functions and processes into valuable metrics to aid us in making decisions about our projects."
comments: false
post: true
categories: [elixir, telemetry, metrics, data]
---

> A text without a context is a pretext.
> – D. A. Carson

If I were to give you a graph with a single point on it and ask you to extract
trending information from it, you'd think I'd gone mad. With only a single point
of data, how could anyone extract anything meaningful from it? And yet we do it
all the time. We extrapolate meaning from a single occurrence ignoring the
larger context.

<img src="https://samuelmullen.com/images/telemetry-metrics/measurement.png" class="img-thumbnail img-responsive" alt="Graph of single measurement" title="Graph of single measurement">

After seeing a friend's post on social media, haven't we all caught
ourselves thinking that our friend's life seemed to be so much more exciting
than our own? Or what about the stock market? As I write this, we appear to be
entering a recession, and because of this, how many people are pulling their
money out of the market fearing things will only get worse?

However, when we take a step back to incorporate information from more than a
single source or a snapshot in time we gain perspective and see emerging
patterns. After all, people rarely share their fears, failures, and struggles on
social media – at least, not genuinely – and the stock market is cyclical with
regard to recessions, and bull and bear markets.

In my last article, [The "How"s, "What"s, and "Why"s of Elixir Telemetry](https://samuelmullen.com/articles/the-hows-whats-and-whys-of-elixir-telemetry/),
we looked at the value of monitoring our projects, how to do so with
[Telemetry](https://github.com/beam-telemetry/telemetry), and the dangers of
tracking the wrong metrics. After reading the article, however, you may have
struggled to determine what to do with the data you captured.

Monitoring and capturing data is only part of the equation. In this article,
we'll look at the difference between measurements and metrics, what makes a good
metric, things to keep in mind when choosing metrics, and finally how to start
capturing metrics with Elixir's
[Telemetry.Metrics](https://github.com/beam-telemetry/telemetry_metrics)
library.

## What's a Metric?

"Metric" is a difficult word to define and is oftentimes confused with
"measurement". Whereas a measurement is a unit-specific value for something
(e.g. length, duration, volume, etc), a metric is used to track and assess
measurements (e.g. summaries, averages, distributions, etc.)

As explained in the book, "[Lean Analytics](https://www.goodreads.com/book/show/16033602-lean-analytics)",
there are four rules of thumb for what makes a good metric:

### A Good Metric is Comparative

Perhaps this is obvious since measuring implies comparison, but it's not
uncommon to erroneously compare two unrelated metrics. Benchmarks are excellent
examples of a good comparison, because you are comparing two similar things such
as comparable libraries or different versions of the same library. A poor
comparison might be lines of code written by two different developers: who can
write more doesn't translate to something valuable.

### A Good Metric is Understandable

Programmers understand terms like "code complexity", "technical debt", and
"refactoring", but most people don't. While complexity can be quantified – sort
of – technical debt can't be, because it must be compared to an unknowable ideal
version of the software. When choosing a metric to track, choose those which can
be reasoned about and understood. "If people can't remember [the metric] and
discuss it, it's much harder to turn a change in the data into a change in the
culture."

### A Good Metric is a Ratio or Rate

Unless the measurements you're tracking are grouped in some way all you're
really doing is collecting a bunch of numbers. Instead, we need to track our
metrics as they relate to time or resources. Examples of common ratios are
throughput (transactions per time period) and bandwidth (bits per available
resource). There are three reasons "ratios tend to be the best metrics":

- "Ratios are easier to act on."
- "Ratios are inherently comparative."
- "Ratios are also good for comparing factors that are somehow opposed, or for
  which there's an inherent tension."

### A Good Metric Changes the Way You Behave

Why do you want to monitor your processes? Is it to show off charts on Twitter
and to management? Or instead, is it to enable you to understand the health of
your project? As discussed in the previous article, "the whole point of
capturing metrics about your system is to enable you to make good decisions
about what to do next." Furthermore, good metrics change your behavior
"precisely _because_ [they're] aligned to your goals".

If merely capturing _measurements_ about our system isn't enough, and instead we
need to be capturing _metrics_, then what are we to do with the Telemetry
library?  After all, Telemetry only captures measurements. Thankfully, the
[Telemetry team](https://github.com/beam-telemetry) has provided us with a
library to help us think about the measurements and metrics we need to capture.

## Telemetry.Metrics

When I began exploring the `Telemetry.Metrics` library I made the mistake of
assuming it would accumulate metrics for me. I misunderstood the first sentence
on the README: "Telemetry.Metrics provides a common interface for _defining
metrics_ based on :telemetry events." (Emphasis: mine). `Telemetry.Metrics` does
little more than provide and validate the different metric types and offer unit
conversions for time-based measurements. This makes sense in retrospect: how
could the Telemetry team know the many different ways we would want to aggregate
data?

`Telemetry.Metrics` currently provides the following five metric types:

- **Telemetry.Metrics.Counter:** Used to keep a running count of the number of
  events.
- **Telemetry.Metrics.Sum:** Used to track the sum total of specific
  measurements.
- **Telemetry.Metrics.LastValue:** Use this metric to hold the measurement of
  the most recent event.
- **Telemetry.Metrics.Summary:** Used to track and calculate statistics of the
  selected measurement such as min/max, average, percentile, etc.
- **Telemetry.Metrics.Distribution:** Used to group event measurements into
  buckets

To start tracking one or more of the five metric types, you'll need to create a
reporter. To reiterate, in case you're as thick as I am:

> ...the metric definitions themselves are not enough, as they only provide the
> specification of what is the expected end-result. The job of subscribing to
> events and building the actual metrics is a responsibility of reporters. This
> is the crucial part of this library design - it doesn't aggregate events
> itself but relies on 3rd party reporters to perform this work in a way that
> makes the most sense for a particular monitoring system.

## Reporters

Building a reporter isn't difficult, and to demonstrate we'll build one to
capture metrics from `Plug.Telemetry`. When complete, we'll be able to include
our reporter in a Plug or Phoenix project, enabling it to capture the following
information:

- A running count of page views
- The sum total of bytes sent
- Show the most recent time the server took to build and send a "page"
- The min and max page build times
- A distribution of page build times

**Note:** This is strictly for demonstration purposes and should not be used
as-is for production purposes.

As covered in the
[Writing Reporters](https://hexdocs.pm/telemetry_metrics/writing_reporters.html)
documentation, a reporter has four responsibilities:

- It must accept a list of metric definitions when started
- It must attach handlers to the defined events
- It must extract and handle the measurements as events are emitted.
- It must detach event handlers when the reporter stops or crashes

We'll build our reporter using these responsibilities as our guide.

### Setup

Before we can even begin creating our reporter we'll need to install
`Telemetry` and set up `Plug.Telemetry`. First things first: add the following
to the `deps/0` function in your project’s mix.exs file

```elixir
defp deps() do
  [
    {:telemetry, "~> 0.4.0"},
    {:telemetry_metrics, "~> 0.3"},
  ]
end
```

With Telemetry installed, we are now free to include `Plug.Telemetry` in our
project's pipeline:

```elixir
defmodule MyApp.Router do
  use MyAppWeb, :router

  pipeline :browser do
    ...
    plug Plug.Telemetry, event_prefix: [:my_app, :plug]
    ...
  end

  ...
end
```

With the basics out of the way, we can start building our reporter.

### Accepting a List of Metrics

Although not necessary, it's recommended that "most reporters should be backed
by a process". With this in mind, we'll create our reporter as a GenServer.
First, however, we need to determine which events we want to capture. Since this
is a tutorial, let's go ahead and capture them all.

In the `start/2` function of our project's `Application` module, let's assign
the metrics we want to monitor to the `metrics` variable and then provide that
to what will eventually become our `PlugReporter` GenServer:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    metrics = [
      Telemetry.Metrics.counter("myapp.plug.stop.duration"),
      Telemetry.Metrics.sum("myapp.plug.stop.duration"),
      Telemetry.Metrics.last_value("myapp.plug.stop.duration", unit: {:native, :millisecond}),
      Telemetry.Metrics.summary("myapp.plug.stop.duration", unit: {:native, :millisecond}),
      Telemetry.Metrics.distribution("myapp.plug.stop.duration", buckets: [200, 500, 1000], unit: {:native, :millisecond}),
    ]

    children = [
      ...

      {MyApp.PlugReporter, metrics: metrics}
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ...
end
```

For each metric, we provide the same event/measurement combination,
`myapp.plug.stop.duration`. The event is `myapp.plug.stop`, while `duration` is
the measurement. This is saying we want to capture "the time it takes to parse
the request, dispatch it to the correct handler, and execute the handler", but
we only want to do so for events matching "myapp.plug.stop".

For three of the metrics, `last_value`, `summary` and `distribution`, we also
include the "unit" option instructing `Telemetry.Metrics` to transform the
duration value to milliseconds from the "native" value (i.e.  nanoseconds).

Finally, we provide a "buckets" option to the `distribution` metric allowing us
to group durations by preset values. By doing this, we can create a histogram of
page loads by specified values enabling us to see how frequently pages fall
into, or out of, desired ranges.

Next, we need to build the `PlugReporter` so we can attach handlers to the
different Telemetry events.

### Attaching Event Handlers

As we've seen, metrics are the accumulation of measurements as they relate
to time, occurrence, or resource. If we are to track this accumulation, we'll
need a means of storing the measurements. We could store these values with a
GenServer, but using ETS will provide more flexibility.

Here then is our initial reporter:

```elixir
defmodule MyApp.PlugReporter do
  use GenServer
  require Logger

  alias Telemetry.Metrics.{Counter, Distribution, LastValue, Sum, Summary}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:metrics])
  end

  def init(metrics) do
    Process.flag(:trap_exit, true)

    :ets.new(:metrix, [:named_table, :public, :set, {:write_concurrency, true}])
    groups = Enum.group_by(metrics, & &1.event_name)

    for {event, metrics} <- groups do
      id = {__MODULE__, event, self()}
      :telemetry.attach(id, event, &handle_event/4, metrics)
    end

    {:ok, Map.keys(groups)}
  end
end
```

From the code above, you can see most of the heavy lifting occurs in the
`init/1` function. Here, we perform four actions: trap "exits" to be handled by
our `terminate/2` callback, initialize a new ETS table, attach our telemetry
events to an event handler, and finally return state. Let's look at each in more
detail.

First, we trap exit signals which gives our GenServer the opportunity to handle
necessary cleanup before finally terminating. We will handle this cleanup in
the `terminte/2` callback we'll define later.

Next, we initialize an ETS table as a public, "named table", which stores its
data in a set. We do this to simplify calling the correct table while ensuring
the data is unique. Finally, we turn on "write concurrency" to allow concurrent
write access.

Our third action is to "attach" event handlers to the metrics we're tracking. We do so by looping through each event group, creating unique ids, and associating those IDs to the handled event.

Finally, we set the state which we can use later to detach our event handlers.

### Responding to Events

Each time an event comes in, we want to handle it according to each of the
metrics we're watching. To do this, we need to iterate through the list of
metrics, passing the measurements and metadata to each.

```elixir
def handle_event(_event_name, measurements, metadata, metrics) do
  metrics
  |> Enum.map(&(handle_metric(&1, measurements, metadata)))
end
```

With this in place, we can match each metric to their own function. But before
we do that we need to ensure we use the correct measurement value. As we saw
when defining our metrics, we can specify a unit conversion. When we specify a
unit conversion, `Telemetry.Metrics` returns a function instead of a value for
the measurement. Therefore, we need to handle both cases and we do that with
the following function:

```elixir
defp extract_measurement(metric, measurements) do
  case metric.measurement do
    fun when is_function(fun, 1) ->
      fun.(measurements)

    key ->
      measurements[key]
  end
end
```

#### Counter

The `%Counter{}` metric is "used to keep a count of the total number of events."
Because we are using ETS, we can take advantage of its `update_counter/4`
function. This function "is guaranteed to be atomic and isolated" and simply
increments the existing counter value by the provided amount. The fourth
argument provides the default initial value if none exists, so we don't need to
worry about adding to `nil`.

```elixir
def handle_metric(%Counter{}, _measurements, _metadata) do
  :ets.update_counter(:metrix, :counter, 1, {:counter, 0})

  Logger.info "Counter - #{inspect :ets.lookup(:metrix, :counter)}"
end
```

#### Last Value

While not terribly useful in the context of web applications, there are times
when you want to store the last measurement captured by your application. Rather
than incrementing a counter value, we'll use `insert/2` to store the last
value. If a value is already present, `insert/2` overwrites it.

```elixir
def handle_metric(%LastValue{} = metric, measurements, _metadata) do
  duration = extract_measurement(metric, measurements)
  key = :last_pageload_time

  :ets.insert(:metrix, {key, duration})

  Logger.info "LastValue - #{inspect :ets.lookup(:metrix, key)}"
end
```

#### Sum

Like `%Counter{}`, we can use `update_counter/4` with the `%Sum{}` metric  to
increment the value. However, instead of incrementing the value by `1`, here we
increment the sum by the total `byte_size` of the page body.

```elixir
def handle_metric(%Sum{}, _measurements, %{conn: conn} = metadata) do
  key = :bytes_transmitted

  body = IO.iodata_to_binary(conn.resp_body)

  :ets.update_counter(:metrix, key, byte_size(body), {key, 0})

  Logger.info "Sum - #{inspect :ets.lookup(:metrix, key)}"
end
```

#### Summary

The `%Summary{}` metric is "used to track and calculate statistics". Values such
as minimum, maximum, standard deviations, and percentiles are excellent choices
to capture. You may wish to capture averages here, but unless it is used in
conjunction with percentiles, the values may be misleading. "[T]he average hides
outliers ..., which are the ones you are interested in." ([Latency: A Primer](https://igor.io/latency/#average))

In the `handle_metric/3` function below, we are simply updating (using `insert/2`) the `:summary` key with the min and max values for duration.

```elixir
def handle_metric(%Summary{} = metric, measurements, _metadata) do
  duration = extract_measurement(metric, measurements)

  summary =
    case :ets.lookup(:metrix, :summary) do
      [summary: {min, max}] ->
        {
          min(min, duration),
          max(max, duration)
        }

      _ ->
        {duration, duration, 1, duration}
    end

  :ets.insert(:metrix, {:summary, summary})

  Logger.info "Summary - #{inspect summary}"
end
```

#### Distribution

The last metric you may wish to track is `%Distribution{}`. As already
discussed, this metric allows you to provide a collection of integers by which
to group the measurements. For example, if we defined the buckets as `[200, 500,
1000]` as we did above in the `MyApp.Application` module, we can then group the
page views based on how long it took to build them: less than 200 ms, less than
500 ms, less than 1,000 ms, and then everything over that.

```elixir
def handle_metric(%Distribution{} = metric, measurements, _metadata) do
  duration = extract_measurement(metric, measurements)

  update_distribution(metric.buckets, duration)

  Logger.info "Distribution - #{inspect :ets.match_object(:metrix, {{:distribution, :_}, :_})}"
end

defp update_distribution([], _duration) do
  key = {:distribution, "1000+"}
  :ets.update_counter(:metrix, key, 1, {key, 0})
end

defp update_distribution([head|_buckets], duration) when duration <= head do
  key = {:distribution, head}
  :ets.update_counter(:metrix, key, 1, {key, 0})
end

defp update_distribution([_head|buckets], duration) do
  update_distribution(buckets, duration)
end
```

For the `update_distribution/2` function, we take advantage of Elixir's matching
magic to recursively check if the duration is less than a specific bucket. If it
is, we increment the value for that bucket. If not we look at the next value
until there are none left, in which case we increment the value for "1000+".

### Detaching Event Handlers

The last step of building a reporter is to handle termination, leaving our
system in a clean state if things go south. In our example, we do this by
implementing the `GenServer.terminate/2` callback. We're already "trapping"
exits and providing the list of events through our GenServer's state, now we
just need to loop through those events, detaching from each.

```elixir
def terminate(_, events) do
  events
  |> Enum.each(&(:telemetry.detach({__MODULE__, &1, self()})))

  :ok
end
```

With the final step in place, we have a complete, if not particularly useful,
reporter to track Plug events. If you were to build this for a production system
you would, at the very least, want to track each of the metrics by the page on
which the event occurred and some sort of timestamp (hour, minute, or second
depending on the site's traffic). Furthermore, you would want to break each of
the metrics out into their own module, and also put serious thought into which
metrics are the most valuable to you and which you should ignore.

Knowing that measurements by themselves provide only an isolated perspective
and with a functional reporter in hand, you may now be left wondering what
purpose there is in using the `Telemetry` library outside of
`Telemetry.Metrics`. There are at least three reasons:

1. You can use Telemetry to easily capture performance numbers as you work on
   new features.
2. Use Telemetry to fire off alerts based on triggering events such as slow
   queries, numerous error returns, and throughput or latency issues.
3. Use Telemetry to allow third party systems to handle aggregation.

Notice that in the first two cases, they are only valuable with context. In the
first case, you must watch the numbers as you test your feature over and over.
This is a metric: performance over iteration. In the second case, you
must already know the boundaries in order to know what measurements are outside
of them and thus trigger an event.

In the same way that a photograph captures only the briefest moment in time,
individual measurements provide only the slightest glimpse into your system. To
see beyond that glimpse we must aggregate measurements into metrics,
focusing on those which are comparative, understandable, ratios, and most
importantly, those which change the way we behave.
