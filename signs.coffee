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
		forms = $('<select></select>')
		forms.attr('id', 'forms');
		option = $('<option selected disabled>Forms</option>')
		option.appendTo forms
		for form of settings.forms
			option = $("<option>#{form}</option>")
			option.appendTo forms
		forms.appendTo selects

		#holes select
		holes = $('<select multiple></select>')
		holes.attr('id', 'holes');
		option = $('<option disabled>Holes</option>')
		option.appendTo holes
		for hole in settings.holes
			option = $("<option>#{hole}</option>")
			option.appendTo holes
		holes.appendTo selects

		#materials select
		materials = $('<select></select>')
		materials.attr('id', 'materials');
		option = $('<option selected disabled>Materials</option>')
		for hole in settings.materials
			option = $("<option>#{hole}</option>")
			option.appendTo materials
		materials.appendTo selects


	getConfiguration = ->
		#todo get information from selects

	render = ->
		conf = getConfiguration()
		field = $('preview')

	buildSelects()

	$('select').selectpicker()
	$('select').each ->
		 $(@).change ->
			 render()