---
title: Crawling the Web with Elixir's Broadway and Wallaby
date: 2025-11-06T00:00-05:00
draft: false
description: ""
image: /assets/images/crawling_the_web/elixir-crawl.png
comments: false
post: true
categories: [elixir, broadway, wallaby, web crawling]
---

So it's come to this: you need to programmatically retrieve data from a website
(or websites), but the usual tools aren't cutting it. Maybe the
site uses a CDN and blocks tools like [cURL](https://github.com/curl/curl) and
[wget](https://www.gnu.org/software/wget/). Or maybe it's JavaScript-heavy and
what you normally use can't execute the JS like a browser would, or maybe you
need something with more intelligence. Whatever the case, you're at the
point where you need to build your own crawler.

Thankfully, Elixir's [Broadway](https://github.com/dashbitco/broadway) and
[Wallaby](https://github.com/elixir-wallaby/wallaby) libraries provide an
excellent solution: Broadway to manage concurrency and load, and
Wallaby&mdash;while normally used for User Acceptance Testing&mdash;to handle
visiting and processing webpages; even JS-heavy sites.

In this article, we'll quickly review where we've been with custom Broadway
producers, look at the architecture of where we want to go, and then go over the
additions and changes we need to make to get to that final solution.

## Broadway and Custom Producers

<aside class="panel panel-default pull-right col-md-4">
  This article builds on my previous articles, <a href="https://samuelmullen.com/articles/understanding-elixirs-broadway">Understanding Elixir's Broadway</a> and
  <a href="https://samuelmullen.com/articles/building-custom-producers-with-elixirs-broadway">Building Custom Producers with Elixir's Broadway</a>.
  If you haven't read those yet, you should stop reading this article and go
  read them first. This article is only going to confuse you without the
  foundation of the previous two.
</aside>

As you probably know, Broadway is a sort of mini-framework built on top of the
[GenStage](https://github.com/elixir-lang/gen_stage) library. It's concurrent
and robust, and has built-in batching, rate limiting, and back-pressure. This
means that instead of accepting data "pushed" to it, it "pulls" the data from
its data sources via its producers. These data sources can be anything:
databases, Kafka streams, SQS queues, or, as we'll see in this article,
websites.

To be able to pull data from websites, we'll need a custom producer that's able
to provide the Broadway consumer with URLs from which to fetch data. We've
already seen how to do that in [my previous article](https://samuelmullen.com/articles/building-custom-producers-with-elixirs-broadway),
and in this article we'll tweak it slightly to customize how each site is
crawled.

Let's look at what the architecture of our app will look like when completed.

## Architecture

Here’s the basic architecture of the crawler. The `URLQueue` is where
everything starts. Once a URL is added to it, the `URLProducer` provides it to
the `Pipeline`, which tells the `Crawler`s to process it. The `Crawler`s then
find links on the page and adds them to the `URLQueue` to keep the cycle going.

```
         +------------+
         |            |             +-------------+
         |  Pipeline  |<------------| URLProducer |
         |            |             +-------------+
         +------------+                    ^
                |                          |
                v                          |
 + - - - - - - - - - - - - - -+            |
   Processors                              |
 |                            |      +----------+
    +---------+  +---------+   ----->| URLQueue |
 |  | Crawler |  | Crawler |  |      +----------+
    +---------+  +---------+
 + - - - - - - - - - - - - - -+
        |           |
        v           |
 +-------------+    |        *----*----*
 | URLRegistry |    -------->|  Magic  |
 +-------------+             *----*----*
```

The `Pipeline` is the Broadway consumer. This module defines what producers to
use, how many processors to run, how to transform the data provided by the
producer, and finally how to process it.

The `URLProducer` is a `GenStage` producer that pulls data from the `URLQueue`
and provides data to the `Pipeline` consumer. It remains unchanged from the
previous article.

The `URLQueue` is a `GenServer` used to keep track of what URLs to crawl next.
As mentioned previously, this is just a `List`, but could easily be a `:queue`
or even outsourced to SQS, Kafka, or some other datastore.

Crawlers are the workhorses of this architecture. The way we're building it,
each site we want to crawl will have its own `Crawler`, which is responsible for
finding and storing links in the `URLQueue`, processing the webpage (i.e.
Magic), and registering the URL in the `URLRegistry` so it's not crawled again.

Finally we have the `URLRegistry`. This `GenServer` is responsible for keeping a
list of URLs which have been crawled. If a URL is in the list, it should be
skipped by the `Crawler`. In this version, we're using a `MapSet`, but for
serious work you should use a datastore like `ETS` or Redis.

## Pipeline v2

`Pipeline` is the Broadway consumer which provides configuration for the
producer and processors. For the sake of simplicity, we're forgoing the use of
batching processes.

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

  def handle_message(:default, %Message{data: %{module: module, url: url}} = message, _context) do
    module.crawl(url)
    message
  end

  def transform(url_item, _opts) do
    %Broadway.Message{
      data: url_item,
      acknowledger: Broadway.NoopAcknowledger.init()
    }
  end

  def ack(_ref, _successes, _failures) do
    :ok
  end
end
```

With the exception of the `handle_message/3` function, the module remains
unchanged from my previous article. You'll note the `data` field in `%Message{}`
now expects a `Map` with keys of `module` and `url` instead of the previous
URL string. Also note that we're calling the `crawl/1` function of the `module`
that's passed in. We'll get to that next.

## Crawler

Unless you're building a crawler for a search engine, LLM, or internet archiving
service&mdash;and if you are, this is not the article you should be
reading&mdash;you'll only need to crawl a handful of sites. If that's the
case, you'll likely also have specific requirements you're looking for: links to
follow, data to retrieve, and pages to skip. With that in mind, we'll build our
`Crawler` to limit itself to a single site, [Internet Assigned Numbers
Authority](https://iana.org) by starting the crawl at [https://example.com](https://example.com).

Before we begin, you'll need to install Elixir's
[Wallaby](https://github.com/elixir-wallaby/wallaby) library (as you would any
other library) and Google's
[chromedriver](https://developer.chrome.com/docs/chromedriver) (On a mac: `brew
install chromedriver`).

**Note:** You may also need to install `google-chrome` as well (`brew install
google-chrome`).

Below is our crawler, `MyApp.Crawlers.Example`, in its entirety. It looks like a
lot, but there's only two public API functions&mdash;`init/0` and
`crawl/1`&mdash;both of which are described in more detail below. The module
itself is responsible for starting and stopping the `Wallaby` session, visiting
pages, capturing links to follow, and processing pages. We'll break it down into
smaller chunks below.

```elixir
defmodule MyApp.Crawlers.Example do
  alias MyApp.{URLQueue, URLRegistry}
  alias Wallaby.{Browser, Element, Query}

  def init() do
    URLQueue.push(%{
      module: __MODULE__,
      url: "https://example.com"
    })
  end

  def crawl(url) do
    session()
    |> Browser.visit(url)
    |> process_links()
    |> process_page(url)
    |> Wallaby.end_session()
  end

  defp session() do
    {:ok, session} = Wallaby.start_session(
      capabilities: %{
        chromeOptions: %{
          args: [
                "--headless",
                "--no-sandbox",
                "window-size=1280,800",
                "--fullscreen",
                "--disable-gpu",
                "--disable-dev-shm-usage"
          ]
        }
      }
    )

    session
  end

  defp process_links(session) do
    css_selectors = "header a, footer a"

    session
    |> Browser.all(Query.css(css_selectors, minimum: 0))
    |> Enum.each(&store_link/1)

    session
  end

  defp process_page(session, url) do
    IO.inspect "Processing page: #{url}"
    session
  end

  defp store_link(element) do
    element
    |> Element.attr("href")
    |> _store_link()
  end

  defp _store_link("https://www.iana.org/" <> _rest = url) do
    _store_good_link(url)
  end

  defp _store_link("https://iana.org/" <> _rest = url) do
    _store_good_link(url)
  end

  defp _store_link(url) do
    IO.inspect url, label: "Some other link"
    :ok
  end

  defp _store_good_link(url) do
    url_item = %{
      url: url,
      module: __MODULE__
    }

    case URLRegistry.registered?(url_item) do
      true ->
        :ok
      false ->
        IO.inspect url_item
        URLRegistry.register(url_item)
        URLQueue.push(url_item)
    end
  end
end
```

**Fun Fact:** setting `css_selectors` to `"a"`, and changing `_store_link/1` to
accept any URL, will crawl the entire internet, but not before you've consumed
all your computer's resources. I don't recommend it.

### `init/0`

As its name implies, `init/0` is responsible for initializing the Crawler into
action. It does so by "pushing" a `Map` containing the `module` and starting
`url`, in this case `MyApp.Crawlers.Example` and "https://example.com"
respectively. With this `Map` in the `URLQueue`, the `URLProducer` can retrieve
it and pass it to the `Pipeline`.

```elixir
def init() do
  URLQueue.push(%{
    module: __MODULE__,
    url: "https://example.com"
  })
end
```

### `crawl/1`

The `crawl/1` function accepts a URL in the form of a string and creates a
pipeline for processing that URL. It's a very readable function, but there are a
couple things to take note of: 1) it starts by creating a `Wallaby` session
token and passes that along through the whole pipeline; 2) it finishes by ending
the `Wallaby` session. This last piece is very important. If you don't end the
`Wallaby` session, you will end up with lots of `chromedriver` instances running
on your computer.

```elixir
def crawl(url) do
  session()
  |> Browser.visit(url)
  |> process_links()
  |> process_page(url)
  |> Wallaby.end_session()
end
```

### `session/0`

The pipeline described in `crawl/1` passes a `Wallaby` `session` token to each
function. The `session` is created using the `start_session/1` function. The
`chromeOptions` used are what I found to be the minimum required options to
work. A full list of options can be found on the [Chromium Command Line Switches
page](https://peter.sh/experiments/chromium-command-line-switches/).

```elixir
defp session() do
  {:ok, session} = Wallaby.start_session(
    capabilities: %{
      chromeOptions: %{
        args: [
              "--headless",
              "--no-sandbox",
              "window-size=1280,800",
              "--fullscreen",
              "--disable-gpu",
              "--disable-dev-shm-usage"
        ]
      }
    }
  )

  session
end
```

I should also add that `Wallaby` itself can be configured from a `Config` file.
A basic example is provided below:

```elixir
# my_app/config/config.exs

import Config

config :wallaby,
  js_errors: false,
  driver: Wallaby.Chrome,
  hackney_options: [timeout: 5_000, recv_timeout: :infinity, pool: :wallaby_pool]
```

### `process_links/1`

With the `session` token in hand, we can now start processing our page. The
first step is to find all the links on the page and store them. We can do that
with `Wallaby`'s `Query.css/2` function. Below you can see that we're only
looking for links in the `header` and `footer` elements, which once found,
we iterate through each to store them using `store_link/1`.

```elixir
defp process_links(session) do
  css_selectors = "header a, footer a"

  session
  |> Browser.all(Query.css(css_selectors, minimum: 0))
  |> Enum.each(&store_link/1)

  session
end
```

### `store_link/1`

Even though the `store_link/1` function and its associated private functions
take up more space than anything else in the module, it's relatively simple and
can be broken down into the following steps:

1. Retrieve the URL from the anchor element passed in
2. Compare it against allowed domains
3. Push it onto the `URLQueue` and `URLRegistry` if it's an allowed domain
4. Ignore it if it's not an allowed domain

The `store_link/1` function is what starts things off. It accepts an `Element`
`struct`, retrieves the URL from the `href` attribute, and passes that value to
`_store_link/1`.

`_store_link/1` then uses binary matching to filter out URLs that aren't
allowed. In our case, we're only looking for URLs under the "iana.org" domain.
If it matches we call `_store_good_link/1`, otherwise we print the URL to
`stdout` with the label of "Some other link."

The final step is to call the `_store_good_link/1` function. This function
builds a `Map` containing two items: a `url` and the `module` used to crawl
that URL (`module.crawl` is used on line 25 of the `Pipeline` module.) Next, it
checks to see if that `url_item` has already been registered in the
`URLRegistry`. If it has, it returns `:ok`, otherwise it prints out the
contents, registers the item, and pushes it onto the queue to be crawled.

```elixir
defp store_link(element) do
  element
  |> Element.attr("href")
  |> _store_link()
end

defp _store_link("https://www.iana.org/" <> _rest = url) do
  _store_good_link(url)
end

defp _store_link("https://iana.org/" <> _rest = url) do
  _store_good_link(url)
end

defp _store_link(url) do
  IO.inspect url, label: "Some other link"
  :ok
end

defp _store_good_link(url) do
  url_item = %{
    url: url,
    module: __MODULE__
  }

  case URLRegistry.registered?(url_item) do
    true ->
      :ok
    false ->
      IO.inspect url_item
      URLRegistry.register(url_item)
      URLQueue.push(url_item)
  end
end
```

### `process_page/2`

The last step in the Crawler pipeline before we end the session is
`process_page/2`. This is where the magic happens. In our example, all we do is
print out that we're processing the page, but in a "real world" scenario, this
is where you would retrieve data from the page, submit forms, follow links, etc.
I'll leave it up to you to determine how best to complete this function. You
will, however, need to return the session object in order to successfully end
the session.

```elixir
defp process_page(session, url) do
  IO.inspect "Processing page: #{url}"
  session
end
```

## URLRegistry

The last module to consider from the architecture section, and perhaps a bit
anti-climactic, is the `URLRegistry`. It's a `GenServer` that uses a `MapSet` to
store a unique list of `url_item`s. The two functions in the API you will use
are `register/1`, to register a `url_item`, and `registered?` to determine if a
`url_item` has already been crawled.

```elixir
defmodule MyApp.URLRegistry do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def register(url_item) do
    GenServer.cast(__MODULE__, {:register, url_item})
  end

  def registered?(url_item) do
    GenServer.call(__MODULE__, {:registered?, url_item})
  end

  @impl GenServer
  def init(_args), do: {:ok, MapSet.new()}

  @impl GenServer
  def handle_cast({:register, url_item}, state) do
    {:noreply, MapSet.put(state, url_item)}
  end

  @impl GenServer
  def handle_call({:registered?, url_item}, _from, state) do
    {:reply, MapSet.member?(state, url_item), state}
  end
end
```

This is a very naive approach to keeping track of crawled URLs, but is useful
for demonstration purposes. In a production environment, you might consider an
ETS table or a Redis store with TTL (Time to Live) settings so pages can be
re-crawled after a set period of time.

## Running the Crawler

To run the example Crawler, you need to start the `URLQueue`, `Pipeline`, and
`URLRegistry` processes, and then execute the `init/0` function for the desired
Crawler. Here's an example of doing that and the resulting output.

```elixir
iex1> MyApp.URLQueue.start_link([])
{:ok, #PID<0.252.0>}

iex2> MyApp.Pipeline.start_link([])
{:ok, #PID<0.253.0>}

iex3> MyApp.URLRegistry.start_link([])
{:ok, #PID<0.254.0>}

iex4> MyApp.Crawlers.Example.init()
:ok

...after a few moments of waiting...

%{
  module: MyApp.Crawlers.Example,
  url: "https://www.iana.org/"
}
%{
  module: MyApp.Crawlers.Example,
  url: "https://www.iana.org/domains"
}
%{
  module: MyApp.Crawlers.Example,
  url: "https://www.iana.org/protocols"
}

...

Some other link: "https://pti.icann.org/"
Some other link: "https://www.icann.org/"
Some other link: "https://www.icann.org/privacy/policy"
Some other link: "https://www.icann.org/privacy/tos"
"Processing page: https://www.iana.org/help/example-domains"
Some other link: "https://pti.icann.org/"
Some other link: "https://www.icann.org/"
Some other link: "https://www.icann.org/privacy/policy"
Some other link: "https://www.icann.org/privacy/tos"
"Processing page: https://www.iana.org/about/excellence"
Some other link: "https://pti.icann.org/"

```

In a supervised app, you'd just need to add those processes to your
`application.ex` file.

```elixir
def start(_type, _args) do
  children = [
    {MyApp.URLQueue, []},
    {MyApp.Pipeline, []},
    {MyApp.URLRegistry, []}
  ]

  opts = [strategy: :one_for_one, name: Glutton.Supervisor]
  Supervisor.start_link(children, opts)
end
```

## Consider Also...

Before we wrap this up there are a few things you should also consider before
building your own crawler(s).

### Be a Good Netizen

Crawling a webpage requires resources from the hosting site and you'll want to
make sure you don't overload that site consuming their data. To that end, the
authors of the excellent [Crawly](https://github.com/elixir-crawly/crawly)
library have provided four items which define a polite crawler:

1. A polite crawler respects `robots.txt`.
1. A polite crawler never degrades a website’s performance.
1. A polite crawler identifies its creator with contact information.
1. A polite crawler is not a pain in the buttocks of system administrators.

### Poolboy

In the `Example` crawler we initiate and end a Wallaby session in the `crawl/1`
pipeline. But what happens if an error occurs before the pipeline finishes?
Well, you end up with an unfinished session which can eat up resources. A better
solution would be to use [poolboy](https://github.com/devinus/poolboy) to manage
sessions.

For brevity's sake, I didn't include poolboy's use in this article, but I have
another article tackling it's use: [Elixir, Poolboy, and Little's
Law](https://samuelmullen.com/articles/elixir-poolboy-and-littles-law).

### Build Crawlers with Protocols or Behaviours

If you end up with multiple Crawlers, you might find it beneficial to use either
a Protocol or Behaviour to reduce code duplication. Again, I didn't include that
here for the sake of brevity, but what a great idea for an article.

### Using Floki

Wallaby's good at retrieving HTML from a page, but if you need more control over
parsing it, you can output the page source with `Wallaby.Browser.page_source/1`
and use [Floki](https://github.com/philss/floki) to get at the content you want.


## Wrapping Up

Crawling the web, like traversing a file system, is a kind of recursive process:
you start from a single page, collect all the links from it, crawl the next
page, collect the links, and so on until you've crawled everything you need.
It's a perfect problem to solve with Broadway, thanks to its concurrent
processing, use of back-pressure, and rate-limiting. When combined with Wallaby
and its use of headless browsers, you're no longer limited to traditional
HTML-only pages, but can crawl SPA sites as well.

All the code above and from my [Building Custom Producers with Elixir's
Broadway](https://samuelmullen.com/articles/building-custom-producers-with-elixirs-broadway)
article can be found in my [Glutton](https://github.com/samullen/glutton) GitHub
repo.

