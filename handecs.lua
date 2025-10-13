local handecs = {
   components = {},
}

function handecs:component(data)
   local index = #self.components + 1
   self.components[index] = data
   return index
end

return handecs
