New component checklist:
 - [x] replace **name_it** in README
 - [x] two-sentence desription of the component purpose in the current state
 - [ ] update structured data, if applicable
 - [ ] upodate LICENSE, specifically **licence_year** and **auhtors**
 - [ ] assign repository `tags` in github, if applicable  
 - [ ] the checklist is removed before initial commit


:scissors: tear line below
----

# :microscope: Incubating: gd_field
Class to represent plane mesh with provided points (X,Y) associtated with it for [Godot](https://godotengine.org/) engine.

## Overview
Field is a [PlaneMesh](https://docs.godotengine.org/en/stable/classes/class_planemesh.html) with additional local points per square unit and resolution (default is 100).
Local points are treated according to FIELD_FILL_STRATEGY with simply repeating all points per every square unit as a default behavior.

## Usage

This code expects you to know what you are doing...
 
The class can be used directly, but it is recommended to start with `Field.builder()` as it provides some safenet to build *Field* object:
```
Field.builder().size(Vector2i(1,3)).build()
```   
Above would create 1 x 3 unit plane with a single (center) point defined implicitly.

The client can provide own points:
```
Field.builder().size(Vector2i(1,3)).set_points([Vector2i(20,30),Vector2i(70,30)]).build()
```






