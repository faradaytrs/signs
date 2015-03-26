#Created by Andrey Izotov faradaytrs@gmail.com

signs = angular.module('Signs', ['file-model'])
#first one is default
settings =
	pixel_size: 8
	magic_coeff: 0.75
	step_coeff: 0.9
	canvasHeight: 500
	canvasWidth: 555
	shapes: [
		"rectangle"
		"rounded rectangle"
		"round"
	]
	holes_radius: 9
	min_hole_padd: 5
	holes: [
		"Top"
		"Top left corner"
		"Top right corner"
		"Middle left"
		"Middle right"
		"Bottom left corner"
		"Bottom right corner"
	]
	hole_rect: {
		width: 10
		height: 5
	}
	materials: [
		"Plastic",
		"Metal"
	]
	alignment: [
		"Left"
		"Center"
		"Right"
	]
	themes: [
		{
			name: "black / yellow"
			bgColor: "yellow"
			textColor: "black"
		}
		{
			name: "white / black"
			bgColor: "#000"
			textColor: "#FFF"
		}
		{
			name: "black / white"
			bgColor: "white"
			textColor: "black"
		}
		{
			name: "black / red"
			bgColor: "red"
			textColor: "black"
		}
		{
			name: "white / red"
			bgColor: "red"
			textColor: "white"
		}
		{
			name: "red / white"
			bgColor: "white"
			textColor: "red"
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
		"PT Sans Narrow"
	]
	maxLinesOfText: 4
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
	name: "Sign"
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
			text: "Your text here"
			size: 5
			align: "Center"
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
			context.fillText("#{size.sign.origin.height} mm", size.sign.x - 60, size.sign.y + size.sign.height / 2)
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

createText = (align, str, x, y, width, font, size, color) ->
	textObj = new Konva.Text
		x: x
		y: y
		text: str
		fontSize: toPixel(size)
		fontFamily: font
		fill: color
		width: width
#		padding: 20
		align: align.toLowerCase()

createText2 = (align, str, x, y, font, size, color) ->
	textObj = new Konva.Text
		x: x
		y: y
		text: str
		fontSize: toPixel(size)
		fontFamily: font
		fill: color
#		padding: 20
		align: align.toLowerCase()

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
			model.font, text.size * k, model.theme.textColor)
#		console.log("#{textObj.getTextWidth()} #{textObj.getTextHeight()}")
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
		if size.width > maxLen then maxLen = size.width
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

getSignWidth = (size, padding) ->
	size + padding

getSignHeight = (size, padding) ->
	size + padding

toPixel = (mm) ->
	mm * settings.pixel_size

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
	#return 1
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

clearStage = (stage) ->
	stage.clear()
	layers = stage.getLayers().toArray()
	for layer in layers
		layer.destroy()
	return

onChange = (stage, model, errorCallback) ->
	console.clear()
	sizes = getSizesTexts(model)

	textSize = getTextSize(sizes)
	textSize.maxTextSize = getMaxTextSize(model)

	signSize = {}

	if model.shape is 'round'
		if (model.size.autoRadius)
			padding = getRoundPadding(model, textSize)
			signSize.width = getSignWidth(textSize.width, padding.indent) # в функцию getWidthSign для каждого model.shape
			signSize.height = getSignHeight(textSize.height, padding.indent)
			signSize.height = signSize.width = getMax(signSize.width, signSize.height)
		else
			signSize.width = signSize.height = toPixel(model.size.radius) # <- diameter
			padding = getRoundPadding(model, textSize)
			if (settings.debug)
				console.log(toPixel(model.size.radius))
				console.log(textSize.width + padding.indent)
			if (toPixel(model.size.radius) < textSize.width + padding.indent)
				errorCallback("too small radius")
				return
	else
		padding = getPadding(model, textSize)

		signSize.width = getSignWidth(textSize.width, padding.width()) # в функцию getWidthSign для каждого model.shape
		signSize.height = getSignHeight(textSize.height, padding.height())

		if (!model.size.autoWidth)
			if (toPixel(model.size.width) < signSize.width)
				errorCallback("too small width")
				return
			else
				signSize.width = toPixel(model.size.width)
				textSize.width = signSize.width - padding.width()

		if (!model.size.autoHeight)
			if (toPixel(model.size.height) < signSize.height)
				errorCallback("too small height")
				return
			else
				signSize.height = toPixel(model.size.height)
				textSize.height = signSize.height - padding.height()
				padding.text = (textSize.height - getTextHeight(sizes)) / model.texts.length

	k = getBalancingCoefficient(signSize.width, signSize.height, settings.canvasWidth, settings.canvasHeight)

	sizes = getSizesTexts(model, k)
	textSize = getTextSize(sizes)

	signSize.width = getSignWidth(textSize.width, padding.width()) # в функцию getWidthSign для каждого model.shape
	signSize.height = getSignHeight(textSize.height, padding.height())

	signSize.width *= k
	signSize.height *= k
	textSize.width *= k
	textSize.height *= k

	signBegin = {}
	signBegin.x = getSpace(settings.canvasWidth, signSize.width)
	signBegin.y = getSpace(settings.canvasHeight, signSize.height)

	textBegin = {}
	if model.shape is 'round'
		textBegin.x = getSpace(settings.canvasWidth, textSize.width)
		textBegin.y = getSpace(settings.canvasHeight, textSize.height)
	else
		textBegin.x = signBegin.x + k * padding.left
		textBegin.y = signBegin.y + k * (padding.top + padding.text / 2)
		padding.text *= k

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
	if (model.material is 'Plastic')
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
			model.font, size.k * text.size, color.textColor)

		if (settings.debug)
			rect = simpleRect(size.text.x, size.text.y, size.text.width, textKonva.getHeight())
		size.text.y += textKonva.getHeight() + size.padding.text

		if (settings.debug)
			textLayer.add(rect)
		textLayer.add(textKonva)
	#	forEnd

	switch model.shape
		when 'rectangle'
			shape = rectKonva(size.sign.x, size.sign.y, size.sign.width, size.sign.height,
			  settings.borderWidth, color.bgColor, color.textColor)
		when 'round'
			shape = circleKonva(size.sign.x, size.sign.y, size.sign.width / 2,
			  settings.borderWidth, color.bgColor, color.textColor)
			if (settings.debug)
				debug = simpleRect(size.sign.x, size.sign.y, size.sign.width, size.sign.height)
		else
			shape = roundRect(size.sign.x, size.sign.y, size.sign.width, size.sign.height,
			  settings.radius, settings.borderWidth, color.bgColor, color.textColor)

	shapeLayer.add(shape)
	if (settings.debug && model.shape is 'round')
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
signs.controller 'shapesController', ($scope) ->
	$scope.shapes = settings.shapes
	$scope.showShapes = (material) ->
		material == "Plastic"
signs.controller 'holesController', ($scope) ->
	$scope.holes = settings.holes
	$scope.showHoles = (material) ->
		material == "Plastic"
signs.controller 'fontsController', ($scope) ->
	$scope.fonts = settings.fonts
	$scope.showFonts = (material) ->
		material == "Plastic" or material == "Metal"
signs.controller 'materialsController', ($scope) ->
	$scope.materials = settings.materials
	$scope.changeMaterial = (material) ->
		unless $scope.model.material is material
			unless JSON.stringify($scope.model) == JSON.stringify(modelTemplate)
				swal
					title: "Are you sure?"
					text: "You lose all current settings if you switch material!"
					type: "warning"
					showCancelButton: true
					confirmButtonColor: "green"
					confirmButtonText: "Okay!"
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
		$scope.model.material == "Plastic" or $scope.model.material == "Metal"
	$scope.showRadius = ->
		$scope.model.shape == "round"
	$scope.showWidthHeight = ->
		$scope.model.shape == "rectangle" or $scope.model.shape == "rounded rectangle"
	$scope.showRadiusError = () ->
		$scope.sizeError == "too small radius"
	$scope.showWidthError = () ->
		$scope.sizeError == "too small width"
	$scope.showHeightError = () ->
		$scope.sizeError == "too small height"

	#something here
signs.controller 'themesController', ($scope) ->
	$scope.themes = settings.themes
	$scope.showThemes = (material) ->
		material == "Plastic"
signs.controller 'textController', ($scope) ->
	$scope.alignment = settings.alignment
	$scope.isDisabled = -> $scope.model.texts.length >= settings.maxLinesOfText
	$scope.addText = () ->
		unless $scope.isDisabled()
			$scope.model.texts.push copyObj(modelTemplate.texts[0])
	$scope.removeText = ($index) ->
		$scope.model.texts.splice($index, 1)
	$scope.setAlign = (align, index) ->
		$scope.model.texts[index].align = align
	$scope.increaseSize = (index, size = 1) ->
		$scope.model.texts[index].size += size
	$scope.decreaseSize = (index, size = 1) ->
		$scope.increaseSize(index, -size)

signs.controller 'modelsController', ($scope) ->
	$scope.errorCallback = (error) ->
		if error?
			console.warn error
		$scope.sizeError = error
		switch error
			when "too small height"
				1
			when "too small width"
				2
			when "too small radius"
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
		reader.onload = (event) ->
			contents = event.target.result
			sheets = XLS.read(contents, {type: "binary"})
			sheet = sheets.Sheets[sheets.SheetNames[0]]
			console.log sheet
			#sheet to model object
			#push to models

		reader.onerror = (event) ->
			console.error("Problems reading file, code:  " + event.target.error.code)

	#reader.readAsBinaryString(newVal)

	$scope.triggerImport = ->
		$('#file').trigger('click')

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
		model.order * 20
	$scope.summary = (models = $scope.models) ->
		summary = {}
		summary.price = 0
		summary.order = 0
		for model in models
			summary.price += $scope.calcPrice(model)
			summary.order += model.order
		summary
