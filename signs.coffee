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



	$('.selectpicker').selectpicker();
	$('select').each ->
		 $(@).change ->
			 console.log @