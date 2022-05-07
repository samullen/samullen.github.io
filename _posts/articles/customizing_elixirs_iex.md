---
title: Customizing Elixir's IEx
description: "Out of the box, Elixir's REPL IEx is incredibly powerful. With a little modification, you can make it event better."
date: "2017-10-30T14:55:16-06:00"
comments: false
post: true
categories: [elixir]
---

Most modern programming languages come with a REPL (Read Evaluate Print Loop)tool to allow you to interact with the language experientially. Ruby has IRB, JavaScript has Node.js' tool, Swift has both a REPL and a Playground, and, of course, Elixir has IEx.

If you've not taken advantage of IEx or other similar tool, you owe it to yourself to give it a try. Once you get used to the convenience of a REPL, switching to language that lacks such a tool feels like stepping back in time.

IEx allows you to "play" with the Elixir language — its modules, functions, libraries, and syntax — experimenting to discover what you can and can't do in the language. But as with any programming tool, after you've used it long enough you'll begin to notice features and configurations that are either missing or not what you'd prefer.

In IEx, fine-tuning your environment begins in the `.iex.exs` file.

## .iex.exs

As you may have gathered from the filename, `.iex.exs` is just an Elixir file. This means that configuring your IEx environment is only limited by what you can do in Elixir, which is to say, not much. When your `.iex.exs` file is loaded, you'll have access to any variables, functions, modules, and aliases you've defined therein.

When launching, IEx first searches for an `.iex.exs` file in the current working directory. If IEx is unable to find one, it then looks in your home directory. Once an `.iex.exs` file is found, it "is evaluated in the shell’s context. So, for instance, any modules that are loaded or variables that are bound in the `.iex.exs` file will be available in the shell after it has booted."

Taking advantage of this process, library authors can include an `.iex.exs` file in the root of their projects to simplify working with the library in IEx. By adding the following line to a project's `.iex.exs` file, you combine both the project's and the developer's configurations.

```
File.exists?(Path.expand("~/.iex.exs")) && import_file("~/.iex.exs")
```

Since we're on the subject, let's look at some of the configurations.

## Configuration

IEx comes with some simple configurations out of the box: a basic prompt, default colors, and a small command history. But you don't have to settle for the defaults. After all, we're not savages.

To see what your current configuration is, type `IEx.configuration` at the prompt and hit return.

```elixir
iex(3)> IEx.configuration
[inspect: [pretty: true], history_size: 20,
 alive_prompt: "%prefix(%node)%counter>", colors: [],
 default_prompt: "%prefix(%counter)>"]
```

To get a (mostly) complete view of what can be configured, you can type
`h IEx.configure/1` at the IEx prompt, or visit the [IEx.configure/1 web page](https://hexdocs.pm/iex/IEx.html#configure/1).

### History Size

You can see the previous expressions you typed at the prompt by using the "up" and "down" arrow keys on your keyboard. By default, IEx keeps a history of your 20 previous "expressions" entered at the prompt. If you need more you can change it to what you think is reasonable. Alternatively, you can give it a negative number to keep an infinite number of expressions.

```elixir
IEx.configure(history_size: 50)
```

### Width

"Width" sets "the maximum number of columns to use in output." I'm only adding this for the sake of completeness, but you don't need to change it: it's correctly defaulted to 80.

```elixir
IEx.configure(width: 80)
```

### Inspect

The `:inspect` configuration gives you control over how IEx presents the output
of the last evaluation. There are a lot of [configurations for inspect](https://hexdocs.pm/elixir/Inspect.Opts.html), and at the very least you'll want to turn on `:pretty` and set a reasonable value for `:limit` (the max number of items to display).

```elixir
IEx.configure([pretty: true, limit: :infinity])
```

### Colors

What would configuring your command-line be without colors? It would be
horrible. I know. I was there. And don't get me started on the one level of undo
that VI had.

Like most of the other configurations, colors define how the evaluated output
appears. Colors can be set for syntax, directory listings, documentation,
error/warning output, and more. Colors are defined in the [IO.ANSI documentation](https://hexdocs.pm/elixir/IO.ANSI.html), but can be boiled down to the following: `:black`, `:blue`, `:cyan`, `:green`, `:magenta`, `:red`, `:white`, `:yellow`, and `:light_` variations of each of them.

**Note:** `:light_black` is dark grey, `:white` is light grey, and `:light_white` is actually white.

You can set colors as either an atom or a list of atoms. When using a list, you can include a color and modifiers such as `:underline`, `:bright` (i.e. bold), and others.

```elixir
IEx.configure(
  colors: [
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :light_black,
      boolean: :red,
      nil: [:magenta, :bright],
    ],
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline],
  ],
)
```

### Prompt

The last configuration we'll cover is the IEx prompt. There are, in fact, two prompts: `:default_prompt` and `:alive_prompt`. The latter is used when `Node.alive?` returns `true`.

The configuration for each of the two prompts is just a string, so you can use interpolation, include `IO.ANSI` colors and function outputs, and concatenation to define your perfect prompt. You can also use three "key words" provided by IEx that get replaced with what they represent:

- `%counter`: a number representing the number of evaluations performed
- `%prefix`: a name provided by `IEx.Server`
- `%node`: "the name of the local node." (You'll only use this in the `:alive_prompt`.)

**ProTip:** Don't add a newline character (`\n`) to your prompt configuration. It'll make multiline commands look weird, and has some other minor side effects as well.

```elixir
IEx.configure(
  default_prompt:
    "#{IO.ANSI.green}%prefix#{IO.ANSI.reset} " <>
    "[#{IO.ANSI.magenta}#{timestamp.()}#{IO.ANSI.reset} " <>
    ":: #{IO.ANSI.cyan}%counter#{IO.ANSI.reset}] >"
)

...

iex [08:47 :: 5] > dwarves
["Fili", "Kili", "Oin", "Gloin", "Thorin", "Dwalin", "Balin", "Bifur", "Bofur",
 "Bombur", "Dori", "Nori", "Ori"]
iex [08:47 :: 6] > Enum.map(1..100, &(&1))
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,
 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62,
 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82,
 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100]
iex [08:48 :: 7] >

```
## Quality of Life

Configuring your IEx experience isn't limited to merely beautifying the output; it can also be used to import and alias modules, set frequently used variables, and define helper functions.

In a Phoenix project, for example, you might consider importing `Ecto.Query` and aliasing your project's `Repo`, models, and any other modules you regularly interact with:

```elixir
File.exists?(Path.expand("~/.iex.exs")) && import_file("~/.iex.exs")

import Ecto.Query

alias Project.Repo

alias Project.User
alias Project.Post
```

Other things to consider adding to your `.iex.exs` file:

- Variables with dummy data

```elixir
dwarves = ["Fili","Kili", "Oin", "Gloin", "Thorin", "Dwalin", "Balin", "Bifur",
           "Bofur", "Bombur", "Dori", "Nori", "Ori"]
```

- Quality of life functions

```elixir
timestamp = fn -> # for use in your prompt
  {_date, {hour, minute, _second}} = :calendar.local_time
  [hour, minute]
  |> Enum.map(&(String.pad_leading(Integer.to_string(&1), 2, "0")))
  |> Enum.join(":")
end
```

It's probably best not to include 3rd party modules in your `.iex.exs` file, especially if you use the same file across multiple machines.

## Ctrl-C, Ctrl-C

REPLs add a great deal to the enjoyment of modern languages such as Elixir. They not only provide us with a sandbox to experiment and play with the language, but also a means to discover and inspect new features, and even access documentation for our discoveries.

But what fun is a sandbox without the ability to make it your own and bring your own toys?

`IEx` allows us to do just that. By creating your own `.iex.exs` file, you can define exactly what your sandbox looks like and what toys are available to play with. As with a real sandbox, what you create is only limited by your imagination.

My `.iex.exs` as of this writing:

```elixir
timestamp = fn ->
  {_date, {hour, minute, _second}} = :calendar.local_time
  [hour, minute]
  |> Enum.map(&(String.pad_leading(Integer.to_string(&1), 2, "0")))
  |> Enum.join(":")
end

IEx.configure(
  colors: [
    syntax_colors: [
      number: :light_yellow,
      atom: :light_cyan,
      string: :light_black,
      boolean: :red,
      nil: [:magenta, :bright],
    ],
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline],
  ],
  default_prompt:
    "#{IO.ANSI.green}%prefix#{IO.ANSI.reset} " <>
    "[#{IO.ANSI.magenta}#{timestamp.()}#{IO.ANSI.reset} " <>
    ":: #{IO.ANSI.cyan}%counter#{IO.ANSI.reset}] >",
  alive_prompt:
    "#{IO.ANSI.green}%prefix#{IO.ANSI.reset} " <>
    "(#{IO.ANSI.yellow}%node#{IO.ANSI.reset}) " <>
    "[#{IO.ANSI.magenta}#{timestamp.()}#{IO.ANSI.reset} " <>
    ":: #{IO.ANSI.cyan}%counter#{IO.ANSI.reset}] >",
  history_size: 50,
  inspect: [
    pretty: true,
    limit: :infinity,
    width: 80
  ],
  width: 80
)

dwarves = ["Fili","Kili", "Oin", "Gloin", "Thorin", "Dwalin", "Balin", "Bifur",
           "Bofur", "Bombur", "Dori", "Nori", "Ori"]
fellowship = %{
  hobbits: ["Frodo", "Samwise", "Merry", "Pippin"],
  humans: ["Aragorn", "Boromir"],
  dwarves: ["Gimli"],
  elves: ["Legolas"],
  wizards: ["Gandolf"]
}
```
