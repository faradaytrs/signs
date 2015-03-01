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
			ctx.fillStrokeShape(this);
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

createText = (align, str, x, y, width, font, size, color) ->
	textObj = new Konva.Text
		x: x
		y: y
		text: str
		fontSize: size * settings.PIXEL_SIZE
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
		fontSize: size * settings.PIXEL_SIZE
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
	left = h["Middle left"] || h["Top left corner"] || h["Bottom left corner"]
	right = h["Middle right"] || h["Top right corner"] || h["Bottom right corner"]
	{
		u: 15
		b: 15
		l: if left then 45 else 15
		r: if right then 45 else 15
		w: () -> this.l + this.r
		h: () -> this.u + this.b
		text: 0
	}

resizeWidthPadding = (padding, text_w)->
	text_w /= 100
	padding.l += text_w
	padding.r += text_w
	padding

createSizeObj = ->
	{
		w: 0
		h: 0
	}

getBalancingCoefficient = (width, height, canvasWidth, canvasHeight) ->
	fatalWidth = width/canvasWidth
	fatalHeight = height/canvasHeight
	oneWeUse = if fatalHeight > fatalWidth then fatalHeight else fatalWidth
	if oneWeUse > 0.8
		new_k = oneWeUse
		while new_k > 0.8
			new_k = new_k *= 0.9
		new_k/oneWeUse
		# console.log "K: #{1}"
	else
		1

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
	textSize.w = getTextWidth(sizes)
	textSize.h = getTextHeight(sizes, padding.text)

	padding = resizeWidthPadding(padding, textSize.w)
	signSize = {}
	signSize.w = getSignWidth(textSize.w, padding.w()) # в функцию getWidthSign для каждого model.shape
	signSize.h = getSignHeight(textSize.h, padding.h())

	k = getBalancingCoefficient(signSize.w, signSize.h, settings.canvasWidth, settings.canvasHeight)

	signBeginX = getSpace(settings.canvasWidth, k * signSize.w)
	signBeginY = getSpace(settings.canvasHeight, k * signSize.h)

	textBeginX = signBeginX + k * padding.l
	textBeginY = signBeginY + k * padding.b

	#model.size.width = Math.round(signSize.w / settings.PIXEL_SIZE)
	#model.size.height = Math.round(signSize.h / settings.PIXEL_SIZE)

	size =
		k: k #to delete
		sign: signSize
		text: textSize
		padding: padding #to delete probably
		indent:
			sign:
				x: signBeginX
				y: signBeginY
			text:
				x: textBeginX
				y: textBeginY

	console.log("padding.x: #{size.padding.w()}; padding.y: #{size.padding.h()}")
	console.log("sign x: #{size.indent.sign.x};	y: #{size.indent.sign.y}")
	console.log("text x: #{size.indent.text.x};	y: #{size.indent.sign.y}")
	console.log("width: #{size.sign.w}; height: #{size.sign.h}")

	reRender(stage, model, size)

reRender = (stage, model, size) ->
	clearStage(stage)

	shapeLayer = new Konva.Layer()
	textLayer = new Konva.Layer()
	stage.add shapeLayer
	stage.add textLayer

	for text, id in model.texts
		textKonva = createText(text.align, text.text, size.indent.text.x, size.indent.sign.y, size.k * size.text.w + 1,
			model.font, size.k * text.size, model.theme.textColor)
		textLayer.add(textKonva)

		rect = simpleRect(size.indent.text.x, size.indent.text.y, size.k * size.text.w + 1, textKonva.getHeight())
		textLayer.add(rect)

		size.indent.text.y += textKonva.getHeight() + size.k * size.padding.text
	# forEnd

	rectKonva = roundRect(size.indent.sign.x, size.indent.text.y, size.sign.w, size.sign.h,
		settings.radius, settings.borderWidth, model.theme.bgColor, model.theme.textColor)

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