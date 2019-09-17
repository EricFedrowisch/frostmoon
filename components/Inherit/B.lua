local B = {}
B.__parent = "Inherit.A"

B.defaults = {
}

B.event_types = {
}

function B:testB()
   print("Function called that is defined in B.")
end

return B
