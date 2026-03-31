# Ruby Q.E.D.

[Homepage](https://rubyworks.github.io/qed) /
[Documentation](https://rubydoc.info/gems/qed/frames) /
[Report Issue](https://github.com/rubyworks/qed/issues) /
[Development](https://github.com/rubyworks/qed)


## Introduction

Q.E.D. is an abbreviation for the well known Latin phrase "Quod Erat Demonstrandum",
literally "which was to be demonstrated", which is oft written in its abbreviated
form at the end of a mathematical proof or philosophical argument to signify
a successful conclusion. And so it is too for Ruby Q.E.D., though it might as easily
be taken to stand for "Quality Ensured Documentation".

QED is in fact both a test framework and a documentation system for Ruby
developers. QED sits somewhere between lower-level testing tools like Test::Unit
and grandiose requirement specifications systems like Cucumber. In practice it
works exceptionally well for *API-Driven Design*, which is especially
useful when designing reusable libraries, but it can be used to test code at
any level of abstraction, from unit test to systems tests.


## Features

* Write tests and documentation in the same breath!
* Demos can be Markdown or RDoc format.
* Supports fenced code blocks — non-Ruby blocks (e.g. ` ```elixir `) are automatically skipped.
* Can use any BRASS compliant assertion framework, such as the excellent AE (Assertive Expressive) library.
* Data and Table macros allow large sets of data to be tested by the same code.
* HTML report generation via `--html` flag.
* Documentation tool (`qedoc`) generates browsable HTML from demos.


## Synopsis

### Assertion Syntax

QED can use any BRASS compliant assertions framework. Simply require the library in
ones applique (see below). Traditionally this has been the AE (Assertive Expressive) library,
which provides an elegant means to make assertions. To give a quick overview, assertions
can be written as:

    4.assert == 5

In this example, because 4 != 5, this expression will raise an Assertion
exception. QED's Runner class is thus just a means of running and capturing
code blocks containing such assertions.

You can learn more about BRASS and AE at https://github.com/rubyworks/brass and
https://github.com/rubyworks/ae, respectively.

### Document Structure

QED documents are simply text files called *demonstrandum* (demos for short).
Because they largely consist of free-form descriptive text, they are a practice
of pure Literate Programming. For example:

    # Example

    Shows that the number 5 does not equal 4.

        5.assert! == 4

    But in fact equals 5.

        5.assert == 5

Description text aligns to the left margin and all code is indented. QED also
supports fenced code blocks:

    ```ruby
    5.assert == 5
    ```

Blocks tagged with a non-Ruby language are skipped during execution, which is
useful for multi-language documentation:

    ```javascript
    // This is not executed
    console.log("hello");
    ```

QED recognizes Markdown and RDoc headers for improved console output. The
essential take away is that QED *demonstrandum* are simply descriptive
documents with interspersed blocks of example code.

### Running Demonstrations

If we were to run the above document through QED in verbatim mode the output
would be identical (assuming we did not make a typo and the assertions passed).
If there were errors or failures, we would see information detailing each.

To run a document through QED, simply use the `qed` command.

    $ qed -v demo/01_example.md

The `-v` option specifies verbatim mode, which outputs the entire document.

Notice we placed the QED document in a `demo/` directory. This is the
canonical location, but demonstrations can be placed anywhere. The `qed`
command will look for `qed/`, `demo/`, `demos/` and `spec/`, in that order,
if no path is given.

The `01_` prefix helps order documents when generating QED documentation.

To generate an HTML test report:

    $ qed --html > report.html

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
the @round instance variable will be reset to an empty array.

It is rather amazing what can be accomplished with such a system.
Be sure to look at QED's own demonstrandum to get a better notion of
how you can put the system to use.

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

### Generating Documentation

To generate documentation from QED documents, use the `qedoc` command.

    $ qedoc --output doc/demo.html --title "Example" demo/

When documenting, QED recognizes the format by the file extension and
treats it accordingly.

Use the `--help` option on each command to get more information
on the use of these commands.


## Requirements

QED depends on the following libraries:

* [BRASS](https://github.com/rubyworks/brass) - Assertions System
* [ANSI](https://github.com/rubyworks/ansi) - ANSI Color Codes
* [kramdown](https://kramdown.gettalong.org/) - Markdown Processing

These will be automatically installed when installing QED via RubyGems.

Optional libraries that are generally useful with QED:

* [AE](https://github.com/rubyworks/ae) - Assertions Framework

Install AE and require it in your applique to use.

Requires Ruby 3.1 or later.


## Development

### Testing

QED uses itself for testing. To run the tests:

    $ rake demo

Or directly:

    $ ruby -Ilib bin/qed

To generate a test coverage report:

    $ rake demo:cov


## Copyrights

(BSD-2-Clause license)

Copyright (c) 2009 Rubyworks. All rights reserved.

See LICENSE.txt for details.
