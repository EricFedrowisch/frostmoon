# Frostmoon
Frostmoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
## Introduction
Frostmoon is meant to be a data driven object oriented library for Lua that runs on iOS, OS X and Windows 10. The goal is to make complex programs more easily possible. With Frostmoon it should be able to create a program by specifying object classes and the arguments to create instances of them.
## Frostmoon Terminology
- Object versus Component vesus Table:
Frostmoon is written in Lua, where the only data structure is the table. So both what I call Objects and Components are tables. The difference between the two in Frostmoon is that Objects usually are simple tables that are made to be the top level containers of Components. Components don't HAVE to be contained in Objects though and Components can contain other Components. When tables are mentioned, they are usually meant in the strict sense of an actual Lua table.
- Class versus Module versus Component:
All Components must have a Class. That class is in the form of a .lua file with the Class name. All the classes are loaded as modules during after frostmoon.lua is required.
## Loading components
To load a component, put it in the "components" directory in top level directory where Frostmoon.lua resides. The default location can be overriden by changing the "component_dir" variable in Frostmoon.lua. Frostmoon will go through all the folders and subfolders in the component directory, loading all .lua files it finds as components.
## Writing your own components
Components are easy to write as long as they do the following:
- Components MUST return a table as the final thing they do. This is because Frostmoon is treating them like modules by using require on them.
- Components should expect to have a component_type that is their folder path below the components directory, seperated by "." notation. This is also what Frostmoon will use as the table key to look them up for instantiation. So, if you make a class file myClass.lua and store it in components/gui/myClass.lua, it will be of type "gui.myClass". The reuslts of loading the class will be stored in frostmoon.components["gui.myClass"].
- If you want your components to have default variables, make sure to assign them as a table with key "defaults" in the return table of your class. This is where Frostmoon will look for them when instantiating objects of your class.
Something like:
```
local Component = {}

Component.defaults = {
   ["default1"] = "A default",
   ["default2"] = "Another default",
}

return Component
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
## Instantiating Components
Once you have imported the Frostmoon module like so:
```
local f=require("frostmoon")
```
You will be able to use tables of arguments to create components using the
new function of Frostmoon. The arguments table will need to specify at the minimum the component type as explained above. If the component class has
defaults, you can ovveride them by specifying an argument with the same key.
You can even put other components inside and instantiate those at the same time.
```
local new_args = {
   ["component_type"]="data.object",
   ["embedded_table"]= {"table entry 1","table entry 2","table entry 3"},
   ["subcomponent"]= {
      ["component_type"]="gui.button"
   }
}
test_obj = f:new(new_args)
```
