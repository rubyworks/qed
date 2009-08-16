= Respect's Mocking Facility

Respect's mocks are not like mocks in other frameworks.
Traditional mocks are too closely knit to underlying
implementation. Respect mocks are instead light-weight
pre-assertion containers.

Require mock.rb library.

  require 'respect/mock'

== Mocks via Delegation

As with stubs, delegation provides the most robust means 
for implemention mocks. In this example we will mock-out
a simple string.

  @obj = "hello"

We can create a reusable mock module by instantiating
a new Mock.

  @mck = Respect::Mock.new
  @mck.upcase == "HeLLo"

Now we apply the mock module to the target object and
we get a new mocked object, which delegates to the original.

  @alt = @obj.mock(@mck)

When to invoke the target method, it will apply our assertion
about the method, testing if the original object indeed 
produces the mocked result. In this case, the method #upcase
produces "HELLO" and not "HeLLo" (ie, "HeLLo" != "HELLO"),
so an Assertion exception is raised.

  expect(Assertion){ @alt.upcase }

You can see that the original object is in no ways affected
by the mock.

  @obj.upcase.assert == "HELLO"

== Reusing Mocks via Object Extension

Macks are modules, so they can also be reused via #extend.
For example a new string:

  @obj = "hi"

Can be mocked with the Mock object we used in the previous section.

  @obj.extend(@mck)

An Assertion error will be raised again because "hi".upcase != "HeLLo".

  expect(Assertion){ @obj.upcase }

We can change the mock on the fly.

  @mck.upcase == "HI"

Now we can call the #upcase method and nothing will be raised,
since "hi".upcase == "HI".

  @obj.upcase

The mock can be removed from the object using #remove_mock.

  @mck.upcase == "GO BOOM"
  @obj.remove_mock(@mck)
  @obj.upcase

== Quick Mocks

Each object is also given one special built-in mock,
accessible via its #mock method.

  @obj = "hey"
  @obj.mock.upcase == "HeY"

  expect(Assertion){ @obj.upcase }

Under the hood, the effect is the same as +obj.extend(obj.mock)+.
We can remove this special mock via #remove_mock by leaving
out the argument.

  @obj.remove_mock
  @obj.upcase.assert == "HEY"

This imples +obj.remove_stub(obj.mock)+.
And as you can see, we are back to the normal String behaivor.


