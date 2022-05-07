--- 
title: "Use Capybara::add_selector to Simplify Finding Links"
date: 2011-12-26
comments: false
post: true
categories: [TDD, Capybara]
---
In a [recent post](http://blog.steveklabnik.com/posts/2011-12-20-write-better-cukes-with-the-rel-attribute), Steve Klabnik argued that when writing Cucumber steps, we should base our selectors on the "rel" attribute of a link rather than using the traditional selectors (:id, :class, text, etc.). He argues that IDs shouldn't be used because they are unique and don't provide a general enough solution, and class attributes have everything to do with styles and nothing to do with semantics and data. His solution, as I've already mentioned, is to use an anchor tag's "rel" attribute.

At the time of his writing, I also happened across [Capybara's "add_selector" method](https://github.com/jnicklas/capybara/blob/master/lib/capybara.rb#L72-110) and was looking for an opportunity to use it. Steve's article made for a perfect opportunity.

If you don't already know, "::add_selector" "[Add's] a new selector to Capybara" (shocking, I know). By using this method, you can simplify the way you find elements. So rather than using this:
``` ruby
num = 3

page.find(:xpath, ".//table/tr[#{num}]")
```

You might use something like  this:

``` ruby
page.find(:table_row, num)
```
Back to Klabnik's post. Like I said, Steve thinks we should be looking for links based on their "rel" attribute. To do this in Capybara we normally have to do something like this:

``` ruby
find("//a[@rel='edit-article']").click
```

But rather than using this bit of xpath nastiness, let's use Capybara's "::add_selector" method.

I've created a "selectors.rb" file in my "Rails.root/features/support" directory and added the following finder:

``` ruby
Capybara.add_selector(:link) do
  xpath {|rel| ".//a[@rel='#{rel}']"}
end
```
Now, I can use this in my steps:

``` ruby
find(:link, "edit-article")
```

Not only is this easier to remember, but it reads better too.
### Further Reading:
<ul>
	<li>Steve Klabnik - Write Better Cukes With the Rel Attribute: <a href="http://blog.steveklabnik.com/posts/2011-12-20-write-better-cukes-with-the-rel-attribute">http://blog.steveklabnik.com/posts/2011-12-20-write-better-cukes-with-the-rel-attribute</a></li>
	<li>Capybara.add_selector: <a href="https://github.com/jnicklas/capybara/blob/master/lib/capybara.rb#L72-110">https://github.com/jnicklas/capybara/blob/master/lib/capybara.rb#L72-110</a></li>
	<li>Improving your tests with Capybara custom selectors: <a href="http://blog.plataformatec.com.br/2011/02/improving-your-tests-with-capybara-custom-selectors/">http://blog.plataformatec.com.br/2011/02/improving-your-tests-with-capybara-custom-selectors/</a></li>
	<li>The Gist of my code: <a href="https://gist.github.com/1521583">https://gist.github.com/1521583</a></li>
</ul>
