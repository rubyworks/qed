# Advice

Advice are event-based procedures that augment demonstrations.
They are used to keep demonstrations clean of extraneous,
repetitive and merely adminstrative code that the reader does
not need to see over and over.

Typically you will want to put advice definitions in applique
files, rather then place them directly in the demonstration
document, but you can do so, as you will see in this document.

## Before and After

QED supports *before* and *after* clauses in a specification
through the use of Before and After code blocks. These blocks
are executed at the beginning and at the end of each indicated
step.

We use a *before* clause if we want to setup some code at the
start of each code step.

    a, z = nil, nil

    Before do
      a = "BEFORE"
    end

And an *after* clause to teardown objects after a code step.

    After do
      z = "AFTER"
    end

Notice we assigned +a+ and +z+ before the block. This was to ensure
their visibility in the scope later. Now, lets verify that the *before*
and *after* clauses work.

    a.assert == "BEFORE"

    a = "A"
    z = "Z"

And now.

    z.assert == "AFTER"

There can be more than one before and after clause at a time. If we
define a new *before* or *after* clause later in the document,
it will be appended to the current list of clauses in use.

As a demonstration of this,

    b = nil

    Before do
      b = "BEFORE AGAIN"
    end

We will see it is the case.

    b.assert == "BEFORE AGAIN"

Only use *before* and *after* clauses when necessary --specifications
are generally more readable without them. Indeed, some developers
make a policy of avoiding them altogether. YMMV.

## Caveats of Before and After

Instead of using Before and After clauses, it is wiser to
define a reusable setup method. For example, in the helper
if we define a method such as #prepare_example.

    def prepare_example
      "Hello, World!"
    end

Then we can reuse it in later code blocks.

    example = prepare_example
    example.assert == "Hello, World!"

The advantage to this is that it gives the reader an indication
of what is going on behind the scenes, rather the having
an object just magically appear.

## Event Targets

There is a small set of advice targets that do not come before or after,
rather they occur *upon* a particular event. These include +:pass+, +:fail+
and +:error+ for when a code block passes, fails or raises an error; and
+:step+, +:applique+, +:match+ and +:test:+ which targets the processing 
of a demo step and it's example excecution.

These event targets can be advised by calling the +When+ method
with the target type as an argument along with the code block
to be run when the event is triggered.

    x = []

    When(:step) do |section|
      section.text.scan(/^\*(.*?)$/) do |m|
        x << $1.strip
      end
    end

Now let's see if it worked.

* SampleA
* SampleB
* SampleC

So +x+ should now contain these three list samples.

    x.assert == [ 'SampleA', 'SampleB', 'SampleC' ]

## Pattern Matchers

QED also supports comment match triggers. With the +When+ method one can
define procedures to run when a given pattern matches comment text.

    When 'given the facts' do
      @facts = "this is truth"
    end

Then whenever the words, 'given the facts' appear in step description
the `@facts` varaible will be set.

    @facts.assert == "this is truth"

Pattern matchers reall shine when we also add captures to the mix.

    When 'given a setting @a equal to (((\d+)))' do |n|
      @a = n.to_i
    end

Now, @a will be set to 1 whenever a comment like this one contains,
"given a setting @a equal to 1".

    @a.assert == 1

A string pattern is translated into a regular expression. In fact, you can
use a regular expression if you need more control over the match. When
using a string all spaces are converted to <tt>\s+</tt> and anything within
double-parenthesis is treated as raw regular expression. Since the above
example has (((\d+))), the actual regular expression contains <tt>(\d+)</tt>,
so any number can be used. For example, "given a setting @a equal to 2".

    @a.assert == 2

When clauses can also use consecutive pattern matching. For instance
we could write,

    When 'first match #(((\d+)))', 'then match #(((\d+)))' do |i1, i2|
      @a = [i1.to_i, i2.to_i]
    end

So that 'first match #1' will be looked for first, and only after
that if 'then match #2' is found, will it be considered a complete match.
All regular expression slots are collected from all matches and passed to
the block. We can see that the rule matched this very paragraph.

    @a.assert == [1,2]

This concludes the basic overview of QED's specification system, which
is itself a QED document. Yes, we eat our own dog food.

