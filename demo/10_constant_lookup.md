# Missing Constant

If a constant is missing it is because it was not found
in either the demos scope, the applique or at the toplevel.

    begin
      UnknownConstant
    rescue => err
      # no colon means toplevel
      err.name.to_s.refute.include?('::')
    end

A constant defined in the applique is visible.

    APPLIQUE_CONSTANT.assert = true

