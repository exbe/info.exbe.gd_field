extends GutTest
var params_spec = ParameterFactory.named_parameters(
	['dots', 'size', 'dot', 'expectedDot','message'], 
	[   # values
		[[Vector2i(9,14),Vector2i(80,33)], Vector2i(1,4),Vector2(-0.41, -0.86),Vector2i(9,14),"Exact dot should return it"],
		[[Vector2i(9,14),Vector2i(80,33)], Vector2i(1,4),Vector2(-0.31, -0.76),Vector2i(9,14),"Close dot should return dot"]
	])


func test_similar_point2(params = use_parameters(params_spec)):
	# this test will pass because 1 does equal 1
	var dots :  Array[Vector2i] = []
	dots.assign(params.dots)
	var field = Field.builder().size(params.size).set_points(dots).build()
	var coords = field.get_dot_of(params.dot)
	assert_eq(coords.size(),1)
	assert_eq(params.expectedDot,coords[0], params.message)
	
