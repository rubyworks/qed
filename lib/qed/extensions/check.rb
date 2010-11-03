# TODO: place this in Scope ?

def check(&block)
  @_check = block
end

def ok(*args)
  @_check.call(*args)
end

#def no(*args)
#  @_check.call(*args)
#end

