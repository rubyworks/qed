# Quotes

We do not always want verbatim clauses to be interpreted as code.
Sometimes it would more useful to treat them a plain text to 
which the preceeding paragraph can make use in a processing rule.

For example let say we want to make an example out of the following
text:

    The file will contain

    this text

The use of the colon (`:`) tells the processor that the next
segment is a plain text continuation of the current segment, rather
than executable code. If the next segment is varbatim it will be added to
the end of the arguments list of any applicable processing rule.

Behind the scenes we created a rule to set the text to an instance
variable called @quote_text, and we can verify it is so.

    @quote_text.assert == "The file will contain\n\nthis text"

Alternately we can use a colon (':') instead of ellipsis. We can repeat
the same statment as above.

For example let say we want to make an example out of the following
text:

    The file will contain

    different text

And again we can verify that it did in fact set the @quote_text variable.

    @quote_text.assert == "The file will contain\n\ndifferent text"

