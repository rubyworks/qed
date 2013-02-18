# RELEASE HISTORY

## 2.9.1 | 2013-02-20

The RC gem is optional now and old school `etc/qed.rb`, `config/qed.rb` and
`.qed` are all supported again.

Changes:

* Resupport traditional config files.
* Make RC optional dependency.
* Add support for Markdown-style helper links.


## 2.9.0 | 2012-05-19

IMPORTANT! The `.qed` configuration file is no longer used for configuration.
Either use a unified `.ruby` or `.rubyrc` file or require a special config file
via the `-r` option, e.g. `qed -r ./config/cov.rb`.

General configuration is now handled by the RC library. The only other
form of configuration supported is that of requiring a special file
directly via `-r ./path/to/file.rb`. This keeps the code as
simple as possible without giving-up functionality. Because the old
`.qed` configuration file is no longer supported, this release has
a major version bump.

Changes:

* Utilize the RC configuration management library.
* Improve hash-arrow assertion notation.


## 2.8.8 | 2012-03-17

Feel like a heel after the last four releases. The simplest solution
to the configuration issue is to allow traditional configuration
trump confection based configuration. If the former is used, then
the later will never even load. Problem solved.

Changes:

* Traditional configuration trump Confection configuration.


## 2.8.7 | 2012-03-16

Release fixes a bug that prevented default demo locations from being
used when none are specified on the command line. Also change way
to deactivate use of Confection for configuration, use environment
variable `config='legacy'`.

Changes:

* Fix bug that prevented default demo locations from being used.
* Change environment variable to config='legacy' to deactivate Confection.


## 2.8.6 | 2012-03-15

This release simply make the configuration more versatile by supporting
Confection, task directory and traditional `.qed` configuration.

Changes:

* Support variety of configuration systems.


## 2.8.5 | 2012-03-14 19:00

Minor release simply make sure configuration file(s) were distributed 
with package. Part of the new idea that configurations can be 
reusable.

Changes:

* Include configuration files in distribution.


## 2.8.4 | 2012-03-14 18:06

Just a fix of a method that should have been renamed. Nothing to see here.

Changes:

* Renamed #config_override to #configless?.


## 2.8.3 | 2012-03-14 18:00

What a difference a week makes ;) The Confection library has been substantially
improved and if that trend continues at all then I think it will be well worth
supporting. So with this release QED will again move configuration handling
over to Confection. Jump over to the Confection project to learn how to use it.
In short, this release reverts the previous release. Along with this change,
profiles are now specified via the `-p`/`--profile` command line option instead
of specialized options.

Changes:

* Use Confection library for configuration.
* Use `-p`/`--profile` to select configuration profile.
* Use `config='none'` environment variable to circumvent Confection.
* Deprecated use of `.map` configuration redirection file.


## 2.8.2 | 2012-03-07

This release simply reverts the configuration file back to an
independent file. The use of the Confection library was a "noble
idea", but in the end not one that's likely to gain traction among 
developers in general, so we have decided to revert back to the
more traditional `.qed` config file. However, we also added built-in
support for `task/qed.rb`, which we encourage so as to promote
clean project structures. Further, QED also supports the `.map` YAML
configuration file which allows you to move the QED config file
wherever you might prefer it. Just add a `qed: path/to/config/file`
entry.

Changes:

* Revert to dedicated configuration file.


## 2.8.1 | 2012-02-01

This release fixes a bug in the parsing of `#=>` notation. It also
adds syntax highlighting to qedoc generated documentation. It does
this with highlight.js.

Changes:

* Fix parsing of `#=>`.
* Add highlight.js to qedocs.


## 2.8.0 | 2012-01-19

IMPORTANT: READ THIS RELEASE NOTICE! This release makes a minor
change, but it is one that will effect all end-users. That is, QED no
longer depends on AE as its one and only assertion framework. Instead
any compliant framework can be used. Certainly most users will be happy
to continue using AE, in which case simply add `require 'ae'` to your
applique (e.g. in 'spec/applique/ae.rb') or add `-r ae` to the qed command
line invocation to ensure demos continue running as before. In place of
AE the _BRASS_ gem now provides basic assertion support. Any assertion
framework that complies with the simple BRASS standards will work with QED.

Changes:

* No longer depend only on AE for assertion framework.
* Rename $assertion_counts to $ASSERTION_COUNTS.
* Complies with assertion standards set by BRASS project.


## 2.7.0 | 2011-11-18

The focus of this release is a much improved underlying API, including
a better event model and the application of SOLID principles to really
get the code in good shape. In most respects the changes will not effect
QED documents --at most some event signals may need to be adjusted, if
an old applique happened to use them.

Beyond the underlying code, some other important changes have been made.

Configuration is now handled by the `confection` gem. Simply add a `qed`
section to your `Confile`. In it you can add `profile` blocks. See QED
project's own `.confile` for an example.

A new notation for captures has been added. Captures can now be written
as `/(\S+)/` and non-capture expressions as `/?:\S+/`. The old 
parenthetical notation still works. Strings arguments may also add `...`
to split the string into two match arguments without actually having
to pass two arguments.

The change most likely to effect old demonstrandum, is the deprecation
of `...` plain text marker. Be sure to make sure your demos use `:` instead.

Changes:

* Deprecate use of '...' as a plain text example indicator.
* When string arguments can use '...' to split the match.
* Applique files can now be demo documents too.
* Use confection gem for configuration.
* Must use `-f` option to use (most) alternative reporters.
* Show full backtrace in (most) reporters.
* Overhaul evaluator using better signal names.
* Underlying observer API redesigned (effects reporters).
* Rework API taking SOLID principles into consideration.


## 2.6.3 | 2011-10-23

Fixed output status. When tests fail or error the `qed`
command with exit -1 instead to 0. Also, the default
spec location uses only one of `qed`, `demo` or `spec`
instead of all.

Changes:

* Fix output status, exit -1 on test failure or error.
* Fix default spec location to only use one or the other.


## 2.6.1 | 2011-07-02

A friend suggested QED default the load path to lib and
automatically look for QED demos in default locations
(qed, demo, spec) if no files are passed to it on the
command line. So it is.

Changes:

* Default loadpath option to lib/.
* Default files to markup files in spec/, demo/ and qed/.
* Fix website links (you might actually find things now).


## 2.6.0 | 2011-07-01

This release fixes some issues with reporters, further refines
their output and adds the start of a new reporter called dtrace.
Also the Table and Data macros have been updated. Table can now
handle a YAML stream with the :stream option, and Data no long runs
the text through YAML.load when the file name ends in .yml or .yaml,
In other words it's for raw fixture data. Finally the documentation
tool has been improved to simplify HTML generation and also add a
format option for creating a simple plain text merging instead.

Changes:

* Data is raw and no longer uses YAML.load.
* Table can handle a YAML stream, via :stream option.
* Better handling of code snippets.
* Backtrace count defaults to 2 rather than 3.
* Load ansi/core, rather than ansi/code.
* Doc output setting takes a file name instead of directory.
* Support for plain text format (by simple file merge).
* HTML output is single file, jquery comes from CDNJ.


## 2.5.2 | 2011-06-26

This release focuses on reporter improvements. Better trace
information is now displayed, and the max number of backtrace
lines can be set with the -t option, or $trace environment
variable.

Changes:

* Trace option takes a max count setting (0 for all).
* Trace count can also be set via $trace environment variable.
* Added TAP-Y reporter.


## 2.5.1 | 2011-06-07

This release makes a number adjustments and fixes one major issue
with the way the latest AE library counts assertions.

Changes:

* Fix references to AE assertion counts.
* @_ stores the return value of last execution block.
* Backtrace filter omits references to AE library.


## 2.5.0 | 2010-11-04

The latest release of QED improves on applique loading, such that each
demonstrandum gets it's own localized set. The CLI has also been modified
so that there is no longer a default location, the directory or files to run
must be specified.

Changes:

* Better handling of Applique.
* Remove Advice class --advice is now stored in Applique.
* Each applique file is it's own module.
* Advice from each applique is applied.
* CLI requires files be specified.


## 2.4.0 | 2010-09-02

All engines go! QED has not been tested against 1.8.6, 1.8.7 and 1.9.2.
Underthehood steps are not organized in doubly-linked lists, which makes
them much more robust and flexible. This release also improves scoping,
test counts, and inline documentation parsing.

Changes:

* Use new doubly-linked list step design.
* Fix -r option on command line.
* Provide #instance_exec core extension for Ruby 1.8.6.
* Scope is extended by and includes applique.


## 2.3.0 | 2010-07-14

Bug to the scurry! QED has broken through the code/document ceiling and
is cracking exoskeletons all the way to the bank. A proverbial can of
Roach-Be-Gone this is! What's that you say? I will explain. QED can now
run directly against code comments. Simply slip the qed command the -c
option and feed it some ruby scripts, and presto watch you comments
fail ;) I think you can figure out what to do next.

In addition to this coolness QED has been improved under the floor
boards as well. The parser, which is much faster, now blocks commentary
paragraphs and code examples together in one-to-one pairings. Not only
does this clean-up the code, but it opens up the potential for Around
advice in a future version.

Changes:

* NEW! Ruby script comment run mode.
* Better parsing system uses commentary-example pairs.
* Colon can also be used to specify plain text (along with ellipsis).
* Now distributed under the more permissive Apache 2.0 license.


## 2.2.2 | 2010-06-21

An issue was reported in which the a code block at the very
top of a demo was being ignored. This release fixes this issue
by rewriting the parser (much better now thanks!). At the same
time the Data and Table methods have been polished, both of
which can now pick up sample data relative to the current demo.

Changes:

* Rewrite parser and fix top code issue.
* Data method cannot write data, instead executes block.
* Data and Table methods look for file relative to demo first.
* Added -R option to run demos relative to project root.


## 2.2.1 | 2010-06-20

Remove dependencies to Tilt and Nokogiri. Should have
done this in last release but alas --there is so
much to do.

Changes:

* Removed HTML parsing dependencies.
* Reduce Advice to a single class.


## 2.2.0 | 2010-06-19

This release returns to a text-based evaluator, rather
then use HTML. Processing HTML proved to have too many
edge cases to be effective --both in implementation
and in end-usage. So to remedy the situation QED has
return to supporting simple markup formats such as
RDoc and Markup.

This release also adds multi-pattern advice. Instead of
a single pattern, multiple patterns can be matched
sequentially. This make it a easier to match large text
descriptions without restoring to regular expressions.

In addition QED now supports raw text blocks. By ending
a description section in ellipsis (...), the subsequent
code section becomes a plain text section and is passed
into the argument list of any matching When advice. This
makes it easy to scaffold fixture files, for example.

Finally, this release also refines the evaluation scopes.
Where before, a new binding was being created, each was 
attached to the TOPLEVEL, and therefore not truly isolated 
on a per-document basis. To correct, QED now mocks the
TOPLEVEL providing a new instance of this mock object for
each document.

Changes:

* No longer uses HTML for document processing.
* Support for plain text blocks using ellipsis.
* New sequential multi-pattern matches.
* Mock TOPLEVEL at both the demo and applique levels.
* Adjust color support for latest ANSI release.


## 2.1.1 | 2010-04-08

Fixed bug introduced in the last version that executed all
scripts in a single binding. There needed to be a binding
for each script.

Changes:

* Fixed cross-script bug by moving binding instantiation into Script class.


## 2.1.0 | 2010-04-07

QED documents are now run in the TOPLEVEL context, rather
than in a subclass of Scope. This ensures code runs as
one would expect it too in the wild.

Changes:

* Scope.new redirect to TOPLEVEL.
* DomainLanguage module is added to include into TOPLEVEL.


## 2.0.0 | 2010-03-04

This is a major new release of QED. All demonstration documents
are now converted to HTML via Tilt (http://github.com/tilt) before
being run through the test runner. So QED now supports any markup
format supported by Tilt, as well as ordinary HTML. Simply
stated, QED process <tt>pre</tt> tags as code and everything else
as comments. Nokogiri is used to parse the HTML.

Changes:

* HTML serves as a common format.
* New dependencies: Tilt and Nokogiri.
* New system of version numbers.


## 1.2.0 | 2009-12-07

This release adds a significant new feature, Comment Matchers.
These work like Cucumber allowing for background code to
be run when matching comments occur --a much better solution
for setup and teardown.

Changes:

* 2 Major Enhancements

  * Added command matchers via #When method.
  * All QED methods are now capitalized.

* 2 Minor Enhancements

  * Use OptionParser for qed executable.
  * Verbatim reporter is literally verbatim.


## 1.1.1 | 2009-09-05

This release needs a description.

Changes:

* 2 Major Enhancements

  * Helpers are provided by bottom code.
  * Added Markdown header support.

* 2 Minor Enhancements

  * Use Ansi project for color output.
  * Use latest RDoc version.


## 1.0.0 | 2009-06-30

QED has found itself. It took some time to really figure out
what this project "was" and how it should best be utilized.
This release is the initial release that puts QED in proper
perspective.

Changes:

* 2 Major Enhancement

    * Partial rewrite of a project that was once called "Quarry".
    * Now use AE for assertions.

