$ ->

	#settings
	settings =
		fonts: [
			"Times New Roman",
			"Arial"
		]
		materials: [
			"Steel",
			"Mystic material"
		]

	getConfiguration = ->
		#todo get information from selects

	render = ->
		field = $('preview')

	$('.selectpicker').selectpicker()
	$('select').each ->
		 $(@).change ->
			 render()