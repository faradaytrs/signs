#Created by Andrey Izotov faradaytrs@gmail.com

signs = angular.module('Signs', ['file-model'])
#first one is default
settings =
	pixel_size: 8
	magic_coeff: 0.75
	step_coeff: 0.9
	canvasHeight: 500
	canvasWidth: 555
	maxWidth: 690
	maxHeight: 450
	maxRadius: 450
	minSize: 10
	shapes: [
		"rektangulär"
		"rundad rektangulär"
		"rund"
	]
	holes_radius: 9
	min_hole_padd: 5
	holes_interface: [
		"Inga"
		"2 hål"
		"4 hål"
	]
	textStyles: [
		"Normal"
		"Kursiv"
		"Fet"
	]
	hole_rect: {
		width: 10
		height: 5
	}
	materials: [
		"Plast"
		"Metall"
	]
	alignment: [
		"Vänster"
		"Mitten"
		"Höger"
	]
	themes: [
		{
			name: "svart / vit"
			bgColor: "white"
			textColor: "black"
		}
		{
			name: "gul / svart"
			bgColor: "black"
			textColor: "yellow"
		}
		{
			name: "grön / vit"
			bgColor: "white"
			textColor: "green"
		}
		{
			name: "röd / vit"
			bgColor: "white"
			textColor: "red"
		}
		{
			name: "brun / vit"
			bgColor: "white"
			textColor: "#964B00"
		}
		{
			name: "blå / vit"
			bgColor: "white"
			textColor: "blue"
		}
		{
			name: "vit / svart"
			bgColor: "black"
			textColor: "white"
		}
	]
	theme_metal: {
		bgColor: "grey"
		textColor: "black"
	}
	fonts: [
		"Arial"
		"Times New Roman"
		"Arial Narrow"
		"Calibri"
	]
	maxLinesOfText: 8
	margin: 15 # in pixels
	radius: 5 # in pixels
	borderWidth: 1.5 #in pixels
	rules:
		indent: 25
		width: 3
	debug: false

hypotenuse = (a, b = a) ->
	Math.sqrt(a * a + b * b)

copyObj = (obj) ->
	JSON.parse(JSON.stringify(obj))

#here we can setup default settings
modelTemplate =
	name: "Skylt"
	shape: settings.shapes[0]
	holes: {
		"Top": false
		"Top left corner": false
		"Top right corner": false
		"Middle left": false
		"Middle right": false
		"Bottom left corner": false
		"Bottom right corner": false
	}
	holes_rect: false
	fonts: settings.fonts[0]
	material: settings.materials[0]
	theme: settings.themes[0]
	order: 1
	texts: [
		{
			text: "Din text här"
			size: 5
			align: "Mitten"
			style: "Normal"
		}
	]
	size: {
		width: 30 #in mms
		height: 10 #ingored if auto is true
		radius: 10 #for circle
		autoRadius: true #for circle
		autoHeight: true
		autoWidth: true
	}
	font: "Arial"

getModels = ->
	if localStorage.models?
		JSON.parse(localStorage['models'])
	else
		models = []
		models.push copyObj(modelTemplate)
		models

saveModels = (models) ->
	localStorage.models = JSON.stringify(models)
	console.log models

roundRect = (x, y, width, height, radius, borderWidth, fillColor, strokeColor) ->
	new Konva.Shape
		drawFunc: (ctx) ->
			ctx.beginPath()
			ctx.moveTo(x + radius, y)
			ctx.lineTo(x + width - radius, y)
			ctx.quadraticCurveTo(x + width, y, x + width, y + radius)
			ctx.lineTo(x + width, y + height - radius)
			ctx.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
			ctx.lineTo(x + radius, y + height)
			ctx.quadraticCurveTo(x, y + height, x, y + height - radius)
			ctx.lineTo(x, y + radius)
			ctx.quadraticCurveTo(x, y, x + radius, y)
			ctx.closePath()
			ctx.fillStrokeShape(@)
		fill: fillColor || 'black'
		stroke: strokeColor || 'black'
		strokeWidth: borderWidth
		shadowOffsetX : 3
		shadowOffsetY : 2
		shadowBlur : 15

rectKonva = (x, y, width, height, borderWidth, fillColor, strokeColor) ->
	new Konva.Rect
		x: x
		y: y
		width: width
		height: height
		strokeWidth: 1
		fill: fillColor || 'black'
		stroke: strokeColor || 'black'
		strokeWidth: borderWidth
		shadowOffsetX : 3
		shadowOffsetY : 2
		shadowBlur : 15

simpleRect = (x, y, width, height) ->
	new Konva.Rect
		x: x
		y: y
		width: width
		height: height
#		fill: 'white'
		stroke: 'black'
		strokeWidth: 1

whiteRect = (x, y, width, height) ->
	new Konva.Rect
		x: x
		y: y
		width: width
		height: height
		fill: 'white'
		stroke: 'black'
		strokeWidth: 1

simpleCircle = (x, y, radius) ->
	new Konva.Circle
		x: x,
		y: y,
		radius: radius || 6,
		fill: 'white',
		stroke: 'black',
		strokeWidth: 1

circleKonva = (x, y, radius, borderWidth, fillColor, strokeColor) ->
	new Konva.Circle
		x: x + radius,
		y: y + radius,
		radius: radius,
		fill: fillColor || 'white'
		stroke: strokeColor || 'black'
		strokeWidth: borderWidth
		shadowOffsetX: 3
		shadowOffsetY: 2
		shadowBlur: 15

renderLeftRule = (size) ->
	#left
	x = size.sign.x - settings.rules.indent
	new Konva.Shape
		drawFunc: (context) ->
			context.beginPath()
			context.moveTo(x, size.sign.y)
			context.lineTo(x, size.sign.y + size.sign.height)
			context.closePath()
			context.fillStrokeShape(@)
			context.fillText("#{size.sign.origin.height} mm", size.sign.x - 65, size.sign.y + size.sign.height / 2)
		stroke: 'black',
		strokeWidth: settings.rules.width
renderTopRule = (size) ->
	#top
	y = size.sign.y - settings.rules.indent
	new Konva.Shape
		drawFunc: (context) ->
			#line
			context.beginPath()
			context.moveTo(size.sign.x, y)
			context.lineTo(size.sign.x + size.sign.width, y)
			context.closePath()
			context.fillStrokeShape(@)
			context.fillText("#{size.sign.origin.width} mm", size.sign.x + size.sign.width / 2 - 10, y - 10)
		#size
		stroke: 'black',
		strokeWidth: settings.rules.width

translateAlign = (align) ->
	switch align
		when "Vänster" then "left"
		when "Mitten" then "center"
		when "Höger" then "right"
translateTextStyle = (style) ->
	switch style
		when "Normal" then "normal"
		when "Kursiv" then "italic"
		when "Fet" then "bold"

createText = (align, str, x, y, width, font, size, color, style = "Normal") ->
	textObj = new Konva.Text
		x: x
		y: y
		text: str
		fontSize: toPixel(size)
		fontFamily: font
		fontStyle: translateTextStyle(style)
		fill: color
		width: width
		wrap: 'none'
#		padding: 20
		align: translateAlign(align)

createText2 = (align, str, x, y, font, size, color, style = "Normal") ->
	textObj = new Konva.Text
		x: x
		y: y
		text: str
		fontSize: toPixel(size)
		fontFamily: font
		fontStyle: translateTextStyle(style)
		fill: color
#		padding: 20
		align: translateAlign(align)

simpleCreateText = (layer, model, obj) ->
	textObj = createText(obj.align, obj.text, 0, 0, 0,
		model.font, obj.size, model.theme.textColor)
	console.log(textObj.getTextHeight())
	layer.add textObj
	textObj

getSpace = (width, squareWidth) ->
	width / 2 - squareWidth / 2

getSizesTexts = (model, k = 1) ->
	sizes = []
	for text in model.texts
		textObj = createText2(text.align, text.text, 0, 0,
			model.font, text.size * k, model.theme.textColor, text.style)
		sizes.push {
			width : textObj.getTextWidth()
			height: textObj.getTextHeight()
		}
	sizes

# max size of font in mm
getMaxTextSize = (model) ->
	max = 0
	for text in model.texts
		if text.size > max then max = text.size
	max

getTextSize = (sizes) ->
	maxLen = 0
	sum = 0
	for size in sizes
		width = size.width
		if width > maxLen then maxLen = width
		sum += size.height
	{
		width: maxLen
		height: sum
	}

getTextWidth = (sizes) ->
	maxLen = 0
	for size in sizes
		if size.width > maxLen then maxLen = size.width
	maxLen

getTextHeight = (sizes) ->
	sum = 0
	for size in sizes
		sum += size.height
	sum

getSignSize = (textSize, padding) ->
	{
		width: textSize.width + padding.width()
		height: textSize.height + padding.height()
	}

getSignWidth = (size, padding) ->
	size + padding

getSignHeight = (size, padding) ->
	size + padding

toPixel = (mm) ->
	mm * settings.pixel_size

toMillimeters = (px) ->
	px / settings.pixel_size

getMax = (a, b) ->
	if (a > b) then a else b

getPadding = (model, textSize) ->
	padding = toPixel(textSize.maxTextSize) / 2
	h = model.holes
	is_left = h["Middle left"] || h["Top left corner"] || h["Bottom left corner"]
	is_right = h["Middle right"] || h["Top right corner"] || h["Bottom right corner"]
	{
		top: padding
		bottom: padding
		left:  if (is_left) then 2*padding else padding
		right: if (is_right) then 2*padding else padding
		width: () -> this.left + this.right
		height: () -> this.top + this.bottom
		hole: padding
		text: 0
	}

getRoundPadding = (model, textSize) ->
	padding = toPixel(textSize.maxTextSize) / 0.5
	h = model.holes
	is_left = h["Middle left"] || h["Top left corner"] || h["Bottom left corner"]
	is_right = h["Middle right"] || h["Top right corner"] || h["Bottom right corner"]
	padding_ = if is_left || is_right then 2 * padding else padding

	###if model.size.autoRadius && !signSize?
		radius = hypotenuse(textSize.height, textSize.width) / 2
		paddingX = radius - textSize.width / 2
		paddingY = radius - textSize.height / 2
	else
		paddingX = (signSize.width - textSize.width) / 2 - padding
		paddingY = (signSize.height - textSize.height) / 2 - padding###

	{
		indent: padding_
		text: 0
		hole: padding
	}

getBalancingCoefficient = (width, height, canvasWidth, canvasHeight) ->
	fatalWidth = width/canvasWidth
	fatalHeight = height/canvasHeight
	oneWeUse = if fatalHeight > fatalWidth then fatalHeight else fatalWidth
	if oneWeUse > settings.magic_coeff
		new_k = oneWeUse
		while new_k > settings.magic_coeff
			new_k = new_k *= settings.step_coeff
		new_k/oneWeUse
	else
		1

getHoles = (model, signBegin, signSize, padding, k) ->
	holes = {}
	holes.radius = k * settings.holes_radius
	padding = if (holes.radius * 2 < settings.min_hole_padd) then settings.min_hole_padd else holes.radius * 2

	top =     signBegin.y + padding
	bottom =  signBegin.y + signSize.height - padding
	middle =  signBegin.y + signSize.height / 2

	left =    signBegin.x + padding
	right =   signBegin.x + signSize.width - padding
	middle_ = signBegin.x + signSize.width / 2

	holes.coord = {
		"Top": {
			x: middle_
			y: top
		}
		"Top left corner": {
			x: left
			y: top
		},
		"Top right corner": {
			x: right
			y: top
		},
		"Middle left": {
			x: left
			y: middle
		},
		"Middle right": {
			x: right
			y: middle
		},
		"Bottom left corner": {
			x: left
			y: bottom
		},
		"Bottom right corner": {
			x: right
			y: bottom
		}
	}
	holes

checkSize = (width, height, radius = false) ->
	str = null;
	if (height < toPixel(settings.minSize)) then str = "Höjden på skylten är för liten"
	if (width < toPixel(settings.minSize)) then str = "Bredden på skylten är för liten"
	if (height > toPixel(settings.maxHeight)) then str = "Höjden på skylten är för stor"
	if (width > toPixel(settings.maxWidth)) then str = "Bredden på skylten är för stor"
	if radius
		if (radius < settings.minSize)  then str = "Diametern för skylten är för liten"
		if (radius > settings.maxHeight) then str = "Diametern för skylten är för stor"
	return str || false;

clearStage = (stage) ->
	stage.clear()
	layers = stage.getLayers().toArray()
	for layer in layers
		layer.destroy()
	return

onChange = (stage, model, errorCallback) ->
	console.clear()
	for text in model.texts
		if !text.size || text.size == ""
			clearStage(stage)
			return

	if (!model.size.autoHeight || !model.size.autoWidth || !model.size.autoRadius)
		if ((str = checkSize(model.size.width, model.size.height, model.size.radius)) != false)
			errorCallback(str)
			return

	sizes = getSizesTexts(model)
	textSize = getTextSize(sizes)
	textSize.maxTextSize = getMaxTextSize(model)

	if model.shape is 'rund'
		signSize = {}
		if (model.size.autoRadius)
			padding = getRoundPadding(model, textSize)
			signSize.width = getSignWidth(textSize.width, padding.indent) # в функцию getWidthSign для каждого model.shape
			signSize.height = getSignHeight(textSize.height, padding.indent)
			signSize.height = signSize.width = getMax(signSize.width, signSize.height)
		else
			signSize.width = signSize.height = toPixel(model.size.radius) # <- diameter
			padding = getRoundPadding(model, textSize)
			if (settings.debug)
				console.log(padding.indent)
			if (toPixel(model.size.radius) < textSize.width + padding.indent)
				errorCallback("För liten diameter")
				return
	else
		padding = getPadding(model, textSize)
		signSize = getSignSize(textSize, padding)

		if (!model.size.autoWidth)
			if (toPixel(model.size.width) < signSize.width)
				errorCallback("För liten bredd")
				return
			else
				signSize.width = toPixel(model.size.width)
				textSize.width = signSize.width - padding.width()

		if (!model.size.autoHeight)
			if (toPixel(model.size.height) < signSize.height)
				errorCallback("För liten höjd")
				return
			else
				signSize.height = toPixel(model.size.height)
				textSize.height = signSize.height - padding.height()
				padding.text = (textSize.height - getTextHeight(sizes)) / model.texts.length

	if ((str = checkSize(signSize.width, signSize.height)) != false)
		errorCallback(str)
		return

	k = getBalancingCoefficient(signSize.width, signSize.height, settings.canvasWidth, settings.canvasHeight)

	if model.shape is 'rund'
		sizes = getSizesTexts(model, k)
		textSize = getTextSize(sizes)
		textSize.maxTextSize = getMaxTextSize(model) * k
		padding = getRoundPadding(model, textSize)

		signSize.width *= k
		signSize.height *= k
		padding.indent *= k
	else
		if (model.size.autoWidth && model.size.autoHeight)
			sizes = getSizesTexts(model, k)
			textSize = getTextSize(sizes)
			textSize.maxTextSize = getMaxTextSize(model) * k
			padding = getPadding(model, textSize)
			signSize = getSignSize(textSize, padding)

		else
			signSize.width *= k
			signSize.height *= k
			textSize.width *= k
			textSize.height *= k
			padding.top *= k
			padding.bottom *= k
			padding.left *= k
			padding.right *= k
			padding.text *= k

	signBegin = {}
	signBegin.x = getSpace(settings.canvasWidth, signSize.width)
	signBegin.y = getSpace(settings.canvasHeight, signSize.height)

	textBegin = {}
	if model.shape is 'rund'
		textBegin.x = getSpace(settings.canvasWidth, textSize.width)
		textBegin.y = getSpace(settings.canvasHeight, textSize.height)
	else
		textBegin.x = signBegin.x + padding.left
		textBegin.y = signBegin.y + (padding.top + padding.text / 2)
	#padding.text *= k

	#model.size.width = Math.round(signSize.width / settings.PIXEL_SIZE)
	#model.size.height = Math.round(signSize.height / settings.PIXEL_SIZE)

	size = {
		k: k #to delete
		sign:
			x: signBegin.x
			y: signBegin.y
			width: signSize.width
			height: signSize.height
			origin:
				width: Math.round(signSize.width / settings.pixel_size / k)
				height: Math.round(signSize.height / settings.pixel_size / k)
		text:
			x: textBegin.x
			y: textBegin.y
			width: textSize.width
			height: textSize.height
			font: sizes
		padding: padding #to delete
		holes: getHoles(model, signBegin, signSize, padding.hole, k)
	}

	console.log "k: #{size.k}"
	console.log("text")
	console.log("x: #{size.text.x};	y: #{size.text.y}")
	console.log("width: #{size.text.width}; height: #{size.text.height}")
	console.log("sign")
	console.log("x: #{size.sign.x};	y: #{size.sign.y}")
	console.log("width: #{size.sign.width}; height: #{size.sign.height}")

	errorCallback(null)
	reRender(stage, model, size)

reRender = (stage, model, size) ->
	clearStage(stage)

	color = {}
	if (model.material is 'Plast')
		color.bgColor = model.theme.bgColor
		color.textColor = model.theme.textColor
	else
		color.bgColor = settings.theme_metal.bgColor
		color.textColor = settings.theme_metal.textColor

	shapeLayer = new Konva.Layer()
	textLayer = new Konva.Layer()
	stage.add shapeLayer
	stage.add textLayer

	for text, id in model.texts
		textKonva = createText(text.align, text.text, size.text.x, size.text.y, size.text.width,
			model.font, size.k * text.size, color.textColor, text.style)

		if (settings.debug)
			rect = simpleRect(size.text.x, size.text.y, size.text.width, textKonva.getHeight())
		size.text.y += textKonva.getHeight() + size.padding.text

		if (settings.debug)
			textLayer.add(rect)
		textLayer.add(textKonva)
	#	forEnd

	switch model.shape
		when 'rektangulär'
			shape = rectKonva(size.sign.x, size.sign.y, size.sign.width, size.sign.height,
			  settings.borderWidth, color.bgColor, color.textColor)
		when 'rund'
			shape = circleKonva(size.sign.x, size.sign.y, size.sign.width / 2,
			  settings.borderWidth, color.bgColor, color.textColor)
			if (settings.debug)
				debug = simpleRect(size.sign.x, size.sign.y, size.sign.width, size.sign.height)
		else
			shape = roundRect(size.sign.x, size.sign.y, size.sign.width, size.sign.height,
			  settings.radius, settings.borderWidth, color.bgColor, color.textColor)

	shapeLayer.add(shape)
	if (settings.debug && model.shape is 'Rund')
		shapeLayer.add(debug)

	for hole, isShow of model.holes
		if (isShow)
			if (model.holes_rect)
				hole = whiteRect(size.holes.coord[hole].x, size.holes.coord[hole].y,
				  settings.hole_rect.width, settings.hole_rect.height)
			else
				hole = simpleCircle(size.holes.coord[hole].x, size.holes.coord[hole].y, size.holes.radius)
			shapeLayer.add(hole)

	leftRule = renderLeftRule(size)
	topRule = renderTopRule(size)
	shapeLayer.add(leftRule)
	shapeLayer.add(topRule)

	shapeLayer.draw()
	textLayer.draw()

#controllers
signs.controller 'shapesController', ($scope, $rootScope) ->
	$scope.shapes = settings.shapes
	$scope.showShapes = (material) ->
		material == "Plast"
	$scope.setShape = (shape) ->
		$scope.model.shape = shape
		if shape == "rund"
			$rootScope.setHole("Inga")
signs.controller 'holesController', ($scope, $rootScope) ->
	$scope.holes = settings.holes_interface
	$scope.showHoles = (material) ->
		material == "Plast"
	$scope.getHoleName = ->
		if $scope.model.holes["Middle left"] and $scope.model.holes["Middle right"]
			return "2 hål"
		else if $scope.model.holes["Top left corner"] and $scope.model.holes["Top right corner"] and $scope.model.holes["Bottom left corner"] and $scope.model.holes["Top right corner"]
			return "4 hål"
		"Inga"
	$scope.setHole = (hole) ->
		for key, value of $scope.model.holes
			$scope.model.holes[key] = false
		switch hole
			when '2 hål'
				$scope.model.holes["Middle left"] = true
				$scope.model.holes["Middle right"] = true
			when '4 hål'
				$scope.model.holes["Top left corner"] = true
				$scope.model.holes["Top right corner"] = true
				$scope.model.holes["Bottom left corner"] = true
				$scope.model.holes["Bottom right corner"] = true
	$rootScope.setHole = $scope.setHole
	$scope.showHole = (hole) ->
		if hole == "4 hål" and $scope.model.shape == "rund"
			return false
		true


signs.controller 'fontsController', ($scope) ->
	$scope.fonts = settings.fonts
	$scope.showFonts = (material) ->
		material == "Plast" or material == "Metall"
signs.controller 'materialsController', ($scope) ->
	$scope.materials = settings.materials
	$scope.changeMaterial = (material) ->
		unless $scope.model.material is material
			unless JSON.stringify($scope.model) == JSON.stringify(modelTemplate)
				swal
					title: "Är du säker?"
					text: "Du kommer att förlora alla nuvarande inställningar om du byter material!"
					type: "warning"
					showCancelButton: true
					confirmButtonColor: "green"
					confirmButtonText: "Ja"
					cancelButtonText: "Ångra"
					closeOnConfirm: yes
				, ->
					$scope.$apply ->
						model = copyObj(modelTemplate)
						$scope.models[$scope.current] = model
						$scope.updateCurrentModel($scope.current)
						$scope.model.material = material
			else
				$scope.model.material = material

signs.controller 'sizeController', ($scope) ->
	$scope.showSize = ->
		$scope.model.material == "Plast" or $scope.model.material == "Metall"
	$scope.showRadius = ->
		$scope.model.shape == "rund"
	$scope.showWidthHeight = ->
		$scope.model.shape == "rektangulär" or $scope.model.shape == "rundad rektangulär"
	$scope.showRadiusError = () ->
		$scope.sizeError == "För liten diameter"
	$scope.showWidthError = () ->
		$scope.sizeError == "För liten bredd"
	$scope.showHeightError = () ->
		$scope.sizeError == "För liten höjd"

	#something here
signs.controller 'themesController', ($scope) ->
	$scope.themes = settings.themes
	$scope.showThemes = (material) ->
		material == "Plast"
signs.controller 'textController', ($scope) ->
	$scope.alignment = settings.alignment
	$scope.textStyles = settings.textStyles
	$scope.isDisabled = -> $scope.model.texts.length >= settings.maxLinesOfText
	$scope.addText = () ->
		unless $scope.isDisabled()
			$scope.model.texts.push copyObj(modelTemplate.texts[0])
	$scope.removeText = ($index) ->
		$scope.model.texts.splice($index, 1)
	$scope.setAlign = (align, index) ->
		$scope.model.texts[index].align = align
	$scope.setStyle = (style, index) ->
		$scope.model.texts[index].style = style

	$scope.increaseSize = (index, size = 1) ->
		$scope.model.texts[index].size = parseInt($scope.model.texts[index].size) + size
	$scope.decreaseSize = (index, size = 1) ->
		$scope.increaseSize(index, -size)

signs.controller 'modelsController', ($scope) ->
	$scope.minSize = settings.minSize
	$scope.maxHeight = settings.maxHeight
	$scope.maxWidth = settings.maxWidth
	$scope.maxRadius = settings.maxRadius
	$scope.errorCallback = (error) ->
		if error?
			console.warn error
		$scope.sizeError = error
		switch error
			when "För liten höjd"
				1
			when "För liten bredd"
				2
			when "För liten diameter"
				3
	$scope.removeSign = ($index) ->
		$scope.models.splice($index, 1)
		unless $scope.models.length == 0
			$scope.updateCurrentModel($scope.models.length - 1)
		else
			$scope.newSign()
		return
	$scope.copySign = ($index) ->
		$scope.models.push(copyObj($scope.models[$index]))
	$scope.init = ->
		$scope.stage = new Konva.Stage
			container: 'preview'
			width: settings.canvasWidth
			height: settings.canvasHeight

	$scope.file = {}
	$scope.$watch 'file', (newVal) ->
		reader = new FileReader()
		reader.readAsBinaryString(newVal)
		reader.onload = (event) ->
			contents = event.target.result
			if newVal.name.match(/^.*(xls)$/)
				sheets = XLS.read(contents, {type: "binary"})
				sheet = sheets.Sheets[sheets.SheetNames[0]]
				json_sheet = XLS.utils.sheet_to_json(sheet, {range: 3, header: 1})
			else if newVal.name.match(/^.*(xlsx)$/)
				sheets = XLSX.read(contents, {type: "binary"})
				sheet = sheets.Sheets[sheets.SheetNames[0]]
				json_sheet = XLSX.utils.sheet_to_json(sheet, {range: 3, header: 1})
			else
				return
			console.log json_sheet
			for row, index in json_sheet
				if index == 0 then break
				if row[1]? # Rad 1
					console.log row
					model = copyObj(modelTemplate)
					if row[0]? # Antal
						model.order = row[0]
					if row[1]? # Rad 1
						model.texts[0].text = row[1]
						model.texts[9].size = row[9]
					if row[2]? # Rad 2
						model.texts[1].text = row[2]
						model.texts[10].size = row[10]
					if row[3]? # Rad 3
						model.texts[2].text = row[3]
						model.texts[11].size = row[11]
					if row[4]? # Rad 4
						model.texts[3].text = row[4]
						model.texts[12].size = row[12]
					if row[5]? # Rad 5
						model.texts[4].text = row[5]
						model.texts[13].size = row[13]
					if row[6]? # Rad 6
						model.texts[5].text = row[6]
						model.texts[14].size = row[14]
					if row[7]? # Rad 7
						model.texts[6].text = row[7]
						model.texts[15].size = row[15]
					if row[8]? # Rad 8
						model.texts[7].text = row[8]
						model.texts[16].size = row[16]
					if row[18]? #width
						model.size.width = row[18]
						model.size.autoWidth = false
					if row[19]? #height
						model.size.height = row[19]
						model.size.autoHeight = false
					# todo make theme import
					if row[20]? #tape
						model.tape = true
					if row[21]?
						if row[21] == "2-hål"
							model.holes["Middle left"] = true
							model.holes["Middle right"] = true
						if row[21] == "4-hål"
							model.holes["Top left corner"] = true
							model.holes["Top right corner"] = true
							model.holes["Bottom right corner"] = true
							model.holes["Bottom left corner"] = true
					console.log model


			#sheet to model object
			#push to models

			reader.onerror = (event) ->
				console.error("Problems reading file, code:  " + event.target.error.code)



	$scope.triggerImport = ->
		$('#file').trigger('click')
		return

	$scope.onChange = onChange
	$scope.models = getModels()
	$scope.current = 0 #by default

	$scope.newSign = ->
		$scope.models.push copyObj(modelTemplate)
		$scope.updateCurrentModel($scope.models.length - 1)
	$scope.model = $scope.models[$scope.current]
	$scope.updateCurrentModel = (index) ->
		$scope.current = index
		$scope.model = $scope.models[$scope.current]
		#$scope.reRender($scope.model, settings.canvasHeight, settings.canvasWidth)
	$scope.$watch 'models', ->
		saveModels($scope.models)
	, true
	$scope.$watch 'model', ->
		# todo rework rerender system to improve performance
		$scope.onChange($scope.stage, $scope.model, $scope.errorCallback)

	, true
	$scope.calcPrice = (model = $scope.model) ->
		20
	$scope.summary = (models = $scope.models) ->
		summary = {}
		summary.price = 0
		summary.order = 0
		for model in models
			summary.price += $scope.calcPrice(model) * model.order
			summary.order += model.order
		summary
