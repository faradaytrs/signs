#Created by Andrey Izotov faradaytrs@gmail.com

#initialization
$ ->
	$('select').selectpicker()

signs = angular.module('Signs', ['file-model'])
#first one is default
settings =
	PIXEL_SIZE: 8
	canvasHeight: 500
	canvasWidth: 555
	shapes: [
		"rectangle"
		"round"
		"rounded rectangle"
	]
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
	alignment: [
		"Left"
		"Center"
		"Right"
	]
	themes: [
		{
			name: "black / white"
			bgColor: "white"
			textColor: "black"
		}
		{
			name: "black / yellow"
			bgColor: "yellow"
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
	fonts: [
		"Arial"
		"Times New Roman"
		"Arial Narrow"
		"Calibri"
	]
	maxLinesOfText: 4
	margin: 15 # in pixels
	radius: 5 # in pixels
	borderWidth: 1.5 #in pixels
	rules:
		indent: 25
		width: 3

copyObj = (obj) ->
	JSON.parse(JSON.stringify(obj))

array2Object = (array) ->
	object = {}
	for i in array
		object[i] = false
	object[0] = true
	object

#here we can setup default settings
modelTemplate =
	name: "New Sign"
	shape: settings.shapes[0]
	holes: array2Object(settings.holes)
	fonts: settings.fonts[0]
	material: settings.materials[0]
	theme: {
		name: "black / yellow"
		bgColor: "yellow"
		textColor: "black"
	}
	order: 0
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
		autoHeight: true
		autoWidth: true
	}
	font: "Arial"

models = []

getModels = ->
	models.push copyObj(modelTemplate)
	models

saveModels = (models) ->
	models

roundRect = (x, y, width, height, radius, borderWidth, fillColor, strokeColor) ->
	new Konva.Shape
		drawFunc: (ctx) ->
			ctx.beginPath();
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
			ctx.fillStrokeShape(@);
		fill: fillColor || 'black'
		stroke: strokeColor || 'black'
		strokeWidth: borderWidth
		shadowOffsetX : 3
		shadowOffsetY : 2
		shadowBlur : 15

simpleRect = (x, y, width, height) ->
	new Konva.Rect
		x: x,
		y: y,
		width: width,
		height: height,
#		fill: 'white'
		stroke: 'black'
		strokeWidth: 1

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
	width/2-squareWidth/2

getSizesTexts = (model) ->
	sizes = []
	for text in model.texts
		textObj = createText2(text.align, text.text, 0, 0,
			model.font, text.size, model.theme.textColor)
#		console.log("#{textObj.getTextWidth()} #{textObj.getTextHeight()}")
		sizes.push {
			width : textObj.getTextWidth()
			height: textObj.getTextHeight()
		}
	sizes

getMaxTextSize = (model) ->
	max = 0
	for text in model.texts
		if text.size > max then max = text.size
	max

getTextWidth = (sizes) ->
	maxLen = 0
	for size in sizes
		if size.width > maxLen then maxLen = size.width
	maxLen

getTextHeight = (sizes, padding) ->
	sum = 0
	for size in sizes
		sum += size.height
	sum + padding * (sizes.length-1)

getSignWidth = (size, padding) ->
	size + padding

getSignHeight = (size, padding) ->
	size + padding

getPadding = (model) ->
	h = model.holes
	is_left = h["Middle left"] || h["Top left corner"] || h["Bottom left corner"]
	is_right = h["Middle right"] || h["Top right corner"] || h["Bottom right corner"]
	{
		top: 0
		bottom: 0
		left: if is_left then 45 else 0
		right: if	is_right then 45 else 0
		width: () -> this.left + this.right
		height: () -> this.top + this.bottom
		text: 0
	}

balancePadding = (padding, textSize) ->
	textSize = toPixel(textSize) / 2
	padding.top += textSize
	padding.bottom += textSize
	padding.left += textSize
	padding.right += textSize
	padding

getBalancingCoefficient = (width, height, canvasWidth, canvasHeight) ->
	fatalWidth = width/canvasWidth
	fatalHeight = height/canvasHeight
	oneWeUse = if fatalHeight > fatalWidth then fatalHeight else fatalWidth
	if oneWeUse > 0.75
		new_k = oneWeUse
		while new_k > 0.75
			new_k = new_k *= 0.9
		new_k/oneWeUse
	else
		1

toPixel = (mm) ->
	mm * settings.PIXEL_SIZE

clearStage = (stage) ->
	stage.clear()
	layers = stage.getLayers().toArray()
	for layer in layers
		layer.destroy()
	return

onChange = (stage, model) ->
	padding = getPadding(model)

	sizes = getSizesTexts(model)
	textSize = {}
	textSize.width = getTextWidth(sizes)
	textSize.height = getTextHeight(sizes, padding.text)

	maxTextSize = getMaxTextSize(model)
	balancePadding(padding, maxTextSize)

	signSize = {}
	signSize.width = getSignWidth(textSize.width, padding.width()) # в функцию getWidthSign для каждого model.shape
	signSize.height = getSignHeight(textSize.height, padding.height())

	if (!model.size.autoWidth)
		if (toPixel(model.size.width) < signSize.width)
			console.warn("very small width")
			return
		else
			signSize.width = toPixel(model.size.width)
			textSize.width = signSize.width - padding.width()

	if (!model.size.autoHeight)
		if (toPixel(model.size.height) < signSize.height)
			console.warn("very small height")
			return
		else
			signSize.height = toPixel( model.size.height)
			textSize.width = signSize.width - padding.width()

	k = getBalancingCoefficient(signSize.width, signSize.height, settings.canvasWidth, settings.canvasHeight)

	signBegin = {}
	signBegin.x = getSpace(settings.canvasWidth, k * signSize.width)
	signBegin.y = getSpace(settings.canvasHeight, k * signSize.height)

	textBegin = {}
	textBegin.x = signBegin.x + k * padding.left
	textBegin.y = signBegin.y + k * padding.top

	#model.size.width = Math.round(signSize.width / settings.PIXEL_SIZE)
	#model.size.height = Math.round(signSize.height / settings.PIXEL_SIZE)

	size = {
		k: k #to delete
		sign:
			x: signBegin.x
			y: signBegin.y
			width: k * signSize.width
			height: k * signSize.height
			origin:
				width: Math.round(signSize.width / settings.PIXEL_SIZE)
				height: Math.round(signSize.height / settings.PIXEL_SIZE)
		text:
			x: textBegin.x
			y: textBegin.y
			width: k * textSize.width
			height: k * textSize.height
			font: sizes
		padding: padding #to delete probably
	}

	console.log("padding w #{size.padding.width()} h #{size.padding.height()}")
	console.log("text")
	console.log("x: #{size.text.x};	y: #{size.text.y}")
	console.log("width: #{size.text.width}; height: #{size.text.height}")
	console.log("sign")
	console.log("x: #{size.sign.x};	y: #{size.sign.y}")
	console.log("width: #{size.sign.width}; height: #{size.sign.height}")

	reRender(stage, model, size)

reRender = (stage, model, size) ->
	clearStage(stage)

	shapeLayer = new Konva.Layer()
	textLayer = new Konva.Layer()
	stage.add shapeLayer
	stage.add textLayer

	for text, id in model.texts
		textKonva = createText(text.align, text.text,
			size.text.x, size.text.y, size.text.width + 1,
			model.font, size.k * text.size, model.theme.textColor)

		rect = simpleRect(
			size.text.x, size.text.y, size.text.width + 1, textKonva.getHeight())
		size.text.y += textKonva.getHeight() + size.padding.text

		textLayer.add(textKonva)
		textLayer.add(rect)
	# forEnd

	rectKonva = roundRect(size.sign.x, size.sign.y, size.sign.width, size.sign.height,
		settings.radius, settings.borderWidth, model.theme.bgColor, model.theme.textColor)
	leftRule = renderLeftRule(size)
	topRule = renderTopRule(size)
	shapeLayer.add(leftRule)
	shapeLayer.add(topRule)
	shapeLayer.add(rectKonva)

	shapeLayer.draw()
	textLayer.draw()

#controllers
signs.controller 'shapesController', ($scope) ->
	$scope.shapes = settings.shapes
signs.controller 'holesController', ($scope) ->
	$scope.holes = settings.holes
signs.controller 'fontsController', ($scope) ->
	$scope.fonts = settings.fonts
signs.controller 'materialsController', ($scope) ->
	$scope.materials = settings.materials
signs.controller 'colorController', ($scope) ->
	$scope.color = settings.color
signs.controller 'sizeController', ($scope) ->
	#something here
signs.controller 'fontController', ($scope) ->
	$scope.fonts = settings.fonts
	#something here
signs.controller 'themesController', ($scope) ->
	$scope.themes = settings.themes
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
			sheets = XLS.read(contents, {type:"binary"});
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
	$scope.current = 0; #by default

	$scope.new = -> $scope.models.push copyObj(modelTemplate)
	$scope.model = $scope.models[$scope.current]
	$scope.updateCurrentModel = (index) ->
		$scope.current = index
		$scope.model = $scope.models[$scope.current]
		#$scope.reRender($scope.model, settings.canvasHeight, settings.canvasWidth)

	$scope.$watch 'model', ->
		# todo rework rerender system to improve performance
		$scope.onChange($scope.stage, $scope.model)
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