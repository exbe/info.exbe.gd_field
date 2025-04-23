New component checklist:
 - [ ] update structured data, if applicable
 - [ ] upodate LICENSE, specifically **licence_year** and **auhtors**
 - [ ] the checklist is removed before initial commit


:scissors: tear line below
----

# :microscope: Incubating: gd_field
Class to represent constrained plane mesh for [Godot](https://godotengine.org/) engine.

This implementation remains **incubating** untill 100 different uses are confirmed. 

## Overview
Field is a [PlaneMesh](https://docs.godotengine.org/en/stable/classes/class_planemesh.html) with additional local points per square unit (a.k.a field unit) and resolution (default is 100).
Local points (or dots) are treated according to FIELD_FILL_STRATEGY with simply repeating all points per every square unit as a default behavior.

The size of the plane is restricted to integer values and it must be equal or more than Vector2i.ONE.

The plane inherits *PlaneMesh* behavior and exposes additional methods to perform Vector2i -> Vector2 and Vector3 conversion.

Builder `Field.builder()` is recommended way to initialize Field for most users.

This project does not have Godot Project (*.tscn or project.godot) as it supposed to be used as a library/script.

## Usage

 
The class can be used directly, but it is recommended to start with `Field.builder()` as it provides some safenet to build *Field* object:
```
Field.builder().size(Vector2i(1,3)).build()
```   
Above would create 1 x 3 unit plane with a single (center) point defined implicitly.

The client can provide own points:
```
Field.builder().size(Vector2i(1,3)).set_points([Vector2i(20,30),Vector2i(70,30)]).build()
```

There are few built-in fill methods `Field.FillMethods`:

 * Field.FillMethods.same(it:Field,coord:Vector2i) - (default), returns all points for all positions, use it as lamda 
 * Field.FillMethods.slidingWithPointsPerUnit(points_per_unit: int) - returns lamda function with pre-defined count of points per cell (group). Group of points changes with position indefenetily. 
 * Field.FillMethods.slidingPriorityX(points_per_unit: int) - returns lamda with pre-defined group of points, but uses X-axis size to fill cells
 * Field.FillMethods.slidingPriorityY(points_per_unit: int) - similar as before, but uses Y-axis
 * Field.FillMethods.callablePointsPerUnit(points_per_unit: int, current_group_func: Callable) - (advance) returns lamda, current_group_func is function to resolve current group based of position and current field 

Function `Field.FillMethods.same` example:
```
 Field.builder() \
	.set_points(dots) \
	.set_fill_method(Field.FillMethods.same) \
	.build()
```


slidingPriorityX or any lamda-generating method:
```
 Field.builder() \
	.set_points(dots) \
	.set_fill_method(Field.FillMethods.slidingPriorityX(points_per_unit)) \
	.build()
```

## Testing

 - Run new godot project, such that this root folder would be under "res://" path.
 - Follow plugin setup instructions for [Gut](https://github.com/bitwes/Gut) 
 - Load test configuration (gut_builder.conf) 
 - run Test 

`test` has executable samples and tests (see [GUT](https://github.com/bitwes/Gut) for details)



