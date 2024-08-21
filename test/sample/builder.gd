extends GutTest

static var EXACTLY_ONE = 1
static var HALF_NEGATIVE_POINT = Vector2(-0.5, -0.5)
static var ALLOWED_ERROR_MARGIN = 0.0001

func test_default_builder():
	var field = Field.builder().build()
	assert_is(field, PlaneMesh, "Field expected to extend Plane")
	assert_is(field, Field, "Expected object of named type Field")
	assert_eq(field.points.size(),EXACTLY_ONE, "At least one point is expected by default")
	assert_eq(field.fill_method, Field.FillMethods.same, "All field cell or units have same points") 
	assert_eq(field.size, Vector2.ONE, "Expected single field unit(cell)") 
	assert_eq(field.size_integer, Vector2i.ONE, "Expected single field unit(cell) as an integer") 
	assert_true(field.check_field(Vector2i.ZERO),"Single cell exist at the origin")
	assert_eq(field.start_point,HALF_NEGATIVE_POINT,"Starting point with default offset and orientation")
	assert_eq(field.get_dots_of(Vector2i.ZERO),[Vector2.ZERO],"Dot with default offset and orientation is origin")
	assert_eq(field.get_dots_of(Vector2i.ONE),[],"No dots for a another cell")
	assert_eq(field.center_offset,Vector3.ZERO,"No offset by default")	
	assert_eq(field.orientation,PlaneMesh.Orientation.FACE_Y,"Plane faces positive Y-axis")	

func test_points():
	var dots :  Array[Vector2i] = [Vector2i(9,14),Vector2i(80,33)]
	var field = Field.builder().set_points(dots).build()
	var actual :  Array[Vector2] = field.get_dots_of(Vector2i.ZERO)
	var expected :  Array[Vector2] = [Vector2(-0.41, -0.36), Vector2(0.3, -0.17)]
	assert_vector2_arrays(actual, expected, ALLOWED_ERROR_MARGIN)


func assert_vector2_arrays(actual: Array[Vector2], expected: Array[Vector2], error_margin: float ):
	assert_eq(actual.size(), expected.size(),"Array size should be equal")
	for i in actual.size():
		var one : Vector2 = actual[i]
		var another : Vector2 = expected[i]
		assert_almost_eq(one.x, another.x, error_margin, "X coord is expected to be within range")
		assert_almost_eq(one.y, another.y, error_margin, "Y coord is expected to be within range")
