$ ->
	#settings
	settings =
		forms:
			round: "link image"
			square: "link image"
		holes: [
			"Top left corner"
			"Top right corner"
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

	buildSelects = ->
		selects = $('.selects')

		#select for forms
		$('<h4>Forms:</h4>').appendTo selects
		for form of settings.forms
			forms = $('<div></div>').addClass("radio")
			label = $("<label></label>")
			input = $("<input type='radio'>")
			input.addClass(form)
			input.attr('value', form)
			input.attr('name', "forms")
			input.appendTo label
			span = $("<span>#{form}</span>")
			span.appendTo label
			label.appendTo forms
			forms.appendTo selects

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
		configuration =
			forms: $('#forms').val()

		#todo get information from selects

	render = ->
		conf = getConfiguration()
		field = $('preview')

	buildSelects()

	$('select').selectpicker()
	$('select').each ->
		 $(@).change ->
			 render()