= Quarry Test/Specifation

== Standard Sections

Quarry sepcifications are divided up into clauses, indicated by
blank line. Clauses that are flush to the left margin are always
documentation or comment clauses. Indented clauses are always
executable code.

Each code section is executed in order of appearence, within a
rescue wrapper that captures any failures or errors. If neither
a failure or error occur the code "passes".

For example, the following passes:

  (2 + 2).assert == 4

While the following would fail, as indicated by the raising of 
an Assertion error:

  expect Assertion do
    (2 + 2).assert == 5
  end

And this would have raised a NameError:

  expect NameError do
    nobody_knows_method
  end


== Macros and Neutral Code

Excutable clauses can have differnt types. Any non-testable code,
can be designated using Macro clause, with the MACRO: indicator
on the preceeding comment. Because the context in which the code
is run is a self-extended module, reusable macros can be created
simply by defining a method.

MACRO: Macros contain code to executed but not tested.

  def assert_integer(x)
    x.assert.is_a? Integer
  end

Now lets try out our new macro definition.

  assert_integer(4)

Let's prove that it can also fail:

  expect Assertion do
    assert_integer("IV")
  end


== Before and After Macros

Quarry supports before and after clauses in a specification
through the use of BEFORE: and AFTER: indicators. Before and after
clauses are executed at the beginning and at the end of each
subsequent step.

BEFORE: We use a before clause if we want to setup some code at the
start of each step.
 
  @a = "BEFORE"

AFTER: And an after clause to teardown objects after a step.

  @z = "AFTER"

Lets verify this is the case.

  @a.should == "BEFORE"
  @z.should == nil

And now.

  @z.should == "AFTER"

There can only be one before or after clause at a time. So if
we define a new BEFORE: or AFTER: clause later in the specification,
it will replace the current clause in use.

BEFORE: As a demonstration of this:
 
  @a = "BEFORE AGAIN"

We will see it is the case.

  @a.should == "BEFORE AGAIN"

Only use before and after claues when necessary --specifications
are generally more readible without them. Indeed, some developers
make a policy of avoiding them altogether. YMMV.


== Tabular Steps

Finally we will demonstrate a tabular step. A 'TABLE:' indicator
is used for this. We also supply a file name in parenthesis telling
Quarry where to find the data table to be used in the test. All table
files are looked for in a tables/ directory along side the 
specification file. If no name is given 'default.yaml' is assumed.

The first row in a table defined the variable names to assign the values
given in the subsequent rows. Each row is assigned in turn and run
through the coded step. Consider the following example:

TABLE:(default.yaml) Every row in 'tables/default.yaml' will be assigned
to the header names as variables and run through the following assertion.

  x.upcase.assert == y

This concludes the basic specification of Quarry's specification system.
Yes, we eat our own dog food.


