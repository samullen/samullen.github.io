---
title: The "How"s, "What"s, and "Why"s of Elixir Telemetry
date: 2019-06-24T09:47:33-05:00
draft: false
description: "It's commonly quoted that 'What gets measured gets managed,' but how do you do that? Elixir's Telemetry library enables you to stop worrying about *how* to capture your system's data and more time thinking about *what* data to capture."
comments: false
post: true
categories: [elixir, telemetry, metrics, data]
---

"What gets measured gets managed." This quote – [wrongly attributed to Peter
Drucker](http://billhennessy.com/simple-strategies/2015/09/09/i-wish-drucker-never-said-it)
– tells us that when we monitor information about something, we can make
decisions about what it is we're monitoring and where to go next. Be warned,
however, that's only part of the quote. The full quote is, "What gets measured
gets managed - even when it's pointless to measure and manage it, and even if it
harms the purpose of the organisation to do so." In other words, if you monitor
the wrong data, you'll make the wrong decisions.

Until recently, Erlang and Elixir developers were left to their own devices when
it came to collecting and measuring data about their processes and applications.
Then in 2018, [Arkadiusz Gil](https://github.com/arkgil) released
[Telemetry](https://github.com/beam-telemetry/telemetry), giving us a "dynamic
dispatching library for metrics and instrumentations." It's a simple library
providing a standardized interface for capturing and handling metrics from
monitored events.

We'll go into a detail on how to set it up in a moment, but in a nutshell,
you'll "attach" it as a supervised process in your project, set up named
"events" to be matched against, and then "execute" against those events in your
code. First, let's look at why we should monitor our processes.

## The Value of Monitoring

At the beginning of any project little thought is given to monitoring, but as
projects increase in size and scope it because apparent that some sort of
view into "just what the hell is going on in there" is needed, and it's
needed for a number of reasons.

The first reason is to enable us, as the developers of the system, to quickly
find and eliminate bottlenecks and other problems in the system. These can be
anything from networking delays to slow database queries, but can just as easily
be used to find speed bumps in GenServers and individual functions.

Of course, once you find an issue you'll want to know if the changes you make
will be an improvement. Capturing data about your system allows you to
benchmark the performance of existing logic against what you plan to implement.
If you don't know where your target is, how will you know if you hit it?

Keeping with this line of thought, the third reason to capture metrics about
your project is to catch issues prior to them being caught by your customers.
This, of course, keeps your customers happy and has the added benefit of
avoiding unnecessarily awkward conversations with your boss.

Lastly, as we already discussed, the whole point of capturing metrics about your
system is to enable you to make good decisions about what to do next. If you see
your webapp using an average of 85% of the memory allotted to it on
[Gigalixir](https://www.gigalixir.com/), you know it's time to upgrade.
Similarly, when you see certain features of a project used more than another,
you can determine where to spend your efforts or even eliminate unused
functionality.

Since we're on the topic of making good decisions...

## Lies, Damned Lies, and Vanity Metrics

If you've worked around the web very long, you've heard people talk about page
views. Page views refer to the amount of traffic your site gets, but
what, if anything, does that mean? Does it mean the company made more money?
Does it mean marketing efforts paid off? If so, which efforts? How does it
compare to past days, weeks, months? What were the conversions in relation to
it? In short, what does the data tell you to do?

A metric by itself is just a number. It needs correlating and comparable data
in order to provide you with the information you need to make good decisions.
Metrics such as page views, memory usage, error counts, and even orders when
taken by themselves are known as "vanity metrics". "Vanity metrics might make
you feel good, but they don't change how you act. Actionable metrics change your
behavior by helping you pick a course of action." ([Lean
Analytics](https://www.goodreads.com/book/show/16033602-lean-analytics))

There's more to monitoring than merely recording numbers; there needs to be a
purpose. "Whenever you look at a metric, ask yourself, 'What will I do
differently based on this information?' If you can't answer that question, you
probably shouldn't worry about the metric too much." ([Lean
Analytics](https://www.goodreads.com/book/show/16033602-lean-analytics))

## Getting Started with Telemetry

With warnings and disclaimers out of the way, let's install and set up
Telemetry. There are four steps to follow to set up Telemetry in your project:
1) Install the library; 2) "attach" the Telemetry supervisor to your project; 3)
Define the "events" to capture; 4) "Execute" against those events.

### Step 1 - Install Telemetry

The first step, of course, is to install the Telemetry library. I know you know
how to install an Elixir library, but for the sake of completeness add the
following to your `deps/0` function in your project's `mix.exs` file.

```elixir
defp deps() do
  [
    {:telemetry, "~> 0.4.0"}
  ]
end
```

_**note:** The [current version](https://hex.pm/packages/telemetry) may be
different by the time your read this._

### Step 2 - Attach the Telemetry Supervisor

Once installed, the next thing you'll need to do is start Telemetry so it can
begin capturing metrics. There are at least two ways to do this: 1) include the
raw Telemetry code in your `application.ex` file; or 2) wrap the logic in a
function and call that from your `application.ex` file.

#### Basic Telemetry Attachment

This is the simplest way to include Telemetry in your project. In your
`application.ex` file, add the following code prior to the call to start
supervising your application:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      ...
    ]

    # Start the Telemetry supervisor
    :telemetry.attach("handler-id", [:event_name], &handle_event/4, nil)

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ...
end
```

A couple things to note here:

- the `attach/4` function only allows you to capture a single event. To handle
  more events, use `attach_many/4`
- The "handler-id" is a unique identifier, "`handler_id` must be unique, if
  another handler with the same ID already exists the `{error, already_exists}`
  tuple is returned."
- `[:event_name]` is a list of atoms used to match events against and fire the
  matching function.
- `handle_event/4` is the function to fire
- The last parameter is a "config" argument.

#### Wrapping the Attachment Logic

Polluting your Application module with unrelated logic isn't ideal. Instead, the
convention is to extract the "attach" functions into an "instrumenter" module
and call that from the `application.ex` module. The instrumenter module will
also include relevant event handlers (next section).

```elixir
defmodule MyApp.Instrumenter do
  def setup do
    events = [
      [:web, :request, :start],
      [:web, :request, :success],
      [:web, :request, :failure],
    ]

    :telemetry.attach_many("myapp-instrumenter", events, &handle_event/4, nil)
  end

  def handle_event([:web, :request, :start], measurements, metadata, _config) do
    ...
  end

  def handle_event([:web, :request, :success], measurements, metadata, _config) do
    ...
  end

  def handle_event([:web, :request, :failure], measurements, metadata, _config) do
    ...
  end
end
```

Then, in your `Application` module, you will use `MyApp.Instrumenter.setup()`
instead of `:telemetry.attach/4`.

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [
      ...
    ]

    MyApp.Instrumenter.setup()

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  ...
end
```

By extracting the logic into its own module, we keep our `Application` module
clean, and organize the Telemetry logic by responsibility (the Single
Responsibility Principle isn't just for OOP).

### Step 3 - Define Your Events

In Step 2, we saw in the basics of defining our events. We don't have to name
the function `handle_event/4`, but that seems to be the convention. The function
does however need to accept four arguments:

- **The event name:** a list of atoms matching the expected event. Examples:

```elixir
events = [
  [:my_app, :repo_name, :query],     # to capture DB queries
  [:my_app, :web_request, :success], # to capture HTTP 200s
  [:my_app, :web_request, :failure], # to capture web errors
]
```

- **Measurements:** Some data structure containing the measurements you're
  interested in. Example:

```elixir
%{
  decode_time: 6000,
  query_time: 673000,
  queue_time: 39000,
  total_time: 718000
}
```

- **Metadata:** Information about the specific Telemetry event. This could be a
  `%Plug.Conn{}` struct if you're working with Plug, query information with
  Ecto, a stack trace, or any other valuable information.

Capturing events is the easy part, the hard part is figuring out what to do with
the data once you've captured it. One option is to log it; that's easy.

```elixir
  def handle_event([:web, :request, :start], measurements, metadata, _config) do
    Logger.info inspect(measurements)
    Logger.info inspect(metadata)
  end
end
```

Another option might be to store it to an ETS table. This is especially useful
if you need to track lots of data very quickly without needing to persist it
indefinitely. A similar option is to use the
[telemetry_metrics](https://github.com/beam-telemetry/telemetry_metrics) library
(a subject for another article.) Finally, it may make more sense to send your
data to a 3rd party vendor such as [DataDog](https://www.datadoghq.com/),
[NewRelic](https://newrelic.com/), or [Scout](https://scoutapm.com/).

### Step 4 - Execute on Events

Finally, with your project set up up to receive them, the only thing left is to
start sending events. To do that, you'll use the `execute/2` or `execute/3`
functions.

```elixir
:telemetry.execute(
  [:my_app, :request, :success],
  %{time_in_milliseconds: 42},
  %{
    request_path: conn.request_path,
    status_code: conn.status
  }
)
```

When the above function is executed, the event handler matching `[:my_app,
:request, :success]` will receive the second argument as the measurement(s), and
the last argument (if any) as the metadata. You can leave metadata out if it's
unimportant.

## Don't Reinvent the Wheel

It might be tempting at this point to go off and spend time building out your
events and add `execute` commands throughout your code base, but before you do
make sure you aren't duplicating effort. Several Elixir libraries already
include Telemetry support and can ease your burden. Let's look at two you'll
mostly like use.

### Plug.Telemetry

Telemetry support is included with [Plug](https://github.com/elixir-plug/plug)
as of v1.8. By including Telemetry in your project's list of dependencies, you
automatically get access to its emitted events.

With Telemetry installed, you'll need to add the plug, `Plug.Telemetry`,
to the relevant pipeline to start sending events. Here's an example:

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

By adding this line to your `:browser` pipeline, all plugs and controllers using
that pipeline get access to the two emitted events: `:start` and `:stop`. Then,
to capture those events, you'll add them to the list of events in your
"Instrumenter" module.


```elixir
events = [
  ...
  [:my_app, :plug, :start], # Captures the time the request began
  [:my_app, :plug, :stop],  # Captures the duration the request took
  ...
]
```

The `:start` event "carries a single measurement, `:time`, which is the
monotonic time in native units at the moment the event is emitted." The `:stop`
event, on the other hand, "carries a single measurement, ':duration', which is
the monotonic time difference between the stop and start events." In each case –
at least on a Mac – the time comes in nanoseconds. You can convert it to
something more manageable with `System.convert_time_unit/3`. It should be noted
that the `metadata` value for both events is the `%Plug.Conn{}` value for the
request.

```elixir
System.convert_time_unit(duration, :nano_seconds, :milli_seconds)
```

The last thing is to define your event handler. It's exactly what you would
expect.

```elixir
def handle_event([:my_app, :plug, :start], %{time: time}, metadata, _config) do
  time = System.convert_time_unit(time, :nano_seconds, :milli_seconds)

  # Logic to handle :start event
end

def handle_event([:my_app, :plug, :stop], %{duration: duration}, metadata, _config) do
  duration = System.convert_time_unit(duration, :nano_seconds, :milli_seconds)

  # Logic to handle :stop event
end
```

### Ecto Telemetry Support

Adding Telemetry support for [Ecto](https://github.com/elixir-ecto/ecto) is just
as easy as `Plug.Telemetry`. After including Telemetry in your list of
dependencies, the first thing you'll do – and this is optional – is add the
`:telemetry_prefix` to your repo's configuration.

```elixir
config :my_app, Repo,
  database: "my_app",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  telemetry_prefix: [:my_app, :repo]
```

If you don't do this, Ecto will default to `[:my_app, :repo]` (thus the
"optional" bit).

By including Telemetry as a dependency, Ecto will automatically start sending
events for _every_ query to the event, `[:my_app, :repo, :query]. To capture
those events, add it to the list of events and create the appropriate handler.

```elixir
defmodule MyApp.Instrumenter do
  def setup do
    events = [
      [:my_app, :plug, :start],
      [:my_app, :plug, :stop],
      [:my_app, :repo, :query], # <- Telemetry event id for Ecto
    ]

    :telemetry.attach_many("myapp-instrumenter", events, &handle_event/4, nil)
  end

  ...

  def handle_event([:my_app, :repo, :query], measurements, metadata, _config) do
    IO.inspect measurements
    IO.inspect metadata
  end
end
```

Just to be clear, handling `[:my_app, :repo, :query]` will capture **_every_**
query. That may not be what you want. For more fine-grain control over which
queries are monitored, you can add `telemetry_event: [:my_app, :repo,
:named_query]` to your Repo execution. Then add a correlating handler and you'll
be good to go.

```elixir
# DB Query
Repo.get(User, 2112, telemetry_event: [:my_app, :repo, :user_get])

# Instrumenter
events = [
  ...
  [:my_app, :repo, :user_get]
  ...
]

...

def handle_event([:my_app, :repo, :user_get], measurements, metadata, _config) do
  IO.inspect measurements
  IO.inspect metadata
end
```

Unlike Plug.Telemetry, `measurements` in Ecto are in milliseconds and contain
more detail:

```Elixir
%{
  decode_time: 6000,
  query_time: 673000,
  queue_time: 39000,
  total_time: 718000
}
```

The `metadata` value for Ecto also provides more information:

```elixir
%{
  params: [2112],
  query: "SELECT u0.\"id\", u0.\"first_name\", u0.\"last_name\", u0.\"email\", u0.\"inserted_at\", u0.\"updated_at\" FROM \"users\" AS u0 WHERE (u0.\"id\" = $1)",
  repo: MyApp.Repo,
  result: {:ok,
   %Postgrex.Result{
     columns: ["id", "first_name", "last_name", "email", "inserted_at", "updated_at"],
     command: :select,
     connection_id: 18220,
     messages: [],
     num_rows: 1,
     rows: [
       [2112, "Example", "User", "user@example.com",
        ~N[2018-08-28 15:29:11.106171], ~N[2018-12-04 14:23:02.000000]]
     ]
   }},
  source: "users",
  type: :ecto_sql_query
}
```

Telemetry isn't a revolutionary idea and the maintainers don't claim it is. What
they do claim is that it provides a simple and flexible means for capturing
data.  More importantly, Arkadiusz Gil, Telemetry's creator, states, "the goal
here is to improve and standardize how we instrument and monitor applications
running on the beam." [Arkadiusz Gil - Telemetry ...and metrics for
all](https://www.youtube.com/watch?v=cOuyOmcDV1U)

It's the word "standardize" which stands out. Now, rather than wasting time
working out _how_ to capture data, we can spend our efforts deciding _what_ data
to capture. Furthermore, because of this standardization, libraries we already
use are including "hooks" into Telemetry to make it easier for us to capture
the data we need.

And we do need data. We need it to work out where bottlenecks are in our system,
how our changes will affect performance, catch problems before our customers do,
and most importantly, to help us make good decisions. We must be careful about
the data we capture. If it's not correlated to other metrics or if it doesn't
help us make good decisions, it may be worse than having no data at all.

> What gets measured gets managed - even when it's pointless to measure and
> manage it, and even if it harms the purpose of the organisation to do so.
>
> – V. F. Ridgway
