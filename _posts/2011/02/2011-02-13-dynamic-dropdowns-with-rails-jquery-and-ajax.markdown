--- 
title: Dynamic Dropdowns With Rails, jQuery, and AJAX
date: 2011-02-13
comments: false
post: true
categories: [ruby on rails, jquery, ajax, javascript]
---
Dynamic dropdowns and how to make them work seem to be a perpetual question with web developers. Basically, these dropdowns are "select" HTML elements which are keyed off "parent" dropdowns. In other words, based on what is selected in one select element, values in another select element are updated accordingly.

It's no surprise this problem appears to be ever present; I've never seen a really simple solution for handling it. I've dealt with it in a variety of ways before, but it wasn't until after watching [railscasts'](http://railscasts.com/) [136th episode](http://railscasts.com/episodes/136-jquery) that I settled on a means that I'm comfortable with.

In the example below, I describe what I've begun using in my own projects. For the purpose of this example, we'll use the parent dropdown, "categories", and the child dropdown, "subcategories" (ingenious, I know).

##The Form
Here's the basic code for creating the parent and child select elements in your forms.
``` ruby
<%= collection_select :widget, :category, @categories, :id, :name, :input_html => {:rel => "/categories/subcategories_by_category"} %>

<%= collection_select :widget, :subcategory, @subcategories, :id, :name %>
```
The primary thing to notice is the value for the "rel" attribute. This value represents the location the jQuery "post" method will call to retrieve the data to fill out the "subcategory" select element.

##The jQuery
In your application.js file, you'll need this bit of code:
``` javascript
jQuery.ajaxSetup({
  'beforeSend': function(xhr) { xhr.setRequestHeader("Accept", "text/javascript") }
});
```

This tells jQuery to send "text/javascript" in the request headers with every request (GET, POST, etc.). Rails will recognize this as a request for JSON and will respond accordingly.

Now we need to define a jQuery function we can call on selected elements:

``` javascript
$.fn.subSelectWithAjax = function() {
  var that = this;

  this.change(function() {
    $.post(that.attr('rel'), {id: that.val()}, null, "script");
  });
}
```

This function uses jQuery's [post](http://docs.jquery.com/Post) method to send a request to the path defined in the parent "select" element. It does this any time the select's value is "changed'. Here's a breakdown of the attributes used in the "post" call.

* that.attr('rel') - Uses the value defined by "rel" in the select to define where the post makes the call to
* {id: that.val()} - Sends the value selected in the parent dropdown with the "id' key attribute.
* null - We don't need a jQuery callback here, so we set this to null
* "script" - This tells jQuery that what is returned is a script to be executed

We can now call this function from our jQuery elements, like so:
``` javascript
$("#widget_category").subSelectWithAjax();
```

##The Controller Action
In our controller, we need to create the following action. The logic is pretty self explanatory. Notice that the "respond_to" block is calling the .js format without any parameters. We do this because we want Rails to render the "subcategories_by_category.js.erb" file (shown in the next section).

``` ruby
def subcategories_by_category
  if params[:id].present?
    @subcategories = Category.find(params[:id]).subcategories
  else
    @subcategories = []
  end

  respond_to do |format|
    format.js
  end
end
```

##The View
Finally, we create a view named "subcateogries_by_category.js.erb" under the categories directory with the following line of jQuery/ERB code:

``` javascript
$("#widget_subcategory").html('&lt;%= options_for_select(@subcategories.map {|sc| [sc.name, sc.id]}).gsub(/n/, '') %&gt;');
```

This is the javascript which will get executed by the "$.post" command above (remember the "script" parameter?), and it's what actually populates the subcategories select element. You can see we are using jQuery to grab the "widget_subcategory" elements, and then we are populating the internal the "select" element with "option values" created by Rails' "options_for_select" method. Note the call the ".gsub". Eliminating the newlines created by the "options_for_select" method is necessary to keep jQuery from choking.

## Conclusion
That's it. You should now be able to populate your "select"  boxes with relative ease from now on. There are some obvious gaps in this "tutorial" - error handling, usage of classes instead of IDs in the jQuery selectors, etc. - but I've hopefully given you enough to get going.

## Further Reading
* [Railscast Episode 136](http://railscasts.com/episodes/136-jquery)
