# Cross-Scripting Check

Make sure local and instance variables from previous
QED scripts are not visible in this document.

    expect NameError do
      a.assert = 100
      b.assert = 200
    end

And two instance_varaibles

    @a.assert! == 1000
    @b.assert! == 2000

Method definitions also do not cross QED scripts.

    expect NameError do
      cross_script_method
    end

Since each demo is encapsulated in a separated class scope, constants also
do not make their way across.

    expect NameError do
      CROSS_SCRIPT_CONSTANT
    end

