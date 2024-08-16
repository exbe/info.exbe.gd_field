class_name Field

extends PlaneMesh

static var it_version = 0
static var min_size := Vector2i.ONE
static var resolution_step := Vector2i.ONE
static var default_resolution = 100
static var field_resolution := Vector2i(default_resolution,default_resolution)
static var center_dot  := field_resolution / 2
static var single_center_dot : Array[Vector2i] = [center_dot]

enum FIELD_FILL_METHOD {CUSTOM, REPEAT_ALL}

var points : Array[Vector2i] = []

var fill_method: Callable

var size_integer: Vector2i
var start_point: Vector2

func _init(field_size: Vector2i):
	self.size_integer = field_size
	self.start_point = field_size * -0.5
	set_size(Vector2(field_size))

func get_dots_of(offset:Vector2i) -> Array[Vector2]:
	return self.fill_method.call(self, offset)
	
func check_field(offset:Vector2i) -> bool:
	return (offset >= Vector2i.ZERO) && (offset <= size_integer - min_size)
	
"""
Repeats https://github.com/godotengine/godot/blob/33c30b9e63a58b860cb2f36957c5e25cee34a627/scene/resources/3d/primitive_meshes.cpp#L1297-L1303
"""
func ofOrientation(dot: Vector2) -> Vector3:
	match(orientation):
		PlaneMesh.Orientation.FACE_X: return Vector3(0.0, dot.y, dot.x)
		PlaneMesh.Orientation.FACE_Y: return Vector3(-dot.x, 0.0, -dot.y)
		PlaneMesh.Orientation.FACE_Z: return Vector3(-dot.x, dot.y, 0.0)
		_: printerr("Unexpected value for PlaneMesh.Orientation=", orientation,". Fallback to zero"); return Vector3.ZERO	

func dot(dot: Vector2) -> Vector3:
	return ofOrientation(dot) + center_offset

"""
Transforms a grid point to array of filler points.
"""
class FillMethods:
	
	static func same(it:Field,coord:Vector2i) -> Array[Vector2]: 
		var result: Array[Vector2] = []
		if not it.check_field(coord): return result
		result.assign(it.points.map(func(point): 
			var fl_x = point.x as float/it.field_resolution.x as float 
			var fl_y = point.y as float/it.field_resolution.y as float
			return it.start_point + Vector2(coord) + Vector2(fl_x, fl_y)
			))
		return result 
		
	static func slidingWithPointsPerUnit(points_per_unit: int) -> Callable:
		return 	 func(it:Field,coord:Vector2i) -> Array[Vector2]: 
			var result: Array[Vector2] = []
			if not it.check_field(coord): return result
			var groups_total = it.points.size() / points_per_unit
			
			var current_group = coord.x % groups_total + coord.y
			var effective_group = current_group % groups_total
			
			var idx_start = effective_group * points_per_unit
			var slice =  it.points.slice(idx_start, idx_start + points_per_unit)

			result.assign( slice.map(func(point): 
				var fl_x = point.x as float/it.field_resolution.x as float 
				var fl_y = point.y as float/it.field_resolution.y as float
				return it.start_point + Vector2(coord) + Vector2(fl_x, fl_y)
				))
			return result

class Builder:
	
	var effective_size := Vector2i.ONE
	var points : Array[Vector2i] = []
	var method : FIELD_FILL_METHOD = FIELD_FILL_METHOD.REPEAT_ALL
	var custom_fill_method: Callable 
	var isOffsetAligned = false

	func size(field_size: Vector2i) -> Builder:
		effective_size = Field.min_size if field_size < Vector2i.ONE else field_size
		if effective_size != field_size:
			printerr("Using Field=", effective_size, " instead of provided ", field_size,". Field size should be more one")
		return self
		
	func set_points(new_points:Array[Vector2i]) -> Builder:
		points = new_points
		return self

	func set_fill_method(fill_method:Callable) -> Builder:
		method = FIELD_FILL_METHOD.CUSTOM
		custom_fill_method = fill_method
		return self	
		
	func align_offset_with_origin() -> Builder:
		isOffsetAligned = true
		return self 

	func build() -> Field:
		var field = Field.new(effective_size)
		field.points = Field.single_center_dot if points.size() < 1 else points
		if method == FIELD_FILL_METHOD.REPEAT_ALL:
			field.fill_method = FillMethods.same
			
		if method == FIELD_FILL_METHOD.CUSTOM:
			field.fill_method = custom_fill_method
				
		if field.fill_method == null:
			printerr("Field method is missing")	

		if isOffsetAligned:
			printerr("Not implemented (allign offset with origin at Vector2i.ZERO")

		return field


static func builder() -> Builder:
	return Builder.new()
