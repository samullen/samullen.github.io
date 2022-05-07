---
title: Just Enough Erlang
date: 2019-08-01T15:17:58-05:00
draft: false
description: "Erlang can be an intimidating language, but it doesn't have to be. This article explores the more common features with the goal of enabling you to more easily include Erlang libraries in your Elixir projects, and to read and understand the documentation."
comments: false
post: true
categories: [erlang, elixir]
---

Erlang is an intimidating language. It's functional – which is enough to make it
intimidating – terse, uses unfamiliar syntax, and just "feels" altogether alien.
Even the [Erlang website](http://erlang.org/) is intimidating. When you click
the "[Erlang Quickstart](http://erlang.org/doc/getting_started/users_guide.html)" button on
the main page you might expect an introduction to the language through a simple
"Hello, World!" tutorial. Instead, what you are given is a lengthy "guide", the
"Introduction" to which has no intention of _introducing_ you to anything other
than explaining what the guide _isn't_ going to cover. The remainder of the
guide leaves one with the sense of being thrown into the deep end of the pool,
and is written a manner as terse as the language itself.

But as the say, "Don't judge the book by the cover."

I won't make the argument that Erlang isn't intimidating. Instead, this article
will show you enough of the language to enable you to use Erlang libraries in
your Elixir projects, read and understand the documentation, and at least read
Erlang at a basic level. By the end, you'll be able to determine for yourself if
Erlang is truly as intimidating as it's been made out to be.

## The Erlang Playground

This isn't a tutorial, but you may still find it valuable to experiment with the
topics and concepts covered here. To that end, you may want to use Erlang's REPL
to test out individual commands or load and compile Erlang files. If you're
familiar with IEx, you're 80% of the way there. The only difference is the
language and some of the commands.

<img src="https://samuelmullen.com/images/just_enough_erlang/iex-v-erl.png" class="img-thumbnail img-responsive img-right" alt="IEx vs. erl" title="IEx vs. erl">

Like IEx and every other REPL, the Erlang REPL is useful for testing out short
commands, working with local files and modules, and using it as a sort of
scratch pad. And just like IEx, you can exit with `ctrl-c, ctrl-c` or `ctrl-c,
a`.

Assuming you have Elixir and/or Erlang installed, just type `erl` at the Unix
prompt.

```erlang
% Try it out:

1> io:format("Hello world~n").

2> 6 * 9 = 42.

3> reindeer_flotilla = 812.
4> ReindeerFlotilla = 812.

5> Double = fun(X) -> 2 * X end.
6> Double(8).
```

You can also "load and compile" files in the REPL with the `c/1`, just like in
IEx. Here's a simple "Hello, World!" module.

```erlang
% hello.erl

-module(hello).
-export([start/0]).

start() ->
  io:format("Hello, world!~n").
```

Now, in the REPL, load it with the `c/1` command:

```erlang
1> c("hello"). % can also use c("hello.erl").
2> hello:start().
```

Already you're seeing some peculiarities with Erlang, and now that our
playground is set up we can explore those peculiarities in more detail.

## Grammar

Learning a new programming language, much like learning a new spoken
language, not only requires learning new words, but oftentimes a whole new way
of organizing your thoughts. That's what I experienced when transitioning from
perl to Ruby and then from Ruy to Elixir (transitioning from C to perl was super
easy, however, and may say more about me than I want to admit). Programming
languages are also like spoken languages in that they echo the languages which
came before them. Elements of German, Latin, and Greek are all present in
English. Likewise, elements of Erlang are present in Elixir in their original
form, while other elements have either been modified and expanded, or are unique
to Elixir.

As we look at how Erlang implements aspects of the language pay close attention
to how it is both similar and different from Elixir. Seeing and understanding
both will help you understand the choices that were made when creating Elixir
and also understand why things are the way they are in Elixir.

<aside class="panel panel-default pull-right col-md-5">
<h3>Well, actually...</h3>

<p>Variables beginning with capital letters, periods to end statements, and semicolons to separate clauses: Where did these wacky ideas come from?</p>

<blockquote>
  <p>Mostly from Prolog. Erlang started life as a modified Prolog. "!" as the send-message operator comes from CSP. Eripascal was probably responsible for "," and ";" being separators and not terminators.</p>

  <p>--<a href="http://erlang.org/faq/academic.html">Academic and Historical Questions</a></p>
</blockquote>
</aside>

### Variables

Perhaps the first thing you will notice when looking at Erlang code is the
difference in variable naming. As has been shown in the above examples, Erlang
variable begin with a capital letter. This is very different from other
languages which reserve such naming for constants, modules, classes and the
like. To be clear, variables _must_ begin with a capital letter.

```erlang
% Try it out

1> foo = 12.
** exception error: no match of right hand side value 12
2> Foo = 12.
12
```

<div class="clearfix"></div>

Another difference between variables in Erlang and other languages is that
variables can only be assigned once.

> In Erlang, variables are just like they are in math. When you associate a
> value with a variable, you're making an assertion–a statement of fact. This
> variable has that value. And that's that.
>
> -- Joe Armstrong, _Programming Erlang_

Because variables can only be assigned once, the standard practice is to append
a number to the end of a variable to "reassign" a variable.

```erlang
% Try it out

1> TheAnswer = 42.
42
2> TheAnswer = 6 * 9.
** exception error: no match of right hand side value 54
3> TheAnswer1 = 6 * 9.
54
```

### Atoms

Unlike Elixir, atoms in Erlang aren't prepended with a `:`. Instead, Erlang
atoms are named much like you would name a variable in Elixir. So an atom must
begin with a lower case letter, can include numbers, underscores, and the `@`
character. Also, unlike Elixir, to define an atom with spaces or begin with a
capital letter, you use single quotes.

```erlang
% Try it out

1> is_atom(particle_man).
true
2> is_atom('Particle Man').
true
3> triangle_man = "Universe Man".
** exception error: no match of right hand side value "Universe Man"
4> is_atom(user@foo).
true
5> :person_man.
* 1: syntax error before: ':'
```

Like in Elixir, module names are atoms, which is why we can use Erlang modules
and functions in Elixir by prepending their names with a `:`.

{% raw %}
```elixir
iex 1 > :io.format("Hello, World!~n")
Hello, World!
:ok
iex 2 > :calendar.universal_time
{{2019, 7, 11}, {18, 25, 50}}
```
{% endraw %}

### Punctuation

After noticing the differences in capitalization with variable and atom naming,
the next thing which stands out is how terms and statements are punctuated.
Following written language, statements – as you have no doubt noticed – end
with a `.` (full stop). Functions are called through a module by use of a `:`
(ex: `io:format("Hello, World~n")`). Semicolons, rather than ending statements,
are used to separate "function definitions and in `case`, `if`, `try..catch`,
and `receive` expressions." Lastly, the `,` as expected, is used to separate
arguments and patterns.

> There's an easy way to remember this–Think of English. Full stops separate
> sentences, semicolons separate clauses, and commas separate subordinate
> clauses.
>
> -- Joe Armstrong, _Programming Erlang_

### Strings

As in Elixir, Strings in Erlang can be represented "as a list of integers or as
a binary". When represented as a binary, the traditional use of double-quotes
(`"`) is used. However, whereas Elixir uses single-quotes to represent character
lists, Erlang only offers lists of integers. As we've seen, single-quoted
strings are atoms in Erlang.

```erlang
% Try it out

1> "Foo Man was here.".
"Foo Man was here."
2> [83, 104, 97, 122, 97, 109, 33].
"Shazam!"
3> is_binary([83, 104, 97, 122, 97, 109, 33]).
false
4> is_list([83, 104, 97, 122, 97, 109, 33]).
true
```

"Strictly speaking, there are no strings in Erlang." This makes finding relevant
documentation for your tasks...challenging.

### Comments

Another difference between Erlang and Elixir – and just about every other
language – are the comments. Erlang uses the `%` character the same way Elixir
uses `#`. Everything after the `%` is commented out.

In some ways this makes sense. The percent sign isn't used for anything other
than showing a percentage which is done so in a string. Also, Erlang uses the
`#` character for use with records and maps. While other languages use `%`
as the modulo operation, Erlang uses the named operator `rem`.

```erlang
% Try it out

1> 'not a comment' % is a comment
1> .
'not a comment'
2> 5 rem 2.
1
3> 5 % 2
3> .
5
```

### Operators

Since we've stumbled into the arena of math operators in our discussion about
comments, it makes sense to look more closely at them and other operators as
well. Erlang does things differently in about every case. Rather than discuss
each operator – which you already understand – I'll list the operator used in
Elixir, Erlang, and the description.

#### Math Operators

<table class="table table-striped table-sm">
  <tr>
    <th>Elixir</th>
    <th>Erlang</th>
    <th>Description</th>
  </tr>

  <tr>
    <td>+</td>
    <td>+</td>
    <td>Addition</td>
  </tr>
  <tr>
    <td>-</td>
    <td>-</td>
    <td>Subtraction</td>
  </tr>
  <tr>
    <td>*</td>
    <td>*</td>
    <td>Multiplication</td>
  </tr>
  <tr>
    <td>/</td>
    <td>/</td>
    <td>Floating point division</td>
  </tr>
  <tr>
    <td>div</td>
    <td>div</td>
    <td>Integer division</td>
  </tr>
  <tr>
    <td>rem</td>
    <td>rem</td>
    <td>Integer remainder</td>
  </tr>
</table>

#### Logical Operators

<table class="table table-striped table-sm">
  <tr>
    <th>Elixir</th>
    <th>Erlang</th>
    <th>Description</th>
  </tr>

  <tr>
    <td><code>not</code></td>
    <td><code>not</code></td>
    <td>NOT</td>
  </tr>
  <tr>
    <td><code>and</code></td>
    <td><code>and</code></td>
    <td>AND</td>
  </tr>
  <tr>
    <td><code>or</code></td>
    <td><code>or</code></td>
    <td>OR</td>
  </tr>
  <tr>
    <td>N/A</td>
    <td>xor</td>
    <td>XOR</td>
  </tr>
</table>

#### Bitwise Operators

<table class="table table-striped table-sm">
  <tr>
    <th>Elixir</th>
    <th>Erlang</th>
    <th>Description</th>
  </tr>

  <tr>
    <td><code>bnot</code> or <code>~~~</code></td>
    <td>bnot</td>
    <td>NOT</td>
  </tr>
  <tr>
    <td><code>band</code> or <code>&&&</code></td>
    <td><code>band</code></td>
    <td>AND</td>
  </tr>
  <tr>
    <td><code>bor</code> or <code>|||</code></td>
    <td><code>bor</code></td>
    <td>OR</td>
  </tr>
  <tr>
    <td><code>bxor</code> or <code>^^^</code></td>
    <td><code>bxor</code></td>
    <td>XOR</td>
  </tr>
  <tr>
    <td><code>bsl</code> or <code>&lt;&lt;&lt;</code></td>
    <td><code>bsl</code></td>
    <td>Left shift</td>
  </tr>
  <tr>
    <td><code>bsr</code> or <code>&gt;&gt;&gt;</code></td>
    <td><code>bsr</code></td>
    <td>Left shift</td>
  </tr>
</table>

**Note:** To use bitwise operators in Elixir, you must `require` or `use` the
`Bitwise` module.

#### Comparison Operators

<table class="table table-striped table-sm">
  <tr>
    <th>Elixir</th>
    <th>Erlang</th>
    <th>Description</th>
  </tr>

  <tr>
    <td>==</td>
    <td>==</td>
    <td>Equal to</td>
  </tr>
  <tr>
    <td>!=</td>
    <td>\=</td>
    <td>Not equal to</td>
  </tr>
  <tr>
    <td>&lt;=</td>
    <td>=&lt;</td>
    <td>Less than or equal to</td>
  </tr>
  <tr>
    <td>&lt</td>
    <td>&lt</td>
    <td>Less than</td>
  </tr>
  <tr>
    <td>&gt;</td>
    <td>&gt;=</td>
    <td>Greater than or equal to</td>
  </tr>
  <tr>
    <td>&gt;</td>
    <td>&gt;</td>
    <td>Greater than</td>
  </tr>
  <tr>
    <td>===</td>
    <td>=:=</td>
    <td>Exactly equal to</td>
  </tr>
  <tr>
    <td>!==</td>
    <td>=/=</td>
    <td>Exactly not equal to</td>
  </tr>
</table>

**Note:** Pay close attention to the "less than or equal to" operator

### Anonymous Functions

The difference between anonymous functions in Erlang (called "funs") and Elixir
is all of two characters: "u" and ";". Where Elixir uses the `fn` keyword,
Erlang uses `fun`. In Erlang, function bodies are separated with a `;`, but in
Elixir, there's no need.

```elixir
# Try it out in Elixir

x = fn
{:ok, _file} -> IO.puts "opened the file"
{_, _error} -> IO.puts "unable to open the file"
end
#Function<6.99386804/1 in :erl_eval.expr/5>
```

```erlang
% Try it out in Erlang

X = fun
({ok, _file}) -> io:format("opened the file~n");
({_, _error}) -> io:format("unable to open the file~n")
end
#Fun<erl_eval.6.99386804>
```

As you can see, there is virtually no difference between Erlang and Elixir when
defining anonymous functions. I should mention one more thing. In Elixir, when
you assign an anonymous function to a variable, you must separate the variable
from the parentheses with a `.`. This isn't necessary in Erlang.

```erlang
% Try it out

1> X = fun(Y) -> 2 * Y end.
#Fun<erl_eval.6.99386804>
2> X(4).
8
```

### Modules

As you work with Erlang libraries in your Elixir applications, you'll rarely run
across documentation requiring you to understand module syntax. However, in the
event that you do, you'll want to be mindful of the differences.

The first difference you'll note is the module declaration. In Elixir this is
performed with the `defmodule` block. In Erlang, however, a module is declared
with the "module attribute" (`-module(module_name).`) and must be named the
"same as the filename minus the extension `.erl`."

Another difference between Erlang and Elixir modules is the treatment and syntax
of functions. By default, _all_ functions within an Erlang module are private
and must be "exported" in order to use them outside the module. Functions also
differ in their syntax as they more closely follow the syntax of "funs" (i.e.
anonymous functions). The difference here being that whereas a single "fun" can
have multiple bodies, a module function must be re-declared with each new body.

```elixir
# Try it out
# fact.ex

defmodule Fact do
  def fact(0), do: 1
  def fact(n), do: n * fact(n-1)
end
```

```erlang
% Try it out
% fact.erl

-module(fact).
-export([fact/1]).

fact(0) -> 1;
fact(N) -> N * fact(N-1).
```

### List Comprehensions

List comprehensions are an underutilized feature of Elixir. In a single line,
you can combine multiple collections, `filter`, `map`, and return a unique set
into a new collection. What you can't do is make all of that terribly readable.
Given their obfuscated nature and just how comprehensive the `Enum` module is,
perhaps it should come as no surprise they're underutilized. Still, consider
this example from the [Plug library](https://github.com/elixir-plug/plug):

```elixir
# List comprehension

defmodule Plug.Conn do
  ...
  def get_resp_header(%Conn{resp_headers: headers}, key) when is_binary(key) do
    for {^key, value} <- headers, do: value
  end
  ...
end

# Example usage:

Plug.Conn.get_resp_header(conn, "Set-Cookie") # returns list of cookies
```

Here, in a single line we are able to both match and filter given a key, and
it's accomplished in a single line. Now, consider what this would look like with
the `Enum` module:

```elixir
# Enum
defmodule Plug.Conn do
  ...
  def get_resp_header(%Conn{resp_headers: headers}, key) when is_binary(key) do
    headers
    |> Enum.filter(fn {k,v} -> k == key end)
    |> Enum.map(fn {_, value} -> value end)
  end
  ...
end
```

To make comprehensions more confusing, you can use multiple "generators" (the
`value <- list` portion) to create a [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product).

```elixir
# Try it out

1> letters = ~w[a b c d e f g h]
2> numbers = [1, 2, 3, 4, 5, 6, 7, 8]

3> chessboard = for l <- letters, n <- numbers, do: "#{l}#{n}"
```

Of course, things are a little different with Erlang. In Elixir, comprehensions
are shaped like functions: function name (i.e. `for`), arguments (i.e.
generators), result block. In Erlang, however, they're shaped like lists with
the result block first and _then_ the generators. Personally, I prefer Erlang's
shape more.

```erlang
% Try it out

1> Headers = [
1> {"Set-Cookie", "Cookie1"},
1> {"Set-Cookie", "Cookie2"},
1> {"Content-Length", 2112}
1> ].
2> [Value || {"Set-Cookie", Value} <- Headers].

3> Letters = ["a", "b", "c", "d", "e", "f", "g", "h"].
4> Numbers = [1, 2, 3, 4, 5, 6, 7, 8].
5> Chessboard = [ lists:concat([L, N])  || L <- Letters, N <- Numbers].
```

### Processes

`spawn`, `receive`, `monitor`, even Erlang's `gen_server` module: for the most
part, there is little difference between Erlang's process functions and those in
Elixir. The one exception to this is Erlang's send operator: `!`.

The `!` operator is no different than Erlang's `erlang:send/2` function. Both
send a message to the destination `pid`. Nevertheless, `erlang:send/2` isn't
referenced in _Programming Erlang_, _Learn You Some Erlang_, or in numerous
articles I've run across. I have to conclude that `!` is the preferred method
for message passing.

```erlang
% Try it out

% summer.erl

-module(summer).
-export([loop/0]).

loop() ->
  receive
    [X, Y] ->
      io:format("~B + ~B = ~B~n", [X, Y, X+Y]),
      loop()
  end.

% In the Erlang REPL

1> c(summer).
{ok,summer}

2> Pid = spawn(summer, loop, []).
<0.66.0>

3> Pid ! [8, 11].
8 + 11 = 19
[\b\v]

4> erlang:send(Pid, [8, 11]).
8 + 11 = 19
[\b\v]
```

### Odds 'n Ends

Not every difference between Elixir and Erlang relates to grammar and syntax,
some differences are in naming and conventions. An example of this is the
acronym "MFA". MFA stands for "Module, Function, Argument". Although this
acronym occasionally appears in the [Elixir Forum](https://elixirforum.com/) and
other discussion areas, it's not as common as within the Erlang community.

Another acronym you are likely to see is "BIF". BIFs are "built-in functions"
and "are defined as part of the Erlang language", (i.e. functions within the
`erlang` module). "[T]he most common BIFs...are autoimported", while those which
are not – such as `erlang:send/2` mentioned in the Process section – must be
called with the `erlang` module.

If you are coming to Erlang from Elixir it may come as a surprise to you that
Erlang has no concept of Pipelines. Because of this, many Erlang developers,
such as Brujo Benavides as discussed in
[ElixirMix Ep.  60](https://devchat.tv/elixir-mix/emx-060-property-based-testing-dialyzer-inaka-with-brujo-benavides/),
find themselves adding pipelines to their Elixir code only after writing the
initial implementation.

Perhaps this difficulty with pipelines stems from another "oddity" of Erlang.
As you read the documentation, you will find the convention is to pass
functional predicates as the first argument rather than the last as in Elixir.
For those of us coming from Elixir or Ruby, passing a function as the first
argument seems completely foreign.

## Documentation

Documentation is a difficult problem. It's not just a problem of explaining
how something works – which is difficult in its own right – but answering "who
is the audience?", "how should it be organized?", and "what and how much
information should be shared?" Every language, framework, and technology answers
these questions even if it's not a conscious decision on the documenter's part.

Like the language itself, Erlang's documentation is terse and expects a certain
level of competency on the part of the developer. For example, this is the
Erlang documentation for `lists:all/2`:

> Returns `true` if `Pred(Elem)` returns `true` for all elements `Elem` in `List`, otherwise `false`.

Contrast this with Elixir's documentation:

> Returns true if fun.(element) is truthy for all elements in enumerable.
>
> Iterates over the enumerable and invokes fun on each element. When an invocation of fun returns a falsy value (false or nil) iteration stops immediately and false is returned. In all other cases true is returned.
>
> **Examples**

```
iex> Enum.all?([2, 4, 6], fn x -> rem(x, 2) == 0 end)
true

iex> Enum.all?([2, 3, 4], fn x -> rem(x, 2) == 0 end)
false

iex> Enum.all?([], fn x -> x > 0 end)
true
```

> If no function is given, the truthiness of each element is checked during iteration. When an element has a falsy value (false or nil) iteration stops immediately and false is returned. In all other cases true is returned.

```
iex> Enum.all?([1, 2, 3])
true

iex> Enum.all?([1, nil, 3])
false

iex> Enum.all?([])
true
```

To be clear, I am not saying Erlang's documentation is bad or even incomplete.
It's not. It is, however, different from what many in the Elixir community are
used to.

### Finding Documentation

Finding the correct Erlang documentation isn't straightforward. From what I can
tell, there are two reasons for this. The first reason is that unlike many
languages, Erlang grew out of Prolog rather than C and inherited its library
organization from there. The second reason is based on how Erlang handles
modules. As we've already seen, Erlang modules must be named the same as the
file in which they reside. Because of this, Erlang doesn't have the idea of
namespacing, resulting in all of erlang's modules organized in a single space
and without a level of importance.

If you're looking for a specific function to perform a task, look first for a
module that covers the topic – If you're dealing with a list, look in the
`lists` module. From there, scan the available functions and see what most
closely matches what you're looking for. Keep an open mind, just because the
function doesn't look like it would make sense, it just might be what you need:
example: `integer_to_list/1` converts integers to strings (remember, strings are
handled as lists in Erlang). Also, remember that many functions developers are
most likely to need are stored as BIFs in the `erlang` module.

If you still can't find what you're looking for, the Internet is your best
choice. Better yet, the chat room of your local Elixir/Erlang group.

### Reading the Documentation

> Good books are over your head; they would not be good for you if they were not.
>
> ― Mortimer J. Adler, _How to Read a Book_

Once you've found the documentation you're looking for, the next obstacle is
getting something useful out of it. Generally speaking, all Erlang documentation
follows the same basic pattern:

**module\_name**
**Module**
- module name (yes, it's redundant)

**Module Summary**
- One sentence summary of the module

**Description**
- Comprehensive description of a module and its uses

**Exports**
- function definition
- function definition
- ...
- function definition

There is some amount of ceremony in Erlang documentation. For example, listing
the module name twice and providing a summary along with the full description
is redundant. Aside from that, the only thing to be mindful of at this top level
is the use of "Exports" instead of "Functions". This goes back to the way Erlang
handles functions inside modules: they're private unless exported, hence the
section name, "Exports".

When we zoom in on the documentation for a particular function, however, things
get more complicated. Let's look at `lists.all/2`:

```
all(Pred, List) -> boolean()

  Types

    Pred = fun((Elem :: T) -> boolean())
    List = [T]
    T = term()

  Returns true if Pred(Elem) returns true for all elements Elem in List, otherwise false.
```

In the first line we see two things: 1) the function definition `all(Pred, List)`; 2) the return value, `boolean()`, shown by the arrow (`->`).

The next section lists the "Types" involved in the function, and goes into some
detail. In the example we see `Pred` used for a "functional predicate". In this
case the function must return a boolean (true/false) value. Also note that
although `T` is not used in the function definition, it is used when defining
both `Pred` and `List`, and therefore receives its own definition under "Types".

Lastly we have the description of what the function does and how to use it.
What's interesting to note here is what is left out: example usage. As I've
skimmed the Erlang documentation I've noted that less than 50% of the modules
and functions provide example usage.

## Including Erlang in your Projects

This may come as a surprise, but you can easily include Erlang files in your
Elixir projects. It makes sense. Afterall, if you can include Erlang libraries
as dependencies, why wouldn't you be able to include them as part of your
project.

To do this, create a `src` directory at the root level of your Elixir project.
From here you can drop in Erlang files and they'll be available to your project.
You can even organize the files by nesting directories within the `src`
directory.

```erlang
% Try it out

% hello.erl
-module(hello).
-export([start/0]).

start() ->
  io:format("Hello, world!~n").
```

Add the module above to your project by following these steps:

```shell
$ mkdir src
$ cp path/to/hello.erl src
$ iex -S mix

# IEx starts

1> :hello.start()
Hello, world!
:ok
```

Of course you don't have to store the Erlang files under `src`, you can change
it. To do so, just add that configuration to the `project/0` function of your
`mix.exs` file:

```elixir
def project do
  ...
  erlc_paths: ["lib"],
  ...
end
```

With this in place, you can now freely mix Erlang and Elixir files under the
same directory structure in your project. By the way, don't do this.

Erlang is thought by many to be an intimidating language, but is it? Certainly
its syntax and grammar are different, having been heavily influenced by Prolog,
but as we've seen it's only slightly different from Elixir's syntax which many
regard to be simple and expressive. Are the two so different?

True, the language is more terse than Elixir, but only just so. In many ways
the two languages are nearly identical. If there is any glaring difference, it's
to be found in the documentation. Whereas Elixir bends over backwards to give
developers the information they need to be productive, Erlang provides them with
just enough and expects them to make up the difference.

There's an old UNIX joke that says, "UNIX is user-friendly; it's just picky
about its friends." I think the same can be said of Erlang. Is Erlang an
intimidating language? It is to those who merely glance at it. However, to those
willing to put in a little more effort, it readily offers up its wealth and
power.

Many thanks to [Amos King](https://binarynoggin.com/) and [Sean Cribbs](https://seancribbs.com/) for proof reading and providing necessary corrections.
