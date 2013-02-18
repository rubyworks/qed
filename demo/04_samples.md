# Test Samples

## Flat-file Data

When creating testable demonstrations, there are times when sizable
chunks of data are needed. It is convenient to store such data in
separate files. The +Data+ method makes is easy to utilize them.

    Data(File.dirname(__FILE__) + '/samples/data.txt').assert =~ /dolor/

The +Data+ method can also take a block which passes the data
as the blocks only argument.

    Data(File.dirname(__FILE__) + '/samples/data.txt') do |data|
      data.assert =~ /dolor/
    end

Files are looked-up relative to the location of the current document.
If not found then they will be looked-up relative to the current
working directory.

## Tabular Data

The +Table+ method is similar to the +Data+ method except that it
expects a YAML file, and it can take a block to iterate the data over.
This makes it easy to test tables of examples.

The arity of the table block corresponds to the number of columns in
each row of the table. Each row is assigned in turn and run through
the coded step. Consider the following example.

Every row in the [table.yml table](table.yml) will be assigned to
the block parameters and run through the subsequent assertion.

    Table File.dirname(__FILE__) + '/samples/table.yml' do |x, y|
      x.upcase.assert == y
    end

Without the block, the +Table+ methods simply returns the sample data.

## Considerations

Both Data and Table are some what "old fashion" approches to sample
data. New techinques using plain text blocks are more convenient
in that the data can be stored directly in the demonstration itself.
However, for especially large data sets and external file is still
the better option, and +Data+ and +Table+ make them quite easy to
access.

