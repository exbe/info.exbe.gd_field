extends GutTest

static var EXACTLY_ONE = 1
static var HALF_NEGATIVE_POINT = Vector2(-0.5, -0.5)

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
	

