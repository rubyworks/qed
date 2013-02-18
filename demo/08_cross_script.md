# Cross-Scripting Setup

We define some variables here to make sure it is
not visible in the next script.

Let's set two local variables.

    a = 100
    b = 200

And two instance varaibles.

    @a = 1000
    @b = 2000

Also let check how it effect constants.

    CROSS_SCRIPT_CONSTANT = "cross?"

And a method.

    def cross_script_method
      "common"
    end

