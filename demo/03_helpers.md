# Helpers

There are two ways to load advice scripts. Manually loaded
helpers act pe-demonstrandum and so apply only to the currently
executing demo. Automaticly loaded helpers apply to all 
demonstrandum within their preview.

Helper scripts can be written just like demonstration scripts,
or they can be defined as pure Ruby scripts.

## Automatic Helpers

Automatic helpers, known as the "applique" are loaded at the
start of a session and apply equally to all demonstrandum within
the same or lower directory as the demo. These helpers are placed
in an +applique+ subdirectory. For instance this document uses,
[applique/env.rb](applique/env.rb).

## Manual Helpers

Manual helpers are loaded per-demonstration by using specially
marked links.

For example, because this link, [Advice](qed://helpers/advice.rb),
begins with `qed:`, it will be used to load a helper. We can 
see this with the following assertion.

    pudding.assert.include?('loaded advice.rb')

No where in the demonstration have we defined +pudding+, but
it has been defined for us in the advice.rb helper script.

We can also see that the generic When clause in our advice
helper is keeping count of decriptive paragraphs. Since the
helper script was loaded two paragraphs back, the next count
will be 3.

    count.assert == 3

Helpers are vital to building test-demonstration suites for
applications. But here again, only use them as necessary.
The more helpers you use the more difficult your demos will
be to follow.

