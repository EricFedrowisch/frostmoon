local B = {}
B.__parent = "Inherit.A"

B.defaults = {
   def1 = "Default 1 for B",
   def2 = 5
}

B.event_types = {
}

function B:testB()
   return "Function called that is defined in B."
end

return B
