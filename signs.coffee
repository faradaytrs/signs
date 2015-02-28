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


reRender = (stage, model) ->
	clearStage(stage)

	shapeLayer = new Konva.Layer()
	textLayer = new Konva.Layer()
	stage.add shapeLayer
	stage.add textLayer

	padding = getPadding(model)
	textSize = createSizeObj()
	signSize = createSizeObj()

	sizes = getSizesTexts(model)
	textSize.w = getTextWidth(sizes)
	textSize.h = getTextHeight(sizes, padding.text)

	padding = resizeWidthPadding(padding, textSize.w)

	signSize.w = getSignWidth(textSize.w, padding.w()) # в функцию getWidthSign для каждого model.shape
	signSize.h = getSignHeight(textSize.h, padding.h())

	k = getBalancingCoefficient(signSize.w, signSize.h, settings.canvasWidth, settings.canvasHeight)

	signBeginX = getSpace(settings.canvasWidth,  k * signSize.w)
	signBeginY = getSpace(settings.canvasHeight, k * signSize.h)

	textBeginX = signBeginX + k * padding.l
	textBeginY = signBeginY + k * padding.b

	console.log("padding.x: #{padding.w()}; padding.y: #{padding.h()}")
	console.log("sign x: #{signBeginX};	y: #{signBeginY}")
	console.log("text x: #{textBeginX};	y: #{textBeginY}")
	console.log("width: #{signSize.w}; height: #{signSize.h}")

	for text, id in model.texts
		textKonva = createText(text.align, text.text, textBeginX, textBeginY, k * textSize.w + 1,
			model.font, k * text.size, model.theme.textColor)
		textLayer.add(textKonva)

		rect = simpleRect(textBeginX, textBeginY, k * textSize.w + 1, textKonva.getHeight())
		textLayer.add(rect)

		textBeginY += textKonva.getHeight() + k * padding.text
	# forEnd

	rectKonva = roundRect(signBeginX, signBeginY, k * signSize.w, k * signSize.h,
		k * settings.radius, settings.borderWidth, model.theme.bgColor, model.theme.textColor)
	shapeLayer.add(rectKonva)

	shapeLayer.draw()
	textLayer.draw()

	# Запихиваем размеры знака в модель
	model.size.width = Math.round(signSize.w / settings.PIXEL_SIZE)
	model.size.height = Math.round(signSize.h / settings.PIXEL_SIZE)

reRender_ = (stage, model) ->

	stage.clear()

	width = stage.width()
	height = stage.height()

	#render shape

	if model.shape == "rectangle"

		shapeLayer = new Konva.Layer()

		stage.add shapeLayer

		textLayer = new Konva.Layer()

		textSizes = []

		top = 15 + rectStartHeight

		for text, index in model.texts

			# этот цикл используется только для определения реальных размеров текста
			text = renderText(text.align, text.text, rectStartWidth, rectStartWidth, top, model.font, text.size, model.theme.textColor)
			# top += text.size().height
			textSizes.push text.size()

		getTextWidth = (sizes) ->
			# todo отступы добавить, слева и справа, добавить этот пункт в настройки (размер отступов)
			max = 0
			for i in textSizes
				max = if (i.width > max) then i.width else max
			max
		getTextHeight = (sizes) ->
			# todo учитывать отступы между строками, над строкой под, здесь и везде
			summ = 0
			for i in textSizes
				summ += i.height
			summ

		signWidth = getTextWidth(textSizes)
		signHeight = getTextHeight(textSizes)

		getBalancingCoefficient = (width, height, canvasWidth, canvasHeight) ->
			fatalWidth = width/canvasWidth
			fatalHeight = height/canvasHeight
			oneWeUse = if fatalHeight > fatalWidth then fatalHeight else fatalWidth
			if oneWeUse > 0.8
				0.8/oneWeUse
			else
				1

		k = getBalancingCoefficient(signWidth, signHeight, width, height)

		balancedSignHeight = signHeight * k
		balancedSignWidth = signWidth * k

		rectStartWidth = getSpace(width, signWidth)
		rectStartHeight = getSpace(height, signHeight)

		rectangle = roundRect(rectStartWidth, rectStartHeight, balancedSignWidth, balancedSignHeight, settings.radius, settings.borderWidth, model.theme.bgColor, model.theme.textColor)

		shapeLayer.add rectangle
		stage.add shapeLayer

		# todo тут нужно отрендерить текст реально, с значение ширины, чтобы работал alignment
		# todo отрендерить стрелки с указанием размеров (в конфа есть даже готовая форма для стрелок)
		# todo ну и отрефакторить всю функцию к чертовой матери

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

		reader.readAsBinaryString(newVal)

	$scope.triggerImport = ->
		$('#file').trigger('click')

	$scope.reRender = reRender
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
		$scope.reRender($scope.stage, $scope.model)
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