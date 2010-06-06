require 'qed/domain_language'

module QED

  # Scope is the context in which QED documents are run.
  # Note, that Scope is now a facade over the TOPLEVEL.

  class Scope

    # Scope is an immitation of TOPLEVEL.
    # TODO: mixin facets/main.rb module ?
    def self.new
      #@self ||= (
        o = ::Object.new
        o.extend QED::DomainLanguage
        o
        #TOPLEVEL_BINDING.eval("include QED::DomainLanguage")
        #TOPLEVEL_BINDING.eval('self')
      #)
    end

    #include DomainLanguage

    #def initialize
    #  @__binding__ = binding
    #end

    #def __binding__
    #  @__binding__
    #end
  end

end


