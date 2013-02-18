# Toplevel Simulation

QED simulates Ruby's TOPLEVEL environment in both the Demonstrandum
and the Applique contexts. This serves two important purposes.
First, it provides the tester the environment that is most intutive.
And second, and more importantly, it stays out of the actual
TOPLEVEL space to prevent any potential interferece with any of 
the code it is intended to test.

Let's look at some examples. For starters, we have access to a class
defined at the "toplevel" in the applique.

    ToplevelClass

We can also call a method defined in the toplevel.

    toplevel_method.assert == true

At the demonstrandum level we can define reusable methods.

    def demo_method
      true
    end

    demo_method.assert == true

And at the demonstrandum level even singleton methods are accessible.

    def self.singleton_method; true; end

    singleton_method.assert == true

QED uses a self-extend modules to achieve this simulation, so the
contexts are in fact a bit more capable then even Ruby's TOPLEVEL.
For instance, #define_method can be used.

    define_method(:named_method){ true }

    named_method.assert == true

