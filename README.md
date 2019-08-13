# Frostmoon
Frostmoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
## Introduction
Frostmoon is meant to be a data driven object oriented library for Lua that runs on iOS, OS X and Windows 10. The goal is to make it easier and faster to make cross platform apps. Frostmoon allows both composition and inheritance object oriented, though it favors [composition over inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance).
## Frostmoon Terminology
- Object versus Component vesus Table:
Frostmoon is written in Lua. Lua's only data structure is the table. So in Frostmoon terminology both Objects and Components are tables. Objects are simple tables that are made to be the top level containers of Components. Components don't HAVE to be contained in Objects however. Components can also contain other Components.
- Class versus Module versus Component:
All Components must have a Class. That class is in the form of a '.lua' file with the Class name. All the classes are loaded as modules after Frostmoon.lua is required.
## Writing your own components
Components are easy to write. Simply put a '.lua' file in the components folder.
At runtime, Frostmoon will go through all the folders and subfolders in the component directory, loading all '.lua' files it finds as component classes.
### All component classes MUST do the following:
Components MUST return a table as the final thing they do. This is because Frostmoon is treating them like modules by using require on them.
### Component Type
The component_type table value is the class file's folder path relative to the components directory, seperated by "." notation. So, if you make a class file myClass.lua and store it in components/gui/myClass.lua, it will be of type "gui.myClass". The reuslts of loading the class will be stored in Frostmoon.components["gui.myClass"]. This is also what Frostmoon will use as the table key to look them up for instantiation.
### Class Default Instantion Values
If you want your components to have default variables, make sure to assign them as a table with key "defaults" in the table of your class. This is where Frostmoon will look for them when instantiating objects of your class.
Something like:
```
local Component = {}

Component.defaults = {
   ["default1"] = "A default",
   ["default2"] = "Another default"
}

return Component
```

You should probably make sure that your defaults cover at least the minimum to safely instantiate a component of that type.
### Class Methods
If you want your class to have class methods, you can add them like so:
```
local Button = {} --Class table to return

function Button:push() --Class function
   print("Button uuid" .. tostring(self._uuid) .. " pushed.")
end

return Button --Always return class table as last thing
```
### The 'init' Component Method
Component classes can have an optional method named init. If defined, init is called when a component is initialized. It is automatically passed the same arguments used to create the component. This is necessary for certain function calls that would not be certain to have good references before all components have been loaded, or Löve has finished initializing ie. This is also how components can initialize their super classes.
### Ineritance in Frostmoon Components
To make a component inherit from another, use the init class function.
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
local test_obj = Object{
   ["embedded_table"]= {"table entry 1","table entry 2","table entry 3"},
   ["subcomponent"]= Button{}
   }
}

```

### Frostmoon's Factory Pattern new method
When Frostmoon's new method is called, it must be passed a table of arguments to use. This table can contain other tables as well. Frostmoon's new method will recursively create new tables and components from what its given. Frostmoon looks for a table value named 'component_type' to know what type of component to create. If a table in the creation arguments has no 'component_type', it is assumed to be a normal Lua table rather than a component.

Example of using Frostmoon's Factory Pattern new method:
```
local component = {
   ["component_type"] = "gui.button",
   ["x"] = 0,
   ["y"] = 0,
   ["random_table"] = {1,2,3}
}

local some_table = {1,2,3,"some string"}

local button = Frostmoon:new({
   component,
   some_table
   })
```

Outputs:
```
1 =
   y = 0
   x = 0
   component_type = gui.test
   random_table =
      1 = 1
      2 = 2
      3 = 3
2 =
   1 = 1
   2 = 2
   3 = 3
   4 = some string
```
## Load Order for Frostmoon App
![Load Order](/docs/Frostmoon_Load_Diagram.png "Frostmoon Load Order")
