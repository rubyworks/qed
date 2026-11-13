# Comment Mode

With the `--comment` option, QED runs the examples in the comments of
a Ruby script, the indented lines, as it would a demo's.

    sample = File.dirname(__FILE__) + '/samples/yard.rb'
    demo   = QED::Demo.new(sample, :mode=>:comment)
    code   = demo.steps.select(&:code?).map { |step| step.code.strip }

A plain example runs, and so does the code under an `@example` tag.

    code.assert.include?("YardSample.double(2).must_return(4)")
    code.assert.include?("YardSample.double(1.5).must_return(3.0)")

## YARD Tags

YARD continues a tag's text on the indented lines after it. Those
lines are part of the tag, not example code, so they don't run.

    code.grep(/Scheduled/).assert.empty?
    code.grep(/times two/).assert.empty?

The tag's text is kept with the explanation instead.

    text = demo.steps.map(&:explain).join
    text.assert.include?("Scheduled for removal next year.")
