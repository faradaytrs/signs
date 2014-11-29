$ ->
	#settings
	settings =
		shapes:
			round: "link image"
			square: "link image"
		holes: [
			"Top left corner"
			"Top right corner"
			"Middle left"
			"Middle right"
			"Bottom left corner"
			"Bottom right corner"
		]
		fonts: [
			"Times New Roman",
			"Arial"
		]
		materials: [
			"Steel",
			"Mystic material"
		]
		color: "#ffffff"

	buildSelects = ->
		selects = $('.selects')

		#background color
		$('<h4>Background color:</h4>').appendTo selects
		bgColor = $("<input type='text' value=\"#{settings.color}\" name=\"bgcolor\" class='color form-control'>")
		bgColor.appendTo selects

		#select for forms
		$('<h4>Shapes:</h4>').appendTo selects
		for shape of settings.shapes
			shapes = $('<div></div>').addClass("radio")
			label = $("<label></label>")
			input = $("<input type='radio'>")
			input.addClass(shape)
			input.attr('value', shape)
			input.attr('name', "shapes")
			input.appendTo label
			span = $("<span>#{shape}</span>")
			span.appendTo label
			label.appendTo shapes
			shapes.appendTo selects

		#holes
		$('<h4>Holes:</h4>').appendTo selects
		for hole in settings.holes
			holes = $('<div></div>').addClass("checkbox")
			label = $("<label></label>")
			input = $("<input type='checkbox'>")
			input.addClass(hole)
			input.attr('value', hole)
			input.attr('name', "holes")
			input.appendTo label
			span = $("<span>#{hole}</span>")
			span.appendTo label
			label.appendTo holes
			holes.appendTo selects

		#select for forms
		$('<h4>Materials:</h4>').appendTo selects
		for material in settings.materials
			materials = $('<div></div>').addClass("radio")
			label = $("<label></label>")
			input = $("<input type='radio'>")
			input.addClass(material)
			input.attr('value', material)
			input.attr('name', "materials")
			input.appendTo label
			span = $("<span>#{material}</span>")
			span.appendTo label
			label.appendTo materials
			materials.appendTo selects

	getConfiguration = ->
		#getting shape
		shape = $('input[name=shapes]:checked').val()

		#getting holes
		holes = []
		$('input[name=holes]:checked').each ->
			holes.push(@.value)

		#getting material
		material = $('input[name=materials]:checked').val()

		#getting color
		color = $('input[name=bgcolor]').val()

		configuration =
			shape: shape
			holes: holes
			material: material
			bgcolor: color

		console.log configuration

	render = ->
		conf = getConfiguration()
		field = $('preview')

	buildSelects()
	$(".color").pickAColor()

	$('input').each ->
		@.onclick = render
		@.onchange = render
