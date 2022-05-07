---
title: More Than 1:1 With Elixir's Genstage
date: 2018-08-04T09:22:49-05:00
draft: false
description: "Most articles and documentation show Elixir's GenStage to communicate between stages in a 1:1 fashion. It can be so much more"
comments: false
post: true
categories: [elixir]
---

I recently started a new job at [Spartan Race](https://spartan.com) and was not
only given a new project, but also the choice of what technology to use. At a
high-level, the project was simple: pull data from one provider's REST endpoint;
based on that, pull data from a second REST endpoint from the same provider;
finally, correlate that second set of data to two other data sets from a
different provider and store the results. There was a little more to it than
that, but it's a good overview and enough to set the stage.

Until recently, Spartan had been a JavaScript shop. While Node.js and
js-framework-of-the-week were more than capable of handling a 200 req/sec
website, the technical debt the site had accumulated gave the newly-hired
technology leaders ample reason to consider alternatives. They chose to bring in
Ruby/Rails for some quick wins with admin tooling and prototyping, and
Elixir/Phoenix to handle the main website and high-volume data needs.

I could have chosen Ruby, but I was concerned that any failure could crash the
entire process. I was also concerned about the speed which I'd be able to
retrieve the data from each step in the process, how to pipeline that data, and
finally work with different threads that would be involved. Well, that's what I
told myself to justify not choosing Ruby. The real reason, of course, is I
wanted the opportunity to do something with Elixir. This project was the perfect
fit.

## The Data

I won't bore you with you the nature of the data I was working with, so for the
remainder of this article, I'll keep it simple and Spartan related with three
types of data: Race, Entry (i.e. athletes "enter" a race), and Athlete. A Race
can "have many" Entries, and each Entry "belongs to" an Athlete.

If each data type was a REST endpoint, we might do something like this:

1. Retrieve a list of all the Races: `http://example.com/races`
2. Retrieve all the Entries for each Race:
   `http://example.com/races/:id/entries`
3. Retrieve each Athlete for each Entry: `http://example.com/athlete/:id` 
  - *Note:* we would be able to get the athlete's id from the entry record

You wouldn't want to do that sequentially, because that is `1 (call to races) +
total # of Entries * 2 (1 athlete/entry)`. If you have 10 races with 20 athletes
each, the total number of calls would be 401. Instead, you'd want to have
different processes (Elixir processes) handling the different steps, and more
than one when possible.

## v1: GenServer

My first pass at the problem used GenServer for all the things. There was a
server to store the list of races, one to store the list of entries, and yet
another to handle another data store. I had servers to handle parsing the data,
compiling the data, and inserting the data. It was too much, but when all you
have is a hammer...

I eventually ran into a blocker with the mess I'd created and reached out to the
[KC Elixir Group](https://www.meetup.com/KC-Elixir-Users-Group/) for help. The
first thing someone asked was, "Why aren't you using GenStage for that?".

The simple answer is: 1) I didn't see GenStage in Elixir's standard library; and
2) I thought I'd heard something recently about a GenSomethingOrOther component
getting deprecated.

Now I know differently.

## GenStage for the uninitiated

[GenStage](https://github.com/elixir-lang/gen_stage) is "a specification" for
"implement[ing] systems that exchange events in a demand-driven way." This
definition makes a lot of sense if you already know what GenStage is, but for
everyone else it might be easier to think of it as library that allows you to
chain of series of processes together. Each process (i.e. stage) can be a
"provider", "consumer", or a combination of the two (i.e. a provider/consumer).
Consumers create demand by requesting data from providers, which in turn either
return the requested data or act as consumers themselves and send demand further
upstream. As data flows down from the top "producer", each link (i.e. stage) in
the chain has the opportunity to modify the incoming data prior to responding to
the requesting consumer.

Let's take GenStage out of it for a moment and look at a real-life scenario:
searching for a race on [https://spartan.com](https://spartan.com)

1. On the "Find a Race" page, an athlete types in "Hawaii" and hits the "Search"
   button
2. The front end doesn't know how to deal with that, so it sends the demand to
   the server
3. The web server doesn't have the information requested, so it sends demand to
   the database
4. The database receives the query about races in Hawaii and sends the results
   back to the web server
5. The web server receives the data from the database and transforms it to
   something usable by the frontend
6. The frontend takes the resulting data and then transforms and presents the
   final data to the end-user
7. Lastly, the end-user gets the sought after information and signs up for a
   race (starting a whole new chain of events)

It's a very Elixir-like way of processing data, and almost like there's some
sort of [invisible hand](https://en.wikipedia.org/wiki/Invisible_hand) at work
in it.

## v2: 1:1 GenStage

With the bright and shiny GenStage tool added to my toolbox I set off to rework
my processes: Agents were terminated, GenServers were mutilated, and
Supervisors got reorged. It was...unpleasant.

As you'll recall, we're looking to import athlete information. To get athlete
information, we must first know what their entries are, and to get that, we have
to retrieve all the races. It's a perfect fit for GenStage. Ideally, I wanted
the following stages:

* Race stage (producer): retrieves all the races
* Entry stage (producer/consumer): retrieves all entries for a race
* Athlete stage (consumer): retries the athlete matching an entry

Unfortunately I wasn't able to make GenStage work with the above stages. I
couldn't figure out how to make the second stage (producer/consumer) return more
data than went into it, and was stuck with a 1:1 ratio of data. One item went
into a stage and only one item would come out.

I knew the Elixir team wouldn't design something so limiting, so in my spare
time I set out to understand what I was doing wrong.

## v3: 1:n:n GenState

To make things easy on myself, I stepped away from the project data and reworked
the examples from the GenStage documentation. Instead of using the module names
`A`, `B`, and `C` — cleverly named as they may be — I changed them to
`Publisher`, `PubSub`, and `Subscriber` respectively.

Let's look first at the `Publisher` module:

```elixir
defmodule Publisher do
  use GenStage

  def start_link() do
    GenStage.start_link(Publisher, 0, name: Publisher)
  end

  def init(counter) do
    {:producer, counter}
  end

  def handle_demand(demand, 6) when demand > 0 do
    # Stop everything when the state reaches 6. i.e. 5 iterations
    System.halt(0)
    {:stop, :normal}
  end

  def handle_demand(demand, counter) when demand > 0 do
   # return the incremented counter
    {:noreply, [counter+1], counter + 1}
  end
end
```

Beginning with the `start_link/0` and `init/1` functions, you'll see that we're
setting the state to 0 and declaring this module to be a `:producer`. In the
second `handle_demand/2` function, we're returning an incremented counter, and
also incrementing the state by one. The first `handle_demand/2` function stops
the process when the state reaches 6.

Let's skip the `PubSub` module for a moment and look at `Subscriber`.

```elixir
defmodule Subscriber do
  use GenStage

  def start_link() do
    GenStage.start_link(Subscriber, :ok)
  end

  def init(:ok) do
    {:consumer, :na, subscribe_to: [{PubSub, max_demand: 1}]}
  end

  def handle_events(events, _from, state) do
    Process.sleep(250)

    IO.puts events

    {:noreply, [], state}
  end
end
```

The module starts up by declaring itself to be a `:consumer`, with no state
(`:na`), and subscribes itself to the `PubSub` module. Then, the handle the
events (`handle_events/3`) function sleeps for a quarter of a second and then
prints the data to `stdout`. Finally, it returns the standard response for a
`:consumer` of `:noreply`, no events, and an irrelevant state.

Now let's look at the real worker of this system, `PubSub`:

```elixir
defmodule PubSub do
  use GenStage

  def start_link() do
    GenStage.start_link(PubSub, :ok, name: PubSub)
  end

  def init(:ok) do
    {:producer_consumer, :na, subscribe_to: [{Publisher, max_demand: 1}]}
  end

  def handle_events([event], _from, state) do
    events = Enum.map(1..10, &("#{event} :: #{&1}"))

    {:noreply, events, state}
  end
end
```

Again, the module starts up, declares itself to be a `:producer_consumer`, sets
its state to something meaningless, and subscribes to the `Publisher` module.
The interesting work happens in the `handle_events/3` function.

As the documentation is currently written, it gives the impression that
`handle_events/3` takes in a collection of "events", transforms them, and then
outputs the same number of items. In reality, any number of "events" can be
returned. It's only when the list of "events" has been depleted that demand will
be sent up to the producer module.

In the code above, the `Publisher` module is producing events from 1 to 6. As
those events are read in by the `PubSub` module, it is effectively multiplying
its results by 10. The output looks like this:

```
1 :: 1
1 :: 2
1 :: 3
1 :: 4
1 :: 5
...
5 :: 6
5 :: 7
5 :: 8
5 :: 9
5 :: 10
```

Even though we began with five items in the `Publisher` module, we ended up
outputting 50 items showing that we are not limited to a mere 1:1 relationship
between `publisher`, `publisher_consumer`, and `consumer`, but rather a 1:n
relationship. As more `publisher_consumer`s are added to the flow, the
relationship changes to a 1:n:n, vastly increasing what's possible.

## Crossing the Finish Line

Much like a [Kanban](https://en.wikipedia.org/wiki/Kanban_%28development%29)
board, GenStage allows us to view our processes and data in "stages". In so
doing, we can more easily reason through the requirements of each stage, locate
and eliminate bottlenecks, distribute processing, and adjust to demand. In fact,
that's what the goals of the GenStage project are:

> One of the original motivations for creating and designing Elixir was to
> introduce better abstractions for working with collections. Not only that, we
> want to provide developers interested in manipulating collections with a path
> to take their code from eager to lazy, to concurrent, and then distributed.  
> – José Valim [Announcing Genstage](https://elixir-lang.org/blog/2016/07/14/announcing-genstage/)

GenStage was the right tool for the project I was working on. It allowed me to
easily group the data by sources, make only the requests I needed, and most
importantly, reason about the flow of the data. Not only this, but it allowed us
to break out the requests into multiple processes without overloading our data
providers. Elixir and GenStage trivialized what could have been a threading
nightmare.
