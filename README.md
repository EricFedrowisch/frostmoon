# Frostmoon
Frostmoon, cross platform Composition Based Object Factory and GUI library
targeting iOS, OS X and Windows 10
Copyright Aug. 9th, 2018 Eric Fedrowisch All rights reserved.
## Introduction
Frostmoon is an object oriented GUI library written in Lua that runs on iOS, OS X, Linux and Windows 10. Frostmoon exists to make it easier and faster to create cross platform apps, while minimizing platform specific code. Frostmoon allows both composition and single inheritance in objects, though it favors [composition over inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance). Frostmoon is built with [Löve](https://love2d.org/), an open source 2D framework.
## Frostmoon Terminology
- Component versus Table versus Objects:
Frostmoon is written in Lua. As Lua's only data structure is the table, all Frostmoon components are tables. It's also possible to put one or more component into another component or a simple table. These composite tables are generally referred to as Objects.
- Class versus Component:
All components belong to a class. Components are instantiated using the prototype table returned by that class. When Frostmoon is imported, all classes are automatically loaded from the components folder.
## Instantiating Components
Once you have imported the Frostmoon module like so:
```
local f=require("frostmoon")
```
You can create instances of any class by calling that class like so:
```
local obj = MyClass{}
```
The above would create a new instance of type MyClass, using the default arguments supplied by that class and storing it in the local variable "obj". You can override class defaults by specifying an argument with the same key.

Here's how an example of supplying arguments to create the instance:
```
local mc = MyClass{
   name = "myclass1",
   fx = function () print("Do the thing.") end,
   x = 5
}
```

You can also create more complex objects composed of multiple components and/or tables like so:
```
local test_obj = Component{
   embedded_table= {"table entry 1","table entry 2","table entry 3"},
   subcomponent= Button{
      component_type="gui.Button",
      x=100,
      y=100
      }
}
```
When making complex objects from tables of arguments, Frostmoon looks for a table key named 'component_type' to know what type of component to create. If a table has no 'component_type', it is assumed to be a normal Lua table rather than a component. In the example above, embedded_table will be stored in test_obj.embedded_table as a regular table and subcomponent will be instantiated as a component and then stored in test_obj.subcomponent.

### Using Frostmoon as an Object Factory with the new method
Frostmoon's object creation is very flexible. When creating components, you can also use Frostmoon's new method directly to create components and objects as per the [Factory method pattern](https://en.wikipedia.org/wiki/Factory_method_pattern). This allows you to supply arguments created at runtime or even during execution, for example. To create a component with the new method, you must supply an arguments table that specifies at the minimum the "component_type". You always have the option to use ```component_type  = "Component"``` for dynamically generated instances.

Example of using Frostmoon's Factory Pattern new method:
```
local component = {
   component_type = "gui.Button",
   x = 100,
   y = 200,
   random_table = {1,2,3}
}

local some_table = {1,2,3,"some string"}

local button = Frostmoon.new{
   component,
   some_table
   }
```

## Writing Your Own Components
Components are easy to write. Simply put a '.lua' file in the components folder.
At runtime, Frostmoon will go through all the folders and subfolders in the component directory, loading all '.lua' files it finds as component classes. Each class must have a unique name to avoid namespace collisions.
### All Component Classes MUST Return a Table:
Components MUST return a table as the final thing they do. Frostmoon treats them like modules by using require on them and checks that they return a table at runtime. This table is then used as the class prototype.
### Component Type
The component_type table value is the class file's folder path relative to the components directory, separated by "." notation. So, if you make a class file myClass.lua and store it in components/gui/myClass.lua, it will be of type "gui.myClass". The reuslts of loading the class will be stored in Frostmoon.components["gui.myClass"]. This is also what Frostmoon will use as the table key to look them up for instantiation. For convenience, you can still use the shorter ending class name to instantiate it like:
```
local mc = myClass{}
```
### Class Default Instantiation Values
If you want your components to have default variables, make sure to assign them as a table with key "defaults" in the table of your class. This is where Frostmoon will look for them when instantiating objects of your class.
Something like:
```
local Component = {}

Component.defaults = {
   default1 = "A default",
   default2 = "Another default"
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
Component classes can have an optional method named init. If defined, init is called as the end of component initialization. Init is automatically passed the same arguments used to create the component. This may be necessary for certain function calls that would not otherwise have good references to other classes or variables before all components have been loaded, or Löve has finished initializing ie.
### Inheritance in Frostmoon Components
Frostmoon allows for classes to have single inheritance. By default a class instance will inherit all variables and methods from the classes above it except those for which it supplies its own values. In addition, all classes inherit from the Component class. To set the parent for a class, use the "__parent" key in a class definition.
For example, assume we have two classes: A and B in the component/Inherit folder. B can inherit from A like so:

##File component/Inherit/A.lua
```
local A = {}

function A:testA()
   print("Function called that is defined in A.")
end

return A
```
##File component/Inherit/B.lua
```
local B = {}
B.__parent = "Inherit.A"

function B:testB()
   print("Function called that is defined in B.")
end

return B
```
B type components now have access to both testA and testB methods through inheritance.
