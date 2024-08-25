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
enum FIELD_POSITIONS_METHOD {CUSTOM, CLOSEST}

var points : Array[Vector2i] = []

var fill_method: Callable
var position_method: Callable

var size_integer: Vector2i
var start_point: Vector2

func _init(field_size: Vector2i):
	self.size_integer = field_size
	self.start_point = field_size * -0.5
	set_size(Vector2(field_size))

func get_dots_of(offset:Vector2i) -> Array[Vector2]:
	return self.fill_method.call(self, offset)

func get_dot_of(offset:Vector2) -> Array[Vector2i]:
	return self.position_method.call(self, offset)


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
		var current_group_func = func(_it:Field, coord:Vector2i,groups_total:int)->int:
			return coord.x % groups_total + coord.y
		return callablePointsPerUnit(points_per_unit, current_group_func)

	static func slidingPriorityX(points_per_unit: int) -> Callable:
		var current_group_func = func(it:Field, coord:Vector2i,groups_total:int)->int:
			return coord.x * it.size_integer.y + coord.y
		return callablePointsPerUnit(points_per_unit, current_group_func)

	static func slidingPriorityY(points_per_unit: int) -> Callable:
		var current_group_func = func(it:Field, coord:Vector2i,groups_total:int)->int:
			return coord.y * it.size_integer.x + coord.x
		return callablePointsPerUnit(points_per_unit, current_group_func)

			
	static func callablePointsPerUnit(points_per_unit: int, current_group_func: Callable) -> Callable:
		return 	 func(it:Field,coord:Vector2i) -> Array[Vector2]: 
			var result: Array[Vector2] = []
			if not it.check_field(coord): return result
			var groups_total = it.points.size() / points_per_unit

			var effective_group = current_group_func.call(it,coord,groups_total) % groups_total
			
			var idx_start = effective_group * points_per_unit
			var slice =  it.points.slice(idx_start, idx_start + points_per_unit)

			result.assign( slice.map(func(point): 
				var fl_x = point.x as float/it.field_resolution.x as float 
				var fl_y = point.y as float/it.field_resolution.y as float
				return it.start_point + Vector2(coord) + Vector2(fl_x, fl_y)
				))
			return result

class PositionMethods:
	static func closest(it: Field, coord: Vector2) -> Array[Vector2i]:
		var result: Array[Vector2i] = []
		var point_point = coord - it.start_point
		var point33 = Vector2i(point_point)
		if not it.check_field(point33): return result
		var xxx = fposmod(point_point.x,1)  * it.field_resolution.x
		var yyy = fposmod(point_point.y,1)  * it.field_resolution.y
		var candidate = Vector2i(xxx,yyy)
		var dot = it.points.map(func(point):
					# no need to create Vector2 in godot4.3 to call distance_squared_to
					var distance: float = Vector2(point).distance_squared_to(candidate)
					return VectorAndDistance.new(point,distance)
					).reduce(func(vctr:VectorAndDistance, accc: VectorAndDistance):
					return vctr if vctr.distance < accc.distance else 	accc
					)
		result.push_front(dot.vector)
		return result


class VectorAndDistance:
	var vector: Vector2i
	var distance: float
	func _init(vector: Vector2i, distance: float):
		self.vector = vector
		self.distance = distance

class Builder:
	
	var effective_size := Vector2i.ONE
	var points : Array[Vector2i] = []
	var method : FIELD_FILL_METHOD = FIELD_FILL_METHOD.REPEAT_ALL
	var position_method: FIELD_POSITIONS_METHOD = FIELD_POSITIONS_METHOD.CLOSEST
	var custom_fill_method: Callable
	var custom_position_method: Callable
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

	func set_position_method(position_method: Callable) -> Builder:
		self.position_method = FIELD_POSITIONS_METHOD.CUSTOM
		custom_position_method = position_method
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

		if position_method == FIELD_POSITIONS_METHOD.CLOSEST:
			field.position_method = PositionMethods.closest

		if position_method == FIELD_POSITIONS_METHOD.CUSTOM:
			field.fill_method = custom_position_method

		if field.fill_method == null:
			printerr("Field fill method is missing")

		if field.position_method == null:
			printerr("Field position method is missing")

		if isOffsetAligned:
			printerr("Not implemented (allign offset with origin at Vector2i.ZERO")

		return field


static func builder() -> Builder:
	return Builder.new()
