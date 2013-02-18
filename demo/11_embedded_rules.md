# Meta Code

All code steps are evaluated in a rescue clause. If an error occurs, it
is captured and reported through the test report, and execution continues.
However, sometimes this is not desired. To evaluate a step without the 
rescue clause, and effective *fail fast*, append `^` mark to the end of
the desription text, like so. ^

    When 'this is cool' do |text|
      @text = text
    end

Now, let's try it by saying, "this is cool":

    And this is the text.

Did it work?

    @text.assert == "And this is the text."


## Match Separator

The `When` method can take a list of String or Regexp as arguments.
If any of the strings contain `...`, the string will be split into
two at this point, which effective means that any text can occur
within this space. It behaves much like adding `((*.?))`, but parses
more quickly by dividing the string into multiple matches.

    When 'Let /(\w+)/ be ... scared of /(\w+)/' do |name, monster|
      @name    = name
      @monster = monster
    end

Okay let's try it: Let John be very scared of Zombies.

So now what is the name?

    @name.assert == "John"

What is the monster?

    @monster.assert == "Zombies"

Did it work?

