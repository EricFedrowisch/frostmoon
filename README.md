# Frostmoon
## Loading components
To load a component, put it in the "components" directory in top level directory where frostmoon.lua resides. The default can be overriden by changing the "component_dir" variable in frostmoon.lua. Frostmoon will go through all the folders and subfolders in components, loading all .lua files it finds as components.
## Writing your own components
Components are easy to write as long as they do the following:
- Components MUST return a table as the final thing they do. This is because frostmoon is treating them like modules and using require on them.
- Components should expect to have a component_type that is their folder path below the components directory, seperated by "." notation. This is also what frostmoon will use as the table key to look them up for instantiation. So, if you make a class file myClass.lua and store it in components/gui/myClass.lua, it will be of type "gui.myClass". The reuslts of loading the class will be stored in frostmoon.components["gui.myClass"].
- If you want your objects to have default variables, make sure to assign them as a table with key _defaults in the return table of your class. This is where frostmoon will look for them when instantiating objects of your class.     
