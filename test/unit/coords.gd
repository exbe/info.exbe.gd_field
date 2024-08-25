extends GutTest

func test_similar_point():
	# this test will pass because 1 does equal 1
	var dots :  Array[Vector2i] = [Vector2i(9,14),Vector2i(80,33)]
	var field = Field.builder().size(Vector2i(1,4)).set_points(dots).build()
	var coords = field.get_dot_of(Vector2(-0.41, -0.86))
	assert_eq(coords.size(),1)
	assert_eq(Vector2i(9,14),coords[0])
	
func test_some_point():
	# this test will pass because 1 does equal 1
	var dots :  Array[Vector2i] = [Vector2i(9,14),Vector2i(80,33)]
	var field = Field.builder().size(Vector2i(1,4)).set_points(dots).build()
	var coords = field.get_dot_of(Vector2(-0.31, -0.76))
	assert_eq(coords.size(),1)
	assert_eq(Vector2i(9,14),coords[0])	
