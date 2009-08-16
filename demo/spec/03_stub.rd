= Respect's Stubbing Facility

Require stub.rb library.

  require 'respect/stub'

== Stubs via Delegation

Delegation provides the most robust form of delegation.
In this example we will stub-out a simple string.

   @obj = "hello"

We can create a reusable stub module by instantiating
a new Stub.

   @stb = Respect::Stub.new
   @stb.upcase == "HeLLo"

Now we apply the stub module to the object we want to stub.

   @alt = @obj.stub(@stb)

And get the newly stubbed object that delegates to the 
original.

   @alt.upcase.assert == "HeLLo"

And as you can see, the original is still intact.

   @obj.upcase.assert == "HELLO"

== Reusing Stubs via Object Extension

Stubs are modules, so they can also be used via #extend.
For example a new string:

   @obj = "hi"

Can be extended with the stub we used in the previous 
section.

   @obj.extend(@stb)
   @obj.upcase.assert == "HeLLo"

We can change the stub dynamically too.

   @stb.upcase == "hI"
   @obj.upcase.assert == "hI"

And remove it if we need the object to return to
it's original behavior.

   @obj.remove_stub(@stb)
   @obj.upcase.assert == "HI"

== Quick Stubs

Each object is also given one special built-in stub,
accessible via its #stub method.

   @obj = "hey"
   @obj.stub.upcase == "HeY"
   @obj.upcase.assert == "HeY"

Under the hood, the effect is the same as +obj.extend(obj.stub)+.
We can remove this special stub via #remove_stub by leaving
out the stub argument.

   @obj.remove_stub  

This imples +obj.remove_stub(obj.stub)+.

   @obj.upcase.assert == "HEY"

And as you can see, we are back to the normal String behaivor.

