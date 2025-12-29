---
title: Asynchronous Tasks and Streaming UIs in Phoenix Liveview
date: 2025-12-29T00:00-05:00
draft: false
description: "A guide to the native asynchronous suite in Phoenix LiveView. Master assign_async/4, stream_async/4, and start_async/4 to handle LLM streaming and background tasks with ease."
image: /assets/images/asynchronous_tasks_and_streaming_uis/async_streaming.png
comments: false
post: true
categories: [elixir, liveview, phoenix]
---

<aside class="panel panel-default pull-right col-md-4">
<h3>For What It's Worth</h3>
<p>Sean's article was bleeding edge and about as simple as it could get when it
was written. The solutions described in this article weren't available until
five months after he wrote his.</p>
</aside>

The [three great virtues of a programmer](https://thethreevirtues.com/) are
laziness, impatience, and hubris. I lean toward laziness more than the other
two, often thinking, "There's got to be an easier way." A recent example of this
was when I was experimenting with streaming LLM output in LiveView. While
researching, I found that the most popular article on the topic, [Streaming ChatGPT Responses With Phoenix LiveView](https://www.hackwithgpt.com/blog/streaming-chatgpt-responses-with-phoenix-liveview/)
by Sean Moriarity, to be quite complex. I knew there had to be a simpler
solution; that's when I stumbled across LiveView's asynchronous functions:
`assign_async/4`, `stream_async/4`, `start_async/4`, and `handle_async/3`.

These functions leverage Elixir's lightweight processes to perform work off the
main LiveView process. When the work is completed, your application can deal
with the results without disrupting your user's experience.

## Use cases

There are any number of reasons and situations where you might want to run
processes asynchronously in LiveView: presenting a dashboard immediately while
allowing charts and graphs to eventually load, performing multiple data fetches
concurrently, isolate the UI from high-latency or failure-prone operations,
presenting data as it becomes available, etc. Every use case boils down into
three general categories:

- **Streaming data:** Examples of this include LLM-style data output, displaying
  log output, and live data feeds.
- **Long running processes:** Running reports, progressive rendering, and
  fire-and-forget-it style processes are all potential use cases.
- **Resilience and lifecycle management:** Allows you to separate the retrieval
  of data from its presentation.

To demonstrate these use cases and how each of the four "async" functions can be
used to address the use case, we'll use a simple LiveView module, rewriting it
for each example.

### `assign_async/4`

`assign_async/4` is as straightforward as it gets, and once you've
seen how to use it, you'll start using it all the time. It's just like using
`assign/3`, but instead of assigning a value, you provide it with a function.
Upon completion, the function updates the assigned key with the result. In the
code below (line 28), we assign `async_output` the `simulate_work/0` function
which, when called, "sleeps" for two seconds, and then returns a success tuple
with key set to "Well that took a long time!".

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  alias Phoenix.LiveView.AsyncResult

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :async_output, AsyncResult.loading(false))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <button phx-click="output" class="bg-blue-600 text-white py-2 px-4">
      Async output!
    </button>

    <%= if @async_output.ok? do %>
      <p><%= @async_output.result %></p>
    <% end %>
    """
  end

  @impl true
  def handle_event("output", _params, socket) do
    {:noreply, assign_async(socket, :async_output, &simulate_work/0)}
  end

  defp simulate_work() do
    Process.sleep(2000)
    {:ok, %{async_output: "Well that took a long time!"}}
  end
end
```

If you were to run the code above, you could click a button and then see "Well
that took a long time!" displayed below the button two seconds later.

One thing to note, which will also come into play in the other functions, is the
use of `Phoenix.LiveView.AsyncResult`. We use this module to keep track of a
key's status. We initialize `AsyncResult` with `loading: false` to represent an
idle state. When the `simulate_work/0` function completes, it automatically
updates `AsyncResult` with an `ok` status.

> Each key passed to `assign_async/3`; will be assigned to an
> `Phoenix.LiveView.AsyncResult` struct holding the status of the operation and
> the result when the function completes.

### `stream_async/4`

In all honesty, I've struggled to figure out why `stream_async/4` exists. I
understand that it's supposed to help with reducing the boilerplate of
`start_async/4` and `handle_async/3`, but it also appears to only work in the
`mount/3` function and it requires a specific data structure to integrate with
Phoenix streams. But for the sake of completeness...

Below is an example of using it to display a list of ten random words from the
Lorem Ipsum after a one-second delay.

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  alias Phoenix.LiveView.AsyncResult

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream_async(:async_output, &stream_response/0)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.async_result :let={async_output} assign={@async_output}>
      <:loading>Loading output...</:loading>
      <:failed :let={_failure}>there was an error loading the output</:failed>
      <%= if async_output do %>
        <ul>
        <%= for {x, item} <- @streams.async_output do %>
          <li>ID: <%= x %> - <%= item.id %> - <%= item.word %></li>
        <% end %>
        </ul>
      <% else %>
        You don't have output yet.
      <% end %>
    </.async_result>
    """
  end

  defp stream_response() do
    Process.sleep(1000)

    words =
      "Lorem ipsum dolor sit amet, ullum phaedrum in est, sit viris dissentiunt eu. Ad qui aperiri senserit necessitatibus. In ferri persius vel, te option saperet pertinacia sit. At duis nulla zril per. Alienum accumsan qui ei, at quem constituto pri, ei facer libris cum. Doctus integre blandit pri an, quas intellegam quaerendum eu per."
      |> String.split()
      |> Enum.take_random(10)
      |> Enum.with_index(fn word, idx -> %{id: idx, word: word} end)

    {:ok, words}
  end
end
```

<aside class="panel panel-default pull-right col-md-4">
<h3>In all fairness</h3>

<p>I spent way too much time trying to figure out `stream_async/4`, and my
negative attitude about the function may be the result of my annoyance at
that.</p>
</aside>

It looks more complicated than what it is. The bulk of the work is in the stream
response which sleeps for one second (i.e. 1,000 milliseconds), and then pulls
10 random words from the Lorem Ipsum string which it returns as an `:ok` tuple.
The list of words is then rendered in the `async_result/1` block. We use
`async_result/1` for rendering, because it handles the potential errors that
`stream_async/4` might receive. If, for example, `stream_response/0` returns an
`:error` tuple, `async_result/1` would have rendered "there was an error loading
the output".

This is an example what the above LiveView module will present after waiting one
second:

```
ID: async_output-0 - 0 - In
ID: async_output-1 - 1 - necessitatibus.
ID: async_output-2 - 2 - pri
ID: async_output-3 - 3 - aperiri
ID: async_output-4 - 4 - Ad
ID: async_output-5 - 5 - ullum
ID: async_output-6 - 6 - quaerendum
ID: async_output-7 - 7 - dissentiunt
ID: async_output-8 - 8 - intellegam
ID: async_output-9 - 9 - ei,
```

In my personal opinion, you're better off skipping this function and using to
the next two. They're much more flexible and provide finer control over what and
when you can perform asynchronous work.

### `start_async/4` and `handle_async/4`

Anything you can do with `assign_async/4` and `stream_async/4`, you can do with
`start_async/4` and `handle_async/3`. In the example below, we'll use the two
functions to stream random words to the page in the same way an LLM might. The
module creates a very simple LiveView page. It has a "Go!" button, which
triggers the word stream. A "Cancel" button which cancels the stream and is only
visible while words are streaming. Lastly, it has a "Reset" button to clear out
previously streamed words.

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view

  alias Phoenix.LiveView.AsyncResult

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:lorem, "")
      |> assign(:async_state, AsyncResult.loading(false))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%= if @async_state.loading do %>
      <button phx-click="cancel" class="bg-red-800 text-white py-2 px-4">
        Cancel
      </button>
    <% else %>
      <button phx-click="go" class="bg-blue-600 text-white py-2 px-4">
        Go!
      </button>
      <button phx-click="reset" class="bg-blue-600 text-white py-2 px-4">
        Reset
      </button>
    <% end %>

    <br />

    {@lorem}
    """
  end

  @impl true
  def handle_event("go", _params, socket) do
    pid = self()

    socket =
      socket
      |> assign(:async_state, AsyncResult.loading())
      |> start_async(:data_stream, fn ->
        stream_response(pid)
      end)

    {:noreply, socket}
  end

  def handle_event("reset", _params, socket) do
    socket =
      socket
      |> assign(:async_state, AsyncResult.ok("Reset"))
      |> assign(:lorem, "")

    {:noreply, socket}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, cancel_async(socket, :data_stream)}
  end

  @impl true
  def handle_async(:data_stream, {:exit, {:shutdown, :cancel}}, socket) do
    {:noreply, assign(socket, :async_state, AsyncResult.ok("cancelled"))}
  end

  @impl true
  def handle_info({:render_lorem, word}, socket) do
    lorem = socket.assigns.lorem <> " " <> word

    {:noreply, assign(socket, lorem: lorem)}
  end

  defp stream_response(pid) do
    word =
      "Lorem ipsum dolor sit amet, ullum phaedrum in est, sit viris dissentiunt eu. Ad qui aperiri senserit necessitatibus. In ferri persius vel, te option saperet pertinacia sit. At duis nulla zril per. Alienum accumsan qui ei, at quem constituto pri, ei facer libris cum. Doctus integre blandit pri an, quas intellegam quaerendum eu per."
      |> String.split()
      |> Enum.random()

    Process.sleep(150)

    send(pid, {:render_lorem, word})
    stream_response(pid)
  end
end
```

### Go!

Clicking the "Go!" button starts everything off. The `handle_event/3` function
on line 39 first sets the `pid` variable to the current process. Next, it
assigns the `:async_state` to "loading", and finally starts `stream_response/1`
function by using the `start_async/4` function.

`stream_response/1` might look a little complicated, but all it does is grab a
random word from the Lorem Ipsum string, sleeps for 150 milliseconds, sends the
word to the parent process, and then call itself again (i.e. recursion). We pass
the `pid` to `stream_response/1`, because `start_async/4` starts it as a child
process and we use that child process to return the data to the parent. By
passing the parent PID, the child process can utilize message passing to update
the UI.

The final piece of the puzzle is `handle_info/2` on line 71. This function
matches messages sent with `{:render_lorem, word}`, (e.g. sent from
`stream_response/1`.) It then appends the word to the `:lorem` assigns variable.
At that point, the page is updated with the new string.

<img src="{{ site.url }}/assets/images/asynchronous_tasks_and_streaming_uis/streaming_capture.gif" class="img-thumbnail">

Most applications won't need streaming data. Instead, you'll use
`start_async/4`/`handle_async/3` to perform multiple, related tasks and assign
the results as needed. An example might be to fetch stock data from an external
source, store the results to the database, and then pull the list of stock
data from the database to recalculate and display on the page.

### Cancel

When you click the "Cancel" button, it triggers the "cancel" event on line 61.
This event first sets the `:async_state` to "cancelled", and then uses the
`cancel_async/3` function to terminate functions spawned by `start_async/4`.
This also has the side effect of executing the `handle_async/3` function with
the `{:exit, {:shutdown, :cancel}}` tuple, which just sets `:async_state` to
cancelled.

### Reset

The last feature is the "Reset" button. When clicked, this sends the "reset"
event to the `handle_event/3` function on line 52, which then sets
`:async_state` to "Reset" using `AsyncResult.ok/1`, and sets `:lorem` to
an empty string.

## In Summary

The evolution of Phoenix LiveView has turned what used to be a complex
orchestration of manual process management into a streamlined, declarative
developer experience. By embracing the "async" suite of functions, you can
adhere to the programmer's virtue of laziness—writing less boilerplate while
achieving more robust results.

### Choosing the Right Tool

To help you decide which function fits your specific needs, here is a quick
reference:

| Function                       | Best For...                                      | Key Advantage                                                       |
|--------------------------------|--------------------------------------------------|---------------------------------------------------------------------|
| assign_async/4                 | Simple data fetching                             | Minimal setup; handles the AsyncResult state automatically.         |
| stream_async/4                 | Initial page loads of collection data.           | Integrates directly with Phoenix Streams for efficient DOM updates. |
| start_async/4 & handle_async/3 | Complex workflows, streaming, and cancellations. | Full control over the process lifecycle and manual messaging.       |

While Sean Moriarity’s original approach was an excellent solution when written,
the introduction of these native async utilities means we no longer have to
"fight" the framework to handle long-running tasks. Whether you are building
dashboards or a real-time LLM interface, these tools allow you to keep the
UI responsive and your code maintainable.
