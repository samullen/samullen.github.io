+++
tags = ["forms","rails"]
author = "Samuel Mullen"
title = "Reduce Form Boilerplate with Rails' FormBuilder"
description = "Different frameworks impose different styles on forms, but they all end up requiring more boilerplate. You can either accept the pain boilerpating brings with it, or work around it. Creating your own FormBuilder is a simple way to do just that."
date = "2017-01-20T20:03:51-06:00"
+++

Larry Wall famously wrote, "The three chief virtues of a programmer are: Laziness, Impatience[,] and Hubris." (Editor: added Oxford comma. Come at me, bro.) These three traits are the reason you hate writing the same blocks of HTML over and over again, and the reason for your frustrations with HTML frameworks like [Bootstrap](http://getbootstrap.com). Because this is a lot of typing just to display a simple form field:

```
<div class="form-group">
  <label for="exampleInputFile">File input</label>
  <input type="file" id="exampleInputFile">
  <p class="help-block">Example block-level help text here.</p>
</div>
```

It's these three "virtues" that led developers to create [Formtastic](https://github.com/justinfrench/formtastic) and [Simple Form](https://github.com/plataformatec/simple_form), and it's these same virtues which might lead you to roll your own solution as well. If that's the direction you're headed, read on. 

Setup
-------

For the purpose of this demonstration, we'll be using Bootstrap, partly because of it's popularity and familiarity to most developers, and partly because its verbosity will highlight what we're trying to accomplish.

In the end, we want to be able to go from writing this...

```
<div class="form-group">
  <%= f.label :title, "Post Title" %>
  <%= f.text_field :title, class: "form-control", placeholder: "The title of this post" %>
</div>
```
...to writing this...

```
<%= f.text_field :title, label: "Post Title", input_options: {placeholder: "The title of this post"} %>
```

...and get the same output.

To do this, we can use Rails' `FormBuilder` class and bend it to our will.

The Class
------------

To begin, we need to create a new `FormBuilder` subclass. This class could be stored somewhere under the `/app` directory, but it makes a little more sense to keep it in the `/config/initializers` directory since we're using it to configure the display of our forms.

Create a new file in `/config/initializers` called `bootstrapped_form_builder.rb` with the following content:

``` ruby
# /config/initializers/bootstrapped_form_builder.rb

class BootstrappedFormBuilder < ActionView::Helpers::FormBuilder
end
```

With this file created, we can already start using it. We just need to define it as our form's `builder`:

```
<%# /app/views/authors/new.html.erb %>

<%= form_for @author, builder: BootstrappedFormBuilder do |f| %>
  <div class="form-group">
    <%= f.label :name %>
    <%= f.text_field :name, class: "form-control", placeholder: "Name" %>
  </div>

  <div class="form-group">
    <%= f.label :email %>
    <%= f.email_field :email, class: "form-control", placeholder: "Email address" %>
  </div>

  <div class="form-group">
    <%= f.label :bio %>
    <%= f.text_area :bio, class: "form-control", placeholder: "A little about the author" %>
  </div>

  <div class="form-group">
    <%= f.label :role %>
    <%= f.select :role, [["Writer","writer"],["Author","author"],["Commenter","commenter"]] %>
  </div>

  <div class="form-group">
    <%= f.label :active %>
    <%= f.check_box :active %>
  </div>

  <%= f.submit class: "brn btn-success" %>

<% end %>
```

When we restart the server and reload the page, we'll see that the output for our form is exactly the same as the default builder.

Text Fields
------------

Now that we've established that our new `FormBuilder` works, let's start changing things. To start, we'll override the `text_field` method. It's the most heavily used in forms and other input types such as "email", "phone", and "search" are built from it.

Looking at the Rails API, we see that `text_field` takes two arguments: `method` and `options={}`. Furthermore, the base FormBuilder class provides us with five instance variables we can use to our advantage:

* `@object_name`: The name of the object (shocking, I know). In our case it would be "Author".
* `@object`: The object provided to the `form_for` method. Ours would be `Author`.
* `@options`: The options provided to the `form_for` method.
* `@proc`: the block provided to the `form_for` method.
* `@template`: The current view. This object provides access to any method you would normally use in your view.

We want to simplify the creation of the `form-control` blocks while at the same time retaining the flexibility of being able to tweak each component in the block.

To do that, we'll override the `text_field` method:

```
def text_field(method, options={})
  label_text = options.fetch(:label, method.to_s.humanize)
  label_options = options.fetch(:label_options, {})
  input_defaults = {class: "form-control"}
  input_options = merge_options(input_defaults, options.fetch(:input_options, {}))

  @template.content_tag :div, class: "form-group" do
    @template.label(@object_name, method, label_text, label_options) +
      super(method, input_options)
  end
end
```

We want the `#label` and `#text_field` to continue accepting the same parameters as before, and in the code above we're doing that by nesting hashes specific to the label and textfield in the `options` hash (`:label`, `:label_options`, and `:input_options`). We could further add a `:wrapper_options` hash to apply to the wrapping `div`, but you get the idea.

The `input_options` variable on the fifth line is being set to the return value of a `merge_options` method. That's a private method we must use to concatenate values set in the view to default values we define for the `text_field` method:

```
private

def merge_options(defaults, new_options)
  (defaults.keys + new_options.keys).inject({}) {|h,key|
    h[key] = [defaults[key], new_options[key]].compact.join(" ")
    h
  }
end
```

In the `text_field` method, it concatenates our default CSS `class` with any new CSS classes we added in the view. 

Example:

```
<%= f.text_field :author, {input_options: {class: "emphasized"}} %>
```

...is transformed to...

```
<div class="form-group">
  <label for="author_name">Name</label>
  <input type="text" id="author_name" class="form-control emphasized" name="author[name]">
</div>
```

This is a good start. We've overridden the default Rails `text_field` to be wrapped in a Bootstrap `form-group` `div`, automatically included the `label`, and applied a default class to the input. Since so many other methods derive from `text_field`, let's look at how we can take this initial method and DRY it out.

DRYing Out
--------------

HTML5 added many new input types, all of which are merely a variation of the typical "text" field. Because of the similarity, we can create a private method to handle all the duplicate work and the call it from the methods that handle those input types.

```
private

def text_layout(method, options, defaults={})
  label_text = options.fetch(:label, method.to_s.humanize)
  label_options = options.fetch(:label_options, {})
  input_defaults = merge_options({class: "form-control"}, defaults)
  input_options = merge_options(input_defaults, options.fetch(:input_options, {}))

  @template.content_tag :div, class: "form-group" do
    @template.label(@object_name, method, label_text, label_options) +
      yield(method, input_options)
  end
end
```

As you'll notice, the `text_layout` method is exactly the same as our `text_field` method, with two exceptions 

1. It accepts a new `defaults` hash to allow element-specific attributes for our different element types.
2. It "yields" to the block passed to it instead of calling `super`.
 
Let's change our `text_field` to use this new method:

```
def text_field(method, options={})
  text_layout(method, options, {class: "text-specific-class"}) do |method, input_options|
    super method, input_options
  end
end
```

We can see that nothing changed in the way we call `text_field` – it still takes a `method` and an `options` hash. Furthermore, we're now giving all `text_field` elements a default `text-specific-class` CSS class. Lastly, it's sending the `text_layout` method a message to `super`.

We can override `email_field` just as easily:

```
def email_field(method, options={})
  text_layout(method, options) do |method, input_options|
    super method, input_options
  end
end
```

Again, there's nothing new here, just a change to the method call. We can do the same for `date_field`, `phone_field`, `url_field`, and the rest of the text-based input fields.

Select, Check Box, Radio Button, and File Fields
---------------

Selects, check boxes, radio buttons, and file fields each have a different method signature from one another and from that of text fields. Because of this, it makes more sense to define them individually than to try and shoehorn them into a generic method. The body of the method follows the pattern already laid out in the `text_field`, but the signature will need to be changed accordingly. An example of a select box is shown below:

```
def select(method, choices=nil, select_options={}, input_options={}, &block)
  label_text = options.fetch(:label, method.to_s.humanize)
  label_options = options.fetch(:label_options, {})
  input_defaults = {class: "form-control"}
  input_options = merge_options(input_defaults, options.fetch(:input_options, {}))

  @template.content_tag :div, class: "form-group" do
    @template.label(@object_name, method, label_text, label_options) +
      super(method, choices, select_options, input_options, &block)
  end
end
```

Defaulting to Your FormBuilder
--------------

As shown above, you need to pass `form_for` the builder every time you use it. If you plan to use your FormBuilder by default you have a couple of options.

### Creating a Helper Method

The first option is to create a helper method that sets some defaults and then passes those along to `form_for`. 

```
def bootstrapped_form_for(object, options={}, &block)
  defaults = {builder: BootstrappedFormBuilder}.merge(options)
  form_for object, options, &block
end
```

As you can see here, we've just copied the signature of the `form_for` method. In it, we combine our builder with the options passed in and then pass along everything else. Both [Simple Form](https://github.com/plataformatec/simple_form) and [Formtastic](https://github.com/justinfrench/formtastic) do something along these lines with their `semantic_form_for` and `simple_form_for`.

### Defaulting to Your FormBuilder

Another method is to make `form_for` use your builder by default. To do that, just add the following line to your `app/helpers/application_helper.rb` file.

```
ActionView::Base.default_form_builder = YourFormBuilder
```

Of course, by doing this you'll no longer have access to the Rails default FormBuilder. If you need that – and you probably will – just add a new builder named `RailsFormBuilder` to the initalizers like so:

```
# config/initializers/rails_form_builder.rb

class RailsFormBuilder < ActionView::Helpers::FormBuilder
end
```

Then, when you need it, you can just set it as your builder in the `form_for`:

```
<%= form_for @author, builder: RailsFormBuilder do |f| %>
<% end %>
```

You can use the super class instead of subclassing it, but I find typing `ActionView::Helpers::FormBuilder` more difficult than `RailsFormBuilder`, and also more difficult to remember.

Testing FormBuilders
-----------------------

This wouldn't be a very respectable Ruby article if it didn't cover the topic of testing (no, that's not an invitation to find all my Ruby articles which don't cover testing). Below you will find a "stub" of a test you can use for your own purposes:

```
# test/initializers/bootstrapped_form_builder_test.rb

require "test_helper"

class TestHelper < ActionView::Base; end

class BootstrappedFormBuilderTest < ActiveSupport::TestCase
  let(:builder) {
    BootstrappedFormBuilder.new(:author, Author.new, TestHelper.new, {})
  }

  describe "#text_field" do
    it "does something" do
      builder.text_field(:name).must_equal "<div class=\"form-group\"><label for=\"author_name\">Name</label><input class=\"form-control bar\" type=\"text\" name=\"author[name]\" id=\"author_name\" /></div>"
    end
  end
end
```

The meat of the example is in the defining of the `TestHelper` and the `:builder`. 'FormBuilder' requires a "template" passed to its initializer, and to do that, we provide it with a new instance of `ActionView::Base` which we've subclassed to `TestHelper`. From that point onward, it's testing as usual.

Rolling your own FormBuilder feeds into Larry Wall's three virtues marvelously: It allows us to write less code – and HTML/CSS code at that – satisfying our virtue of laziness; our impatience is satisfied by writing code we understand instead of learning yet another DSL for yet another library; and finally, our hubris is satisfied by building it "the right way".
