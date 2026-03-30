# Fenced Code Blocks

QED supports fenced code blocks using triple backticks in addition
to the traditional indented code blocks.

## Bare fenced blocks

A bare fenced block (no language tag) is treated as Ruby.

```
x = 1 + 1
x.assert == 2
```

## Ruby-tagged fenced blocks

A block explicitly tagged as `ruby` is also executed.

```ruby
y = "hello"
y.assert == "hello"
```

## Foreign language blocks are skipped

Code blocks tagged with any language other than Ruby are ignored.
This is useful for documentation that includes examples in other
languages.

```elixir
# This Elixir code is NOT executed.
# If it were, QED would raise an error.
IO.puts "hello from elixir"
```

```javascript
// This JavaScript is also skipped.
console.log("hello from js");
```

We can verify that Ruby execution continues normally after
skipping foreign blocks.

    z = 42
    z.assert == 42

## Mixed usage

Traditional indented blocks and fenced blocks can be used
together in the same document.

    a = 10

```ruby
b = 20
```

And the results carry across.

    (a + b).assert == 30
