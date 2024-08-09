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

func _init(field_size: Vector2i):
	set_size(Vector2(field_size))

func get_dots_of(offset:Vector2i) -> Array[Vector3]:
	return self.fill_method.call(self, offset)

class Builder:
	
	var effective_size := Vector2i.ONE
	var points : Array[Vector2i] = []
	var method : FIELD_FILL_METHOD = FIELD_FILL_METHOD.REPEAT_ALL
	var custom_fill_method: Callable 

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

	func build() -> Field:
		var field = Field.new(effective_size)
		field.points = Field.single_center_dot if points.size() < 1 else points
		if method == FIELD_FILL_METHOD.REPEAT_ALL:
			field.fill_method = func(it:Field,_coord:Vector2i) -> Array[Vector3]: 
					var result: Array[Vector3] = []
					result.assign(it.points.map(func(point): return Vector3(point.x, 0, point.y)))
					return result
			
		if method == FIELD_FILL_METHOD.CUSTOM:
			field.fill_method = custom_fill_method
				
		if field.fill_method == null:
			printerr("Field method is missing")	
		return field


static func builder() -> Builder:
	return Builder.new()
