---
title: Understanding Elixir's Broadway
date: 2019-10-20T20:50:06-05:00
draft: false
description: "Broadway is Plataformatec's fourth attempt at streamlining the retrieval and processing of data in Elixir. This article gives you a glimpse into that journey, provides a deeper understanding of the library, giving you everything you need to build your own Broadway application."
comments: false
post: true
categories: [elixir, broadway]
---

At its simplest, all of computing is moving data from one place to another.  Web
forms take user-submitted data and move it into a database; video games start
with an initial state, receive player input, and outputs a final state; even AI,
as exciting and complex as it is, just moves data around.  But stripping
computing down to its core doesn't make programming – which moves data from our
brain into source code – any easier. We must still wrestle with APIs, navigate
documentation, track down bottlenecks, manage resources, and write efficient and
maintainable code.

Why then, if we know that computing is merely moving data from one point
to another, do we still find ourselves building and rebuilding systems similar
to what we've built before? Why do we walk the same trails and tread the same
paths over and over again only to rediscover the same destination? Perhaps we
should expect this, after all what two problem spaces are the same? Or perhaps
it's a matter of failing to see where paths overlap?

Knowing a problem _exists_ and knowing what the problem _is_ are two different
matters. Even discovering that a problem exists requires enough exposure to it
for the pain to become unmistakable. It's only then that a problem is
identifiable and only then that you can start looking for a solution. While
your first solution may be good enough to solve the problem, it may also serve
to emphasize the depth of the problem and the inadequacy of your first attempt.
It's through this cycle – problem discover, identification, and solution – that
led [Plataformatec](http://plataformatec.com.br/) to develop the [Broadway
library](https://github.com/plataformatec/broadway) for Elixir.

## The Road to Broadway

Broadway is a sort of mini-framework for the
[GenStage](https://github.com/elixir-lang/gen_stage) library. As such, it
includes functionality which developers previously had to write themselves:
graceful shutdowns, batching, partitioning, acknowledgements, etc. While some of
this functionality is easily implemented by novice developers, there are
several which are tricky even for the most competent. Assuming, of course, the
developer thinks to build it in.

One might conclude that Broadway was always part of the plan since the release
of GenStage, but as we've already seen, it takes regular exposure to a problem
to even notice one exists. For example, before GenStage existed, José's initial
idea of parallel pipelines looked like this:

```elixir
File.stream(path)
|> ...
|> Stream.async()
|> ...
|> Stream.async()
|> ...
|> Stream.async()
|> ...
|> Stream.run()
```

He and his team quickly discovered the pain point here: it pushed data to
processes whether they were ready for it or not. GenStage came out of this
discovery, and [Flow](https://github.com/plataformatec/flow) soon followed when
the team saw the need to focus on data. In the same way that Flow grew out of a
focus on data, Broadway grew out of a focus "on events and on operational
features, such as metrics, automatic acknowledgements, failure handling, and so
on." <sup>[1]</sup> It took José and Plataformatec 6 or 7 years to get to
Broadway – one iteration at a time.

## Features

Before we see how to use Broadway, let's look at the seven built-in features the
library offers.

### Back-Pressure

Broadway inherits its back-pressure feature from GenStage. In both libraries,
back-pressure allows "consumers" to signal producers their availability to
receive data. Producers stop sending data to a consumer when it meets its
capacity, and begins sending data again once the consumer has dealt with
its backlog. "[B]y relying on GenStage, we only get the amount of events
necessary from upstream sources, never flooding the pipeline."<sup>[2]</sup>

### Automatic Acknowledgements

What happens when your pipeline runs into badly formatted or corrupted data?
Does it crash? Does it silently ignore it? Or does it kick off some other set of
processes to handle it? "Broadway automatically acknowledges messages at the end
of the pipeline or in case of errors."<sup>[2]</sup> Once captured, Broadway
enables you to choose how best to handle the errors and the data that caused
them.

### Batching

Anyone who's experience N+1 issues knows the importance of batching. Working
with data in volume is always faster than handling that same data one record or
data point at a time "Broadway provides built-in batching, allowing you to group
messages either by size and/or by time."<sup>[2]</sup>

### Fault Tolerance

> Broadway pipelines are carefully designed to minimize data loss. Producers are
> isolated from the rest of the pipeline and automatically resubscribed to in
> case of failures. On the other hand, user callbacks are stateless, allowing us
> to handle any errors locally. Finally, in face of any unforeseen bug, we
> restart only downstream components, avoiding data loss.<sup>[2]</sup>

### Graceful Shutdown

If you've worked with GenStage before, then you now the importance of draining
data from the pipeline before terminating processes. You also know the
difficulty in handling this well. My suspicion – and that's all this is – is
that this feature is the primary driver in creating Broadway. I suspect that it
was building this feature into enough projects that drove the team to extract it
out into its own project.

### Built-In Testing

Working with data from external systems makes testing challenging. To that end,
"Broadway ships with a built-in test API, making it easy to push test messages
through the pipeline and making sure the event was properly
processed."<sup>[2]</sup> By providing this, you can run Broadway pipelines in
the testing process without worrying about hitting those third-party systems.

### Partitioning

Finally, "Broadway allows developers to batch messages based on dynamic
partitions."<sup>[2]</sup> That is, Broadway processes data differently based on
what the data contains. If your data can have an email or a phone number, you
may want to batch that data differently: data with phone numbers to an SMS
process, and emails to a mass email process.

### Coming soon...

If this weren't enough, there are more features planned for Broadway.
Rate-limiting, metrics, and back-off features are all planned for future
releases.

## A Basic Example

There are more moving parts in Broadway than what's been advertised, so we'll
use an example project to highlight what those parts do. At its simplest, every
Broadway application has two primary components: a producer and a consumer. The
producer is a GenStage module which "produces" events to, while the consumer is
a function which "processes" those events. For our first example, we'll
implement those two pieces, but we'll need three modules to do it:

- A `Counter` module used to provide a range of number to consumers.
- A transformer module which transforms the data into Broadway messages.
- A Broadway module which starts the application and houses the consumer
  function.

### The Producer

The producer is a GenStage module. Once created, you will assign it to the
"producers" section of the Broadway module which allows Broadway to handle its
supervision. By keeping this module seperate, it is "isolated from the rest of
the pipeline and [can be] automatically resubscribed to in case of failures."<sup>[2]</sup>

Here's our `Counter` producer:

```elixir
defmodule MyApp.Counter do
  use GenStage

  def start_link(number) do
    GenStage.start_link(Counter, number)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, counter) when demand > 0 do
    events = Enum.to_list(counter..counter+demand-1)

    {:noreply, events, counter + demand}
  end
end
```

The `start_link/1` function initializes the `Counter` module with a provided
integer. It then calls the `init/1` function via the `GenStage.start_link/2`
call, which in turn defines the GenStage module as a `:producer`, setting the
initial state to that of the provided integer.

Next, we create the `handle_demand/2` function to receive "demand" from
processors along with the state. It returns a tuple of `:noreply` (part of the
spec), the events to return to the requesting consumer, and finally it sets its
state to the current count plus the demand.

In this example, if we initialized our `Counter` module with 10, then it
received a demand of 20, it would return a list of values from 10-29, and the
new state would be 30.

### The Transformer

If you use one of the "official Broadway producers", you won't need to specify a
transformer. Transformers are only needed if your producer doesn't return a
`%Broadway.Message{}`. Since the `Counter` module returns a list of integers, we
need to transform those integers into `%Broadway.Message`s. We can do that with
a simple module like this:

```elixir
defmodule MyApp.CounterMessage do
  def transform(event, _opts) do
    message = %Broadway.Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, event}
    }
  end

  def ack(_ref, _successes, _failures) do
    :ok
  end
end
```

We'll add this to the Broadway module in a moment, but for now it's enough to
see that the `transform/2` function returns a `%Broadway.Message{}` with the
number assigned to `:data`.

We're also setting the `:acknowledger` to point to this module. The main
Broadway module can then send successful events and failed events to the
`ack/3` function. It's here that you would want to re-queue data, increment
metrics, or send notifications.

### The Broadway Module

With our producer created, we can turn our attention to building the main
Broadway module. This module is divided into two sections: configuration and
implementation. We handle configuration in the `start_link/1` function,
while we handle implementation in all the other functions.

```elixir
defmodule MyApp do
  use Broadway

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: MyAppExample,
      producers: [
        default: [
          module: {MyApp.Counter, 0},
          transformer: {MyApp.CounterMessage, :transform, []},
          stages: 1
        ]
      ],
      processors: [
        default: [stages: 2]
      ],
    )
  end

  def handle_message(:default, %Message{data: data} = message, _context) do
    Process.sleep 1000

    message
    |> IO.inspect
  end
end
```

Looking first at `start_link/1` (i.e. the configuration), we see that it in turn
calls `Broadway.start_link/2` which "starts a `Broadway` process linked to the
current process."<sup>[2]</sup> We could provide it with a different module
which holds our implementation details, but because we're keeping it simple we
use `__MODULE__` and refer it to the current module.

Next we define the three required options: "name", "producers", and
"processors".

The "name" option is straightforward, this is "used for name registration. All
processes/stages created will be named using this value as
prefix."<sup>[2]</sup>

The next option is `:producers`. In the future we'll be able to define multiple
producers, but for now only a single producer (named "default") is allowed.
Within this option we see another three options defined. In the first, `module`,
we define both the producer and the starting value to use. We use the next
option, `transformer`, to instruct Broadway to use our
`CounterMessage.transform/2` function for data transformations. The last option
specifies how many processes should be started as producers. We only want one
for the moment.

The next primary option is `:processors`. Like the "producers" option, only a
single processor can be defined. Unlike the producers section, however, we
merely assign options to the `:default` atom. Broadway matches the `:default`
atom against the `handle_message/3` function below. As in the `:producers`
options, we set stages to define the number of processes used to retrieve data
from the producer. The default value is `System.schedulers_online() * 2` –
that's 16 processes on my machine.

The last thing in our module is the `handle_message/3` function (i.e.  the
processor).  "This is the place to do any kind of processing with the incoming
message, e.g., transform the data into another data structure, call specific
business logic to do calculations. Basically, any CPU bounded task that runs
against a single message should be processed here."<sup>[2]</sup> For our
purposes, it's a simple function which sleeps for one second and then prints out
the contents of `message`, and subsequently returns the message.

The output looks like this:

```elixir
%Broadway.Message{
  acknowledger: {MyApp.CounterMessage, :ack_id, 0},
  batch_key: :default,
  batcher: :default,
  data: 0,
  metadata: %{},
  status: :ok
}
%Broadway.Message{
  acknowledger: {MyApp.CounterMessage, :ack_id, 10},
  batch_key: :default,
  batcher: :default,
  data: 10,
  metadata: %{},
  status: :ok
}
%Broadway.Message{
  acknowledger: {MyApp.CounterMessage, :ack_id, 11},
  batch_key: :default,
  batcher: :default,
  data: 11,
  metadata: %{},
  status: :ok
}
%Broadway.Message{
  acknowledger: {MyApp.CounterMessage, :ack_id, 1},
  batch_key: :default,
  batcher: :default,
  data: 1,
  metadata: %{},
  status: :ok
}
```

Notice that the data seems to bounce around a bit. This is the result of setting
the stages to 2 under the `:processors` option. The first processor (i.e.
consumer) takes the values 0-9, while the second takes 10-19.

What do you think would happen if you changed the number of producers from 1 to
2, or more? Answer: you would see the same numbers repeated twice by each
processor.  While using multiple stages for producers may be useful when the
source data is a queue, it may end up causing a lot of headaches if you try the
same thing against a database unless you keep track of what was last returned.

### Acknowledgers

A Broadway Acknowledger is a
[behaviour](https://elixir-lang.org/getting-started/typespecs-and-behaviours.html#behaviours)
"used to acknowledge that the received messages were successfully processed or
failed."<sup>[3]</sup> Messages marked as "failed" do not continue to the next step in the
pipeline. We can take advantage of the acknowledgement phase to handle both
successes and failures. Here we can re-queue failed messages, update metrics,
and notify other processes or people.

Let's update our `CounterMessage.transform/2` function by adding a
`validate_even/1` function to the pipeline. This function will mark odd numbers
as failures using the `Broadway.Message.failed/2` function, and leave even
numbers alone.

```elixir
defmodule MyApp.CounterMessage do
  alias Broadway.{Acknowledger, Message}

  def transform(event, _opts) do
    %Message{
      data: event,
      acknowledger: {__MODULE__, :ack_id, event}
    }
    |> validate_even()
  end

  def ack(ref, _successes, _failures) do
    :ok
  end

  defp validate_even(%Message{data: event} = message) when rem(event, 2) == 0 do
    message
  end

  defp validate_even(%Message{} = message) do
    Message.failed(message, :odd)
  end
end
```

If we were to run our process again, we would see messages with an odd data
value marked with a status of `{:failed, :odd}`. Messages with an even value
continue to have an `:ok` status.

If you only have a producer and processor, as we do in our current example, then
you will need to filter out `:failed` messages using matching in the function
heads. However, if we were to add a "batcher" stage to our pipeline, Broadway
would automatically filter out the failures for your.

As you can see in the `ack/3` function above, it receives a `ref` (used for
matching), and a list of successes and failures. It's here where you would add
logic to re-queue failed messages, update metrics, or notify.

# A Batching Example

In our example we've been using two stages to process data. Even though each
stage receives multiple messages to fulfill demand they each process those
messages one at a time. For many situations, such as inserting records into a
database or queuing messages to be sent en mass, it's more efficient to do so in
batches.

Adding batching to a Broadway application is like adding a processor: you first
define your batchers in the `start_link/1` section, then create your
`handle_batch/3` functions. Unlike processors, or even producers, you can have
multiple batchers which you can use to partition incoming data. For example,
sending domestic requests to a system to be handled immediately, while foreign
requests could be stored in a database to be handled at a later date.

To see how this might work, let's modify our current example to play [Fizz
Buzz](https://en.wikipedia.org/wiki/Fizz_buzz).

We first need to add the appropriate batchers. Modify the `start_link/1`
function to look like this:

```elixir
def start_link(_opts) do
  Broadway.start_link(__MODULE__,
    name: MyAppExample,
    producers: [
      default: [
        module: {MyApp.Counter, 0},
        transformer: {MyApp.CounterMessage, :transform, []},
        stages: 1
      ]
    ],
    processors: [
      default: [stages: 2]
    ],
    batchers: [
      default: [stages: 1, batch_size: 5],
      fizzbuzz: [stages: 1, batch_size: 5],
      fizz: [stages: 1, batch_size: 5],
      buzz: [stages: 1, batch_size: 5],
    ]
  )
end
```

Here we've defined four batchers: "default", "fizzbuzz", "fizz", and "buzz".
Each has one stage and has a batch size of five. Batch size means that the
batcher triggers when the message count reaches that number.

Let's modify our processor to set the batcher each message will use.

```elixir
def handle_message(:default, %Message{data: data} = message, context) do
  Process.sleep(250)
  result = fizzbuzz(data)

  message
  |> Message.put_batcher(result)
end

defp fizzbuzz(data), do: _fizzbuzz(data, rem(data, 3), rem(data, 5))
defp _fizzbuzz(_data, 0, 0), do: :fizzbuzz
defp _fizzbuzz(_data, 0, _), do: :fizz
defp _fizzbuzz(_data, _, 0), do: :buzz
defp _fizzbuzz(data, _, _), do: :default
```

Here, after we sleep for a quarter of a second, we retrieve the result from
fizzbuzzing our message data. The `fizzbuzz/1` function returns an atom of
`:default`, `:fizz`, `:buzz`, or `:fizzbuzz` which we use in the
`Message.put_batcher/1` function. With the batcher defined, Broadway then routes
the messages to the appropriate batcher.

```elixir
def handle_batch(:default, messages, _batch_info, _context) do
  data = Enum.map(messages, &(&1.data)) |> Enum.join(", ")
  IO.inspect "Default: #{data}"
  messages
end

def handle_batch(:fizz, messages, _batch_info, _context) do
  data = Enum.map(messages, &(&1.data)) |> Enum.join(", ")
  IO.inspect "Fizz: #{data}"
  messages
end

def handle_batch(:buzz, messages, _batch_info, _context) do
  data = Enum.map(messages, &(&1.data)) |> Enum.join(", ")
  IO.inspect "Buzz: #{data}"
  messages
end

def handle_batch(:fizzbuzz, messages, _batch_info, _context) do
  data = Enum.map(messages, &(&1.data)) |> Enum.join(", ")
  IO.inspect "FizzBuzz: #{data}"
  messages
end
```

The output looks like this:

```elixir
"Default: 1, 2, 4, 11, 13"
"Default: 14"
"Fizz: 12, 18, 3, 6, 9"
"Default: 16, 17, 7, 8"
"Buzz: 10, 5"
"FizzBuzz: 15, 0"
"Default: 22, 23, 19, 26, 28"
"Buzz: 20, 25"
"Fizz: 21, 24, 27"
"Default: 37"
"Fizz: 36, 39, 33"
"Buzz: 35"
"FizzBuzz: 30"
"Default: 38, 41, 43, 44, 29"
```

You'll notice that even though we've specified the batch size to 5, the function
sometimes fires with a smaller batch. This is due to the `:batch_timeout`.
"When this timeout is reached, a new batch is generated and sent downstream, no
matter if the `:batch_size` has been reached or not."<sup>[2]</sup> If we change
the timeout to 15 seconds, we'll see results more in line with our expectations:

```elixir
"Default: 1, 2, 4, 11, 13"
"Default: 14, 16, 17, 7, 8"
"Fizz: 12, 18, 3, 6, 9"
"Default: 19, 22, 23, 26, 28"
"Fizz: 21, 24, 27, 33, 36"
"Buzz: 20, 5, 10, 25, 35"
"Default: 29, 31, 32, 34, 37"
"Default: 38, 41, 43, 46, 47"
"Default: 49, 44, 52, 53, 56"
"Fizz: 39, 42, 48, 51, 54"
"Buzz: 40, 50, 55, 65, 70"
"Default: 58, 59, 61, 62, 64"
"FizzBuzz: 15, 30, 45, 60, 75"
```

The above example has been kept simple to help you see what each piece of the
Broadway puzzle does, and enable you to get started with your own Broadway
project. As your project increases in scope, I recommend looking at the source
code of the [BroadwayRabbitMQ](https://github.com/plataformatec/broadway_rabbitmq) and [BroadwaySQS](https://github.com/plataformatec/broadway_sqs) projects.

"At its simplest, all of computing is moving data from one place to another." If
only it were that simple. Even when working with consistent and clean data there
are still countless considerations and limitations standing in the way of
"moving data from one place to another." Unreliable network, inaccessible
servers, malicious activity, and legacy code all play havoc with your processes.
As they say, "The devil is in the details," and nowhere is this more true than
in computing.

While still not as simple as just "moving data from one place to another,"
Broadway does manage to lift several burdens from the developer's shoulders:
back-pressure, acknowledgements, batching, auto-restarts, graceful shutdowns,
partitioning, with still more to come. Seven years ago, José's idea was to chain
`Stream.async()` functions together. It makes you wonder what Elixir's data
processing will look like in another seven years.

[1]: https://github.com/plataformatec/broadway "Broadway - GitHub"
[2]: https://hexdocs.pm/broadway/Broadway.html "Broadway - Hex docs"
[3]: https://hexdocs.pm/broadway/Broadway.Acknowledger.html "Broadway.Acknoledger - Hex docs"
