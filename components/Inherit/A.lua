local A = {}

A.defaults = {
   def1 = "Default 1 for A",
   def2 = 7,
   def3 = 9
}

A.event_types = {
}

function A:testA()
   return "Function called that is defined in A."
end

return A
