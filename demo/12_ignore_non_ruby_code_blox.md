 # Ignore Non Ruby Code

Which can be indicated by a markdown \`\`\`elixir string e.g

    count = 0

Now we increment it

```elixir
    count = count + 1
```

or not?

```
    count.assert.zero?
    count += 1
```

but  

```ruby
    count += 1
```

worx

    count.assert == 2 
