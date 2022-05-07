+++
author = "Samuel Mullen"
date = "2016-09-29T06:39:51-05:00"
description = "An introduction to ActionCable with a focus on how things work rather than how to make them work."
tags = ["rails", "ruby", "actioncable"]
title = "An Introduction to ActionCable in Rails 5"

+++

Ruby on Rails 5.0+ has been out for a few months now and has brought with it a
number of much needed improvements (AdequateRecord, Rails API), and a few which
were more controversial such as ApplicationRecord. When it was first
announced, ActionCable was among the "more controversial" features – coming as a
surprise to even some of the core team – but now it's regarded as the next
logical step in Rails' evolution.

ActionCable brings [WebSockets](https://en.wikipedia.org/wiki/WebSocket) to your
Rails application, allowing "for real-time features to be written in Ruby in the
same style and form as the rest of your Rails application, while still being
performant and scalable." ([ActionCable Overview](http://guides.rubyonrails.org/action_cable_overview.html)) Of course Ruby can only be run on the server, so it
also provides a JavaScript framework as part of the stack.

More than just chat rooms
-----------------------------------

<aside class="panel panel-default pull-right col-md-6">
<h3>Websockets</h3>

<p>Traditionally when a web browser loads a page it's a one-time transaction. The browser makes the request for the HTML, CSS, and the requisite assets, which the server then dutifully provides. Unless further action is performed on the client's side (clicking a link, submitting a form, etc.) the interaction is complete.</p>

<p>Now, with the inclusion of the websocket protocol, a webpage can continue to both send and receive data along a "channel" which remains open between the browser and the web server. This open channel allows the server to respond more quickly to the client, but more importantly, it allows the client (i.e. browser) to receive data without the need for refreshing the page.</p>
</aside>

When considering real-time components for the web, our thoughts are inevitably
drawn to creating chat rooms. It's the obvious choice: we're familiar with them,
they're the perfect example of "real-time", and 98% of the examples available
seem to be exactly that.

Of course there is more to web sockets than just chat rooms, but drawing from
our understanding of chat rooms we can see potential opportunities for products
and improved user experiences such as helpdesk chats. As we further remove
ourselves from chat, we can also imagine live comments for blogs or discussion
sites, and from there it's not difficult to see the opportunity of viewing any
kind of personal update (i.e. likes, images, and reposts). Finally, as we
disconnect ourselves from the idea of person-to-person interaction and toward
website components being the recipients of live data, new ideas abound: stock
tickers, live poll results, notifications, log feeds, and more. 

ActionCable Lifecycle
----------------------------

Before we dive into an example, we need to get a better idea of what happens
when a user loads an ActionCable enhanced page. ActionCable's has a lot of
moving parts, and the following list details which of those parts come in to
play during a page's life cycle, and when.

1. A user loads an ActionCable enabled page
2. The consumer (i.e. browser) informs the server it can take connections via `/app/assets/javascripts/cable.js`
3. The server determines authentication of the consumer: `/app/channels/application_cable/connection.rb`
4. A "connection" (i.e. cable) is established when the consumer subscribes to any of the available channels: `/app/assets/javascripts/cable/subscriptions/*.js`
5. Data is broadcast through "channels" (`/app/channels/*Channel.rb`) within the connection to the appropriate subscribers
6. Data is received on those channels for specific subscribers (see #4) and an action is triggered.
7. Finally, the connection is closed when the consumer is refreshed, changes location, or the tab or window is closed.

Nate Berkopec summarizes this process:  

> Action Cable provides the following:
> <ul>
>  <li>A "Cable" or "Connection", a single WebSocket connection from client to server. It's worthwhile to note that Action Cable assumes you will only have one WebSocket connection, and you'll send all the data from your application along different...</li>
>  <li>"Channels" - basically subdivisions of the "Cable". A single "Cable" connection has many "Channels".</li>
>  <li>A "Broadcaster" - Action Cable provides its own server. Yes, you're going to be running another server process now. Essentially, the Action Cable server just uses Redis' pubsub functions to keep track of what's been broadcasted on what cable and to whom.</li>
> </ul>
> – [ActionCable - Friend or Foe?](https://www.nateberkopec.com/2015/09/30/action-cable.html)

Example: Let's go to the polls!
--------------------------------

While chat rooms can be a lot of fun, they're overused as examples for real-time web interactions. Let's do something different; let's create a live-updating poll.
We want to keep this as simple as possible – it's an example after all – so we're only going to look at code immediately related to `ActionCable`. Other code, such as setting up migrations and authentication, are available in the repo, but won't be covered here. You can find the complete app, named [Pollish](https://github.com/samullen/pollish), on [GitHub](https://github.com/).

There are three features we want to implement:

1. **Authentication** - Only signed in users will be able to see the results
2. **Voting** - Everyone can vote, but only once
3. **Results** - The results page will show what's currently in the DB, and will update based on new results that come in

Because this is an introductory article, and we want to focus on ActionCable
itself, we're not going to worry about tests, (but it sounds like a great
subject for a future article.) We'll start off by laying out the groundwork of
our app by creating the page for polls, voting, and results, and then wire it up
with ActionCable.

### Polls

Let's start things off by creating our Polls resource. All we need for this is a page listing the polls in which users can participate and a page where they can cast their vote. We'll do that with a simple `PollsController`.

```
# /app/controllers/polls_controller.rb

class PollsController < ApplicationController
  def index
    @polls = Poll.all
  end

  def show
    @poll = Poll.find(params[:id])
    @vote = @poll.votes.build

    if session[@poll.code].present?
      redirect_to polls_path, notice: "Don't ruin the fun, You've already voted."
    end
  end
end
```

The `PollsController` is straightforward. We don't want people voting more than
once, so we are guarding against that by checking for the presence of the
session variable in the `#show` method.

The views for `#index` and `#show` are equally straightforward:

``` 
<%# index.html.erb %>

<ul>
  <% @polls.each do |poll| %>
    <li><%= link_to poll.name, poll %>
    
    <% if user_signed_in? %>
      [<%= link_to "results", poll_results_path(poll) %>]
    <% end %>
    </li>
  <% end %>
</ul>
```

The `index.html.erb` file allows everyone to see the available polls, but only allows authenticated users access to the final results.

```
<%# show.html.erb %>

<h1><%= @poll.name %> <small>:: <%= @poll.code %></small></h1>

<%= render partial: @poll.code %>
```

The `show.html.erb` file is pretty empty, displaying both the `name` and `code`
of the vote before it renders the partial. As you can see from the last line,
the poll's `code` is the name of the partial file. *Note: This isn't the way you
would want to do things in real life.*

Finally, let's look at the `_example.html.erb` partial. (This will only work for a poll with the `code` "example"):

```
<%# _example.html.erb %>

<p><%= @poll.description %></p>

<%= form_for [@poll, @vote] do |f| %>
  <%= f.radio_button :value, "yes" %>
  <%= f.label :value, "Yes", value: "yes" %>
  <br/>

  <%= f.radio_button :value, "no" %>
  <%= f.label :value, "No", value: "no" %>
  <br/>

  <%= f.radio_button :value, "maybe" %>
  <%= f.label :value, "Maybe", value: "maybe" %>
  <br/>

  <%= f.submit %>
<% end %>
```

The partial does the majority of the work displaying the actual form for the poll. When a person submits their vote, it's sent to the `VotesController` which then redirects the user back to the `PollsController` index page.

```
# /app/controllers/votes_controller.rb

class VotesController < ApplicationController
  def create
    @poll = Poll.find(params[:poll_id])
    @vote = @poll.votes.build(vote_params)

    if @vote.save
      session[@poll.code] = true
      redirect_to polls_path, notice: "Thanks for your vote!"
    else
      flash.now[:alert] = "Are you sure you pressed the button correctly?"
      render partial: "polls/show"
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:value)
  end
end
```

At this point people are able to view the list of available polls and vote in them. Now we need to display the results.

### Results

Like the logic for `PollsController`, the logic for the `ResultsController` is very simple and only requires an `index` action. 

```
# /app/controllers/results_controller.rb

class ResultsController < ApplicationController
  before_action :authenticate_user!

  def index
    @poll = Poll.includes(:votes).find(params[:poll_id])
  end
end
```

For our lone action, we are retrieving a specific `Poll`, and as we do so, we "include" the `votes` relationship to more easily get our poll results in the view.

```
<#= index.html.erb %>

<h1><%= @poll.name %> <small>:: <%= @poll.code %></small></h1>

<h2>Results</h2>

<div style="width: 600px; height: 400px">
<canvas id="chart" width="600" height="400"></canvas>
</div>

<%= render partial: @poll.code %>
```

The only thing to note on the "index" page is the `canvas` section which is
required by [Chart.js](http://chartjs.org) (included in `/views/layouts/application.html.erb`.)

The real magic starts to happen in the partial:

```
<%# /app/views/results/_example.html.erb %>

<%= javascript_tag do %>
var ctx = document.getElementById("chart");
var myChart = new Chart(ctx, {
  type: 'bar',
  data: {
    labels: ["Yes", "No", "Maybe"],
    datasets: [{
      label: '# of Votes',
      data: [
        <%= @poll.votes.find_all {|v| v.value == "yes"}.size %>,
        <%= @poll.votes.find_all {|v| v.value == "no"}.size %>,
        <%= @poll.votes.find_all {|v| v.value == "maybe"}.size %>
      ],
      backgroundColor: [
        'rgba(255, 99, 132, 0.2)',
        'rgba(54, 162, 235, 0.2)',
        'rgba(255, 206, 86, 0.2)',
      ],
      borderColor: [
        'rgba(255,99,132,1)',
        'rgba(54, 162, 235, 1)',
        'rgba(255, 206, 86, 1)',
      ],
      borderWidth: 1
    }]
  },
  options: {
    scales: {
      yAxes: [{
        ticks: {
          beginAtZero:true
        }
      }]
    }
  }
});
<% end %>
```

Although there is quite a bit of code here, the piece to note is where we gather
the vote counts in the `data` key (No, it's not performant.)

<aside class="panel panel-default pull-right col-md-6">
<p>If you're wondering why only signed in users can view the results, it's because I had originally planned on using this app for presentations. The only way for the audience to see the results was to turn their attention back to the presentation. So while I asked people to turn their attention away, I had a means of recapturing it.</p>
</aside>

At this point, we have a fully armed and operational voting machine. People can
participate in polls, they can vote, and if they have accounts, they can see the
results. What we want, however, is for people to see the results update in the chart as votes come in. To do that, we have to connect ActionCable.

<div class="clearfix"></div>

### Connecting ActionCable

As described in "ActionCable Lifecycle" above, the first thing that happens
after an ActionCable page loads, is a connection is made back to the server
through logic in `/app/assets/javascripts/cable.js`. At its most basic – and
indeed all we'll need in our example – the file looks like this:

```
(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

}).call(this);
```

This small block of code is responsible for creating the websocket connection.
If your websockets originate from anywhere other than `/cable`, you would need
to change the initialization to something like this:

```
App.cable = ActionCable.createConsumer("ws://cable.pollish.com");
```

With the client now looking for a place to connect, we must provide it with an endpoint to fulfill that search. To do that, we'll create our `ActionCable::Connection`. Again, this class is responsible for determining authentication of the consumer (i.e. the client or browser)

```
# app/channels/application_cable/connection.rb

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected

    def find_verified_user
      if verified_user = env['warden'].user
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
```

`ActionCable::Connection` uses `identified_by` as "a connection identifier that
can be used to find the specific connection later."([ActionCable Overview](http://guides.rubyonrails.org/action_cable_overview.html)) In the
example above, we're grabbing the user object from the "warden" environment
variable. We can't grab it from the session, because "[t]he WebSocket server
doesn't have access to the session."

Once the connection is established, the ActionCable server is able to identify
the connection and channel through which it will send data.

With our connection established, we're ready to subscribe to channels. Again, we'll start with our client code:

```
// /app/assests/javascripts/cable/subscriptions/polling.js

App.cable.subscriptions.create(
  { channel: "PollingChannel", code: "example" },

  {
    connected: function() {
      console.log("connected");
    },

    disconnected: function() {
      console.log("disconnected");
    },

    rejected: function() {
      console.log("rejected");
    },

    received: function(data) {
      console.log(data);

      myChart.data.datasets[0].data = [
        _.find(data, function(vote) { 
          return vote.value == "yes";
        }).vote_count,
        _.find(data, function(vote) { 
          return vote.value == "no";
        }).vote_count,
        _.find(data, function(vote) { 
          return vote.value == "maybe";
        }).vote_count
      ];
      myChart.update();
    }
  }
);
```

In the code above, we are sending a block of data (the parameters identified by
“channel” and “code”) identifying what the client is subscribing to. The
`channel` parameter is required for ActionCable to determine which channel (in
`/app/channels`) to subscribe to. Any subsequent parameters can be added to
further identify the data to retrieve or just to pass useful information. We'll
look at `PollingChannel` momentarily.

The next thing to notice are the four methods: `connected`, `disconnected`, `rejected`, and `received`. These methods are activated depending on what is happening with the connection. You can add more methods to provide more functionality, but these four will be triggered by ActionCable itself.

The last thing to note is the `received` method. Here we're taking the `data` received and populating a three element array with the counts for "yes", "no" and "maybe". Once we have that, we update `myChart`.

*Note: we're using the `find` method from [lodash.js](https://lodash.com/), and accessing the `myChart` variable defined in `/app/views/results/_example.html.erb`*

Finally, we need the server to publish to our subscriber. We do that with `/app/channels/polling_channel.rb`

From the Rails Guide: 

> If you have a stream that is related to a model, then the broadcasting used can be generated from the model and channel.

This is exactly what we're doing here: 

```
class PollingChannel < ApplicationCable::Channel
  def subscribed
    poll = Poll.where(code: params[:code]).first
    stream_for poll
  end
end
```

We are taking the `code` parameter passed from the `polling.js` and streaming
for the object identified by the “code” passed in, (in this case, it is
"example"). Any time data is "broadcast" for a `Poll`, it can do so over the
`PollingChannel`.

How is data broadcast? By using the `broadcast_to` class method inherited from
`ApplicationCable::Channel`. For the purposes of our example, we can add that to
the `save` method of the `VotesController`. Here is an excerpt of the updated
logic:

```
# /app/controllers/votes_controller.rb

class VotesController < ApplicationController

…

    if @vote.save
      PollingChannel.broadcast_to(@poll, @poll.results)
      session[@poll.code] = true
      redirect_to polls_path, notice: message
    else

…
end
```

When a vote is cast, the server broadcasts the new results for the poll to the channel for that poll, which all subscribers then use to update the results view.

In our example, it “feels” like there’s a lot going on, but the majority of the work will be with the files in `/app/assets/javascripts/cable/subscription`, `/app/channels`, and wherever you need to trigger a broadcast. 

Rake and the Rails Console
-----------------------------------

Out of the box, ActionCable will not work with the Rails console (or Rake tasks) the way you might expect it to. While building Pollish and researching ActionCable, I burned a number of cycles figuring that out. I had hoped I could trigger page updates by sending `PollingChannel.broadcast_to(@poll, @poll.results)`with new data, but it wasn't to be.

By default, the development environment uses the `async` adapter, which only operates on a single process. In order to allow broadcasts from multiple sources, change the adapter to `redis` (this assumes you have redis running in your development environment) in `/config/cable.yml`:

```
development:
  adapter: redis
  url: redis://localhost:6379/1

test:
  adapter: async

production:
  adapter: redis
  url: redis://localhost:6379/1
```

Should You Use ActionCable?
-----------------------------

You know what I'm going to say here, right? 

It depends.

Whether you use ActionCable or not is dependent on your current and future
needs. ActionCable is definitely cool and we have a lot of fun playing with it,
but it's not right for every situation and we're being slow about recommending
its implementation for some of the following reasons:

#### Not every app benefits from real-time data

Is there a feature in your app which can actively benefit from being a live feed? Is it really going to make a difference to your users? As developers, we often look for excuses to play with new toys, and we've been known to justify the addition of a feature merely to experiment with those new toys. Adding ActionCable to your app is a real commitment; make sure the addition is warranted, and not just an excuse to play.

#### Every new feature is added complexity

The Rails community has been very vocal about the added complexity which comes with each new version of Rails, and 5.0 is no different. Consider the example we used in this article. There is new terminology, new classes and resources, and javascript files which have to stay in line with those new classes and resources.

Not only are there new files, naming, and resources, there's also a new server. Running ActionCable in production requires the addition of the [Redis data structure server](http://redis.io/). 

#### Not every website can afford the added strain

ActionCable requires a lot more memory and a lot more CPU power. Matthew O'Riordan, writing for the [Ably blog](https://blog.ably.io/rails-5-actioncable-the-good-and-bad-parts-1b56c3b31404#.b2wz0o11j) found in testing that "...ActionCable started over 1,690 operating system threads. In comparison, the process with next highest number of threads was the kernel itself at circa 150 threads."

Furthermore, O'Riordan [and others](https://hashrocket.com/blog/posts/websocket-shootout) found ActionCable to lag behind alternative frameworks with regard to performance. Without a lot of solid understanding about performance issues and ActionCable in general, it's likely not going to be a good fit for high traffic sites.

#### Websocket alternatives may be a better fit

Is real-time really necessary? Sometimes it is, but sometimes an occasional update is just as good. [Polling](https://en.wikipedia.org/wiki/Polling_\(computer_science\)) has been around a long time and can be just as effective as websockets in the right circumstances. It furthermore has the added advantage of not needing to recover from getting disconnected from the server; it's a brand new connection each time.

So What?
-------------

ActionCable is likely the most exciting feature to come out of Rails 5.0, and in this article we’ve looked at how it fits in to the existing Rails directory structure, but more importantly we’ve discovered the responsibilities of each of the new components and how they fit into the new architecture. 

In the same way that there is more to WebSockets than merely chat rooms, there's more to ActionCable than what we've touched on in this article. As more and more developers take advantage of this new feature, expect to see new and creative features get added to both familiar and as of yet undiscovered websites.

Even though we've been slow to recommend clients implement ActionCable in their apps, we're still excited and bullish on this new addition to Rails. This is the first release of ActionCable, and like all features, it's only going to improve. There was a time when ActiveRecord was utter rubbish with an inconsistent API and occasionally was the cause of data loss. Look at how far it's come. We expect the same kind of improvements with ActionCable. It's only going to get better.
