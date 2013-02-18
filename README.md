# Ruby Q.E.D.

[Homepage](http://rubyworks.github.com/qed) /
[Documentation](http://rubydoc.info/gems/qed/frames) /
[Report Issue](http://github.com/rubyworks/qed/issues) /
[Development](http://github.com/rubyworks/qed) /
[Mailing list](http://groups.google.com/group/rubyworks-mailinglist) &nbsp; &nbsp;
[![Build Status](https://secure.travis-ci.org/rubyworks/qed.png)](http://travis-ci.org/rubyworks/qed)
[![Gem Version](https://badge.fury.io/rb/qed.png)](http://badge.fury.io/rb/qed)


## Introduction

Q.E.D. is an abbreviation for the well known Latin phrase "Quod Erat Demonstrandum",
literally "which was to be demonstrated", which is oft written in its abbreviated
form at the end of a mathematical proof or philosophical argument to signify
a successful conclusion. And so it is too for Ruby Q.E.D., though it might as easily
be taken to stand for "Quality Ensured Documentation". 

QED is in fact both a test framework and a documentation system for Ruby
developers. QED sits somewhere between lower-level testing tools like Test::Unit
and grandiose requirement specifications systems like Cucumber. In practice it
works exceptionally well for <i>API-Driven Design</i>, which is especially
useful when designing reusable libraries, but it can be used to test code at
any level of abstraction, from unit test to systems tests.


## Features

* Write tests and documentation in the same breath!
* Demos can be RDoc, Markdown or any other conforming text format.
* Can use any BRASS compliant assertion framework, such as the the excellent AE (Assertive Expressive) library.
* Data and Table macros allows large sets of data to be tested by the same code.
* Documentation tool provides nice output with jQuery-based TOC.


## Synopsis

### Assertion Syntax

QED can use any BRASS compliant assertions framework. Simply require the library in
ones applique (see below). Traditionally this has been the AE (Assertive Expressive) library,
which provides an elegant means to make assertions. To give a quick overview, assertion
can be written as:

    4.assert == 5

In this example, because 4 != 5, this expression will raise an Assertion
exception. QED's Runner class is thus just a means of running and capturing
code blocks containing such assertions.

You can learn more about BRASS and AE at http://rubyworks.github.com/brass and
http://rubyworks.github.com/ae, repectively.

### Document Structure

QED documents are simply text files called *demonstrandum* (demos for short).
Because they largely consist of free-form descriptive text, they are a practice
pure Literate Programming. For example:

    = Example

    Shows that the number 5 does not equal 4.

        5.assert! == 4

    But in fact equals 5.

        5.assert == 5

In this example RDoc was chosen for the document format. However, almost any
text format can be used. The only necessary distinction is that description text
align to the left margin and all code be indented, although QED does recognize
RDoc and Markdown single-line style headers, so any format that supports
those (which covers many markup formats in use today) will have mildly
improved console output. In any case, the essential take away here is that
QED *demonstrandum* are simply descriptive documents with interspersed 
blocks of example code.

Give this design some thought. It should become clear that this approach is
especially fruitful in that it allows *documentation* and *specification*
to seamlessly merge into a unified *demonstration*. 

### Running Demonstrations

If we were to run the above document through QED in verbatim mode the output
would be identical (assuming we did not make a typo and the assertions passed).
If there were errors or failures, we would see information detailing each.

To run a document through QED, simply use the +qed+ command.

  $ qed -v demo/01_example.rdoc

The `-v` option specifies verbatim mode, which outputs the entire
document.

Notice we placed the QED document in a `demo/` directory. This is the
canonical location, but there is no place that demonstrations have to go. They
can be placed anywhere that is preferred. However, the `qed` command
will look for `qed/`, `demo/`, `demos/` and `spec/`, in that order, if no
path is given.

Also notice the use of ``01_`` prefix in front of the file name.
While this is not strictly necessary, QED sorts the documents, so it helps order
the documents nicely, in particular when generating QED documentation ("QEDocs").

### Utilizing Applique

QED demonstrandum descriptive text is not strictly passive explanation. Using
pattern matching techniques, document phrases can trigger underlying actions.
These actions provide a support structure for running tests called the *applique*.

Creating an applique is easy. Along with your QED scripts, to which the 
applique will apply, create an `applique/` directory. In this
directory add Ruby scripts. When you run your demos every Ruby script in 
the directory will be automatically loaded.

Within these applique scripts *advice* can be defined. Advice can be
either *event advice*, which is simply triggered by some fixed cycle
of running, such as `Before :each` or `After :all`,
and *pattern advice* which are used to match against descriptive
phrases in the QED demos. An example would be:

    When "a new round is started" do
      @round = []
    end

So that whenever the phrase "a new round is started" appears in a demo,
the @round instance variable with be reset to an empty array.

It is rather amazing what can be accomplished with such a system,
be sure to look at QED's own demonstrandum to get a better notion of
how you can put the the system to use.

### Configuration

Configuration for `qed` can be placed in a `etc/qed.rb` file, or if
you are using Rails, in `config/qed.rb`. Here's a generally useful
example of using SimpleCov to generate a test coverage report when
running your QED demos.

    QED.configure 'coverage' do
      require 'simplecov'
      SimpleCov.start do
        coverage_dir 'log/coverage'
      end
    end

You can then use the profile via the `-p/--profile` option on the command line:

    $ qed -p coverage

Or by setting the `profile` environment variable.

    $ profile=coverage qed

QED can also use the [RC](http://rubyworks.github.com/rc) gem to handle
configuration. Be sure to `gem install rc` and then add this to `.rubyrc`
or `Config.rb` file of the same effect as given above.

    config :qed, :profile=>:coverage do
      require 'simplecov'
      SimpleCov.start do
        coverage_dir 'log/coverage'
      end
    end

### Generating Documentation

To generate documentation from QED documents, use the +qedoc+ command.

    $ qedoc --output doc/qedoc --title "Example" demo/*.rdoc

When documenting, QED recognizes the format by the file extension and 
treats it accordingly. An extension of `.qed` is treated the same
as `.rdoc`.

Use the `--help` options on each command to get more information
on the use of these commands.


## Requirements

QED depends on the following external libraries:

* [BRASS](http://rubyworks.github.com/brass) - Assertions System
* [ANSI](http://rubyworks.github.com/ansi) - ANSI Color Codes
* [RC](http://rubyworks.github.com/rc) - Runtime Configuration
* [Facets](http://rubyworks.github.com/facets) - Core Extensions

These will be automatically installed when installing QED via RubyGems,
if they are not already installed.

Optional libraries that are generally useful with QED.

* [AE](http://rubyworks.github.com/ae) - Assertions Framework

Install these individually and require them in your applique to use.


## Development

### Testing

QED uses itself for testing, which can be a bit tricky. But works fine for
the most part. In the future we may add some addition tests via another
test framework to ensure full coverage. But for now QED is proving sufficient.

To run the tests, use `qed` command line tool --ideally use `$ ruby -Ilib bin/qed`
to ensure the current version of QED is being used.

For convenience, use `$ fire spec` to run the test specifications. To also 
generate a test coverage report use `$ fire spec:cov`.


## Copyrights

(BSD-2-Clause license)

Copyright (c) 2009 Rubyworks. All rights reserved.

See LICENSE.txt for details.

