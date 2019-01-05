# Frostmoon
FrostMoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OSX and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
## Loading components
To load a component, put it in the "components" directory in top level directory where frostmoon.lua resides. The default can be overriden by changing the "component_dir" variable in frostmoon.lua. Frostmoon will go through all the folders and subfolders in the component directory, loading all .lua files it finds as components.
## Writing your own components
Components are easy to write as long as they do the following:
- Components MUST return a table as the final thing they do. This is because frostmoon is treating them like modules and using require on them.
- Components should expect to have a component_type that is their folder path below the components directory, seperated by "." notation. This is also what frostmoon will use as the table key to look them up for instantiation. So, if you make a class file myClass.lua and store it in components/gui/myClass.lua, it will be of type "gui.myClass". The reuslts of loading the class will be stored in frostmoon.components["gui.myClass"].
- If you want your components to have default variables, make sure to assign them as a table with key "defaults" in the return table of your class. This is where frostmoon will look for them when instantiating objects of your class.
Something like:
```
local Component = {}

Component.defaults = {
   ["default1"] = "A default",
   ["default2"] = "Another default",
}

return Object
```
You should probably make sure that your defaults cover at least the minimum to safely instantiate a component of that type.
- If you want your class to have class methods, you can add them like so:
```
local Button = {}

function Button:push()
   print("Button uuid" .. tostring(self._uuid) .. " pushed.")
end

return Button
```
Note: At this time there is no way to bind functions invocations in default values. This is due to the dynamic loading of the component classes themselves. For most cases you should be able to just specify them in the class definition
and then invoke them from the instance.
## instantiating Components
Once you have imported the frostmoon module like so:
```
local f=require("frostmoon")
```
You will be able to use tables of arguments to create components using the
new function of frostmoon. The arguments table will need to specify at the minimum the component type as explained above. If the component class has
defaults, you can ovveride them by specifying an argument with the same key.
You can even put other components inside and instantiate those at the same time.
```
local new_args = {
   ["component_type"]="data.object",
   ["embedded_table"]= {"table entry 1","table entry 2","table entry 3"},
   ["subcomponent"]= {
      ["component_type"]="gui.button",
   }
}
test_obj = f:new(new_args)
```
