# QED Demonstrandum

## Steps

QED demos are light-weight specification documents, highly suitable
to interface-driven design. The documents are divided up into
steps separated by blank lines. Steps that are flush to the 
left margin are always explanatory comments. Indented steps are
either executable code or plain text samples.

Each step is executed in order of appearance within a rescue wrapper
that captures any failures or errors. If neither a failure or error
occur then the step gets a "pass".

For example, the following passes.

    (2 + 2).assert == 4

While the following would "fail", as indicated by the raising of 
an Assertion error.

    expect Assertion do
      (2 + 2).assert == 5
    end

And this would have raised a NameError.

    expect NameError do
      nobody_knows_method
    end

## Defining Custom Assertions

The context in which the QED code is run is a self-extended module, thus
reusable macros can be created simply by defining a method.

    def assert_integer(x)
      x.assert.is_a? Integer
    end

Now lets try out our new macro definition.

    assert_integer(4)

Let's prove that it can also fail.

    expect Assertion do
      assert_integer("IV")
    end

