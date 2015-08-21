#Created by Andrey Izotov faradaytrs@gmail.com

window.numbersOnly = (e) ->
	unicode = if e.charCode then e.charCode else e.keyCode
	if unicode != 8
		if unicode < 48 or unicode > 57
			return false
	return
window.floatsOnly = (el, e) ->
	has_decimal = el.value.indexOf('.') >= 0
	unicode = if e.charCode then e.charCode else e.keyCode
	if unicode == 8
		return true
	if has_decimal
		if el.value.indexOf('.') < el.value.length - 1
			return false
	if unicode >= 48 and unicode <= 57
		return true
	if unicode == 46 and !has_decimal
		return true
	if unicode == 44 and !has_decimal
		el.value = el.value + '.'
		return false
	false

signs = angular.module('Signs', ['file-model', 'ngModal'])
#first one is default
settings =
	pixel_size: 8
	magic_coeff: 0.75
	step_coeff: 0.95
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
			name: "vit / svart"
			textColor: "black"
			bgColor: "white"
		}
		{
			name: "gul / svart"
			textColor: "black"
			bgColor: "yellow"
		}
		{
			name: "grön / vit"
			textColor: "white"
			bgColor: "green"
		}
		{
			name: "röd / vit"
			textColor: "white"
			bgColor: "red"
		}
		{
			name: "brun / vit"
			textColor: "white"
			bgColor: "#964B00"
		}
		{
			name: "blå / vit"
			textColor: "white"
			bgColor: "blue"
		}
		{
			name: "svart / vit"
			textColor: "white"
			bgColor: "black"
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
	debug: true
	roundTo: 5
	orderBasicPrice: 50

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
	tape: false
	comment: ""

getModels = ->
	if localStorage.models?
		JSON.parse(localStorage['models'])
	else
		models = []
		models.push copyObj(modelTemplate)
		models

saveModels = (models) ->
	localStorage.models = JSON.stringify(models)

roundRect = (x, y, width, height, radius, borderWidth, fillColor, strokeColor) ->
	new Konva.Shape
		sceneFunc: (ctx) ->
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
		shadowOffsetX: 3
		shadowOffsetY: 2
		shadowBlur: 15

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
		shadowOffsetX: 3
		shadowOffsetY: 2
		shadowBlur: 15

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
		sceneFunc: (context) ->
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
		sceneFunc: (context) ->
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
	new Konva.Text
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
	new Konva.Text
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

createTextWarning = (stage, str) ->
	sett = settings.errMsg

	layer = new Konva.Layer
	stage.add(layer)

	msg = new Konva.Text
		text: str
		fontSize: sett.size

	w = msg.getTextWidth()
	h = msg.getTextHeight()
	x = getSpace(settings.canvasWidth, w);
	y = getSpace(settings.canvasHeight, h);

	msg = createText2(null, str, x, y, null, 60, 'red')
	layer.add roundRect(x - sett.padd.x, y - sett.padd.y, w + 2 * sett.padd.x, h + 2 * sett.padd.y,
		settings.radius, 2, 'white', 'red');
	layer.add msg
	layer.draw

getSpace = (width, squareWidth) ->
	width / 2 - squareWidth / 2

###
#	Размер строк в пикселях
#   @param model in mm
#   @return размеры в пикселях
###
getRenderTextSizes = (model, k = 1) ->
	sizes = []
	for text in model.texts
		textObj = createText2(text.align, text.text, 0, 0,
			model.font, text.size * k, model.theme.textColor, text.style)
		sizes.push {
			width: textObj.getTextWidth()
			height: textObj.getTextHeight()
		}
	sizes

###
#   Максимальный размер шрифта в миллиметрах
#   max size of font in mm
#   @param texts массив объектов с размерами текста в мм
#   @return mm
###
getMaxTextSize = (texts) ->
	max = 0
	for text in texts
		if text.size > max then max = text.size
	toPixel(max)

###
#   Размер прямоугольника вокруг строк
#   @param sizes
#   @param texts
###
getRectForText = (sizes) ->
	width = 0
	height = 0
	for size in sizes
		if size.width > width then width = size.width
		height += size.height
	{
	width: width
	height: height
	}

###
#	Округление
###
roundTo = (x, to = 1) ->
	Math.ceil(x / to) * to;

###
#	Ширина текста в мм
###
getTextWidth = (sizes) ->
	maxLen = 0
	for size in sizes
		if size.width > maxLen then maxLen = size.width
	maxLen

###
#	Высота текста в мм
###
getTextHeight = (sizes) ->
	sum = 0
	for size in sizes
		sum += size.height
	sum

###
#	Размер знака в пикселях
###
getSignSize = (textSize, padding, round = false) ->
	if round
		{
		width: toPixel(roundTo(toMillimeters(textSize.width + padding.width()), settings.roundTo))
		height: toPixel(roundTo(toMillimeters(textSize.height + padding.height()), settings.roundTo))
		padding: padding
		}
	else
		{
		width: textSize.width + padding.width()
		height: textSize.height + padding.height()
		padding: padding
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

getPadding = (model, maxTextSize) ->
	padding = maxTextSize / 2
	h = model.holes
	is_left = h["Middle left"] || h["Top left corner"] || h["Bottom left corner"]
	is_right = h["Middle right"] || h["Top right corner"] || h["Bottom right corner"]
	{
	top: padding
	bottom: padding
	left: if (is_left) then padding + toPixel(2.5) else padding
	right: if (is_right) then padding + toPixel(2.5) else padding
	width: () -> this.left + this.right
	height: () -> this.top + this.bottom
	hole: padding
	text: 0
	}

getRoundPadding = (model, maxTextSize) ->
	padding = maxTextSize * 2
	h = model.holes
	is_left = h["Middle left"] || h["Top left corner"] || h["Bottom left corner"]
	is_right = h["Middle right"] || h["Top right corner"] || h["Bottom right corner"]
	padding_ = if is_left || is_right then padding + toPixel(2.5) else padding
	{
	indent: padding_
	text: 0
	hole: padding
	}

getBalancingCoefficient = (width, height, canvasWidth, canvasHeight) ->
	fatalWidth = width / canvasWidth
	fatalHeight = height / canvasHeight
	oneWeUse = if fatalHeight > fatalWidth then fatalHeight else fatalWidth
	if oneWeUse > settings.magic_coeff
		new_k = oneWeUse
		while new_k > settings.magic_coeff
			new_k *= settings.step_coeff
		(new_k / oneWeUse).toFixed(4)
	else
		1

getHoles = (model, signBegin, signSize, padding, k) ->
	holes = {}
	holes.radius = k * settings.holes_radius
	padding = if (holes.radius * 2 < settings.min_hole_padd) then settings.min_hole_padd else holes.radius * 2

	top = signBegin.y + padding
	bottom = signBegin.y + signSize.height - padding
	middle = signBegin.y + signSize.height / 2

	left = signBegin.x + padding
	right = signBegin.x + signSize.width - padding
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

###
# @params in mm
###
checkSize = (width, height, radius = false) ->
	str = null;
	if (height < settings.minSize) then str = "Höjden på skylten är för liten"
	if (width < settings.minSize) then str = "Bredden på skylten är för liten"
	if (height > settings.maxHeight) then str = "Höjden på skylten är för stor"
	if (width > settings.maxWidth) then str = "Bredden på skylten är för stor"
	if radius
		if (radius < settings.minSize) then str = "Diametern för skylten är för liten"
		if (radius > settings.maxHeight) then str = "Diametern för skylten är för stor"
	return str || false;

clearStage = (stage) ->
	stage.clear()
	stage.getLayers().toArray().forEach((la) -> la.destroy())
	return

onChange = (stage, model, errorCallback, updateSize) ->
	calcRound = (text, maxTextSize) ->
		sign = {}
		padding = getRoundPadding(model, maxTextSize)
		if (model.size.autoRadius)
			sign.width = getSignWidth(text.width, padding.indent) # в функцию getWidthSign для каждого model.shape
			sign.height = getSignHeight(text.height, padding.indent)
			sign.height = sign.width = getMax(sign.width, sign.height)
		else
# размер вручную
			sign.width = sign.height = toPixel(model.size.radius) # <- diameter
			if (settings.debug)
				console.log(padding.indent)
			return false if (toPixel(model.size.radius) < text.width + padding.indent)
		sign

	calcRect = (text, maxTextSize) ->
		padding = getPadding(model, maxTextSize)
		sign = getSignSize(text, padding)

		if (!model.size.autoWidth)
			return 'w' if (toPixel(model.size.width) < sign.width)

			sign.width = toPixel(model.size.width)
		#text.width = sign.width - padding.width()

		if (!model.size.autoHeight)
			return 'h' if (toPixel(model.size.height) < sign.height)

			sign.height = toPixel(model.size.height)
			text.height = sign.height - padding.height()
			padding.text = (text.height - getTextHeight(sizes)) / model.texts.length
		sign

	getSignBegin = (signSize) ->
		{
		x: getSpace(settings.canvasWidth, signSize.width)
		y: getSpace(settings.canvasHeight, signSize.height)
		}

	getTextBegin = (begin, text, padding) ->
		textBegin = {}
		if model.shape is 'rund'
			textBegin.x = getSpace(settings.canvasWidth, text.width)
			textBegin.y = getSpace(settings.canvasHeight, text.height)
		else
			textBegin.x = begin.x + padding.left
			textBegin.y = begin.y + (padding.top + padding.text / 2)
		textBegin

	console.clear()

	if (!model.size.width || !model.size.height)
		errorCallback('Недопустимый размер')
		clearStage(stage)
		return

	if (!model.size.autoHeight || !model.size.autoWidth || !model.size.autoRadius)
		if ((str = checkSize(model.size.width, model.size.height, model.size.radius)) != false)
			errorCallback(str)
			clearStage(stage)
			return

	sizes = getRenderTextSizes(model)
	textRect = getRectForText(sizes)

	if model.shape is 'rund'
		signSize = calcRound(textRect, getMaxTextSize(model.texts))
		if !signSize
			errorCallback("För liten diameter")
			clearStage(stage)
			return
	else
		signSize = calcRect(textRect, getMaxTextSize(model.texts))
		padding = signSize.padding
		if typeof signSize == 'string'
			errors =
				w: "För liten bredd"
				h: "För liten höjd"
			errorCallback(errors[signSize])
			clearStage(stage)
			return

	if ((str = checkSize(toMillimeters(signSize.width), toMillimeters(signSize.height))) != false)
		clearStage(stage)
		errorCallback(str)
		return

	k = getBalancingCoefficient(signSize.width, signSize.height, settings.canvasWidth, settings.canvasHeight)

	if model.shape is 'rund'
		sizes = getRenderTextSizes(model, k)
		textRect = getRectForText(sizes) # уже за zoom-ено
		padding = getRoundPadding(model, getMaxTextSize(model.texts) * k)
		signSize.width *= k
		signSize.height *= k
		padding.indent *= k
	else
		textRect.height *= k
		textRect.width *= k
		_signSize = signSize
		if (model.size.autoWidth || model.size.autoHeight)
			_padding = getPadding(model, getMaxTextSize(model.texts) * k)
			_signSize = getSignSize(textRect, _padding)
			console.warn("INITIAL: ", _signSize)
			_signSize.width = toPixel(roundTo(toMillimeters(_signSize.width) / k, settings.roundTo) * k)
			#_signSize.height = toPixel(roundTo(toMillimeters(_signSize.height) / k, settings.roundTo) * k)
			console.warn("ROUNDED: ", _signSize)

		if (model.size.autoWidth)
			signSize.width = _signSize.width
			textRect.width = _signSize.width - _padding.width()
			padding.left = _padding.left
			padding.right = _padding.right
		else
			signSize.width *= k
			padding.left *= k
			padding.right *= k
			textRect.width = signSize.width - padding.width()

		if (model.size.autoHeight)
			signSize.height = _signSize.height
			padding.top = _padding.top
			padding.bottom = _padding.bottom

			padding.text = _padding.text
		else
			signSize.height *= k
			padding.top *= k
			padding.bottom *= k
			padding.text *= k


	signBegin = getSignBegin(signSize)
	textBegin = getTextBegin(signBegin, textRect, padding)

	size = {
		k: k #to delete
		sign:
			x: signBegin.x
			y: signBegin.y
			width: signSize.width
			height: signSize.height
			origin:
				width: roundTo(toMillimeters(signSize.width) / k, 1)
				height: roundTo(toMillimeters(signSize.height) / k, 1)
		text:
			x: textBegin.x
			y: textBegin.y
			width: textRect.width
			height: textRect.height
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
	console.log "text padding: #{padding.text}"

	#putting new sizes to model
	updateSize.width(size.sign.origin.width)
	updateSize.height(size.sign.origin.height)

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

	posY = size.text.y
	for text, id in model.texts
		textKonva = createText(text.align, text.text, size.text.x, posY, size.text.width,
			model.font, size.k * text.size, color.textColor, text.style)

		if (settings.debug)
			rect = simpleRect(size.text.x, size.text.y, size.text.width, textKonva.getHeight())
		posY += textKonva.getHeight() + size.padding.text

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
	if (settings.debug && debug?)
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
	$scope.getHoleName = (model = $scope.model) ->
		if model.holes["Middle left"] and model.holes["Middle right"]
			return "2 hål"
		else if model.holes["Top left corner"] and model.holes["Top right corner"] and model.holes["Bottom left corner"] and model.holes["Top right corner"]
			return "4 hål"
		"Inga"
	$rootScope.getHoleName = $scope.getHoleName
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
		if $scope.model.texts[index].size >= 1
			$scope.increaseSize(index, -size)

signs.controller 'modelsController', ($scope) ->
	$scope.minSize = settings.minSize
	$scope.maxHeight = settings.maxHeight
	$scope.maxWidth = settings.maxWidth
	$scope.maxRadius = settings.maxRadius
	$scope.blockRendering = false
	$scope.updateSizes = (width, height) ->
		$scope.blockRendering = true
		$scope.model.size.width = width
		$scope.model.size.height = height
		$scope.model.size.radius = width
		setTimeout ->
			$scope.blockRendering = false
		, 1
	$scope.updateSize =
		width: (width) ->
			$scope.blockRendering = true
			$scope.model.size.width = width
			setTimeout ->
				$scope.blockRendering = false
			, 1
		height: (height) ->
			$scope.blockRendering = true
			$scope.model.size.height = height
			setTimeout ->
				$scope.blockRendering = false
			, 1
		radius: (radius) ->
			$scope.blockRendering = true
			$scope.model.size.radius = radius
			setTimeout ->
				$scope.blockRendering = false
			, 1
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
		$scope.addTextRow = (model, row, rowIndex, textIndex, sizeIndex) ->
			if row[rowIndex]? and row[sizeIndex]?
				defaultText = copyObj(modelTemplate.texts[0])
				model.texts[textIndex] = defaultText
				model.texts[textIndex].text = row[rowIndex]
				model.texts[textIndex].size = row[sizeIndex]
		$scope.addTheme = (model, row, rowIndex) ->
			model.theme = switch row[rowIndex]
				when 'Röd-Vit' then {
				name: "röd / vit"
				textColor: "white"
				bgColor: "red"
				}
				when 'Vit-Svart' then {
				name: "vit / svart"
				textColor: "black"
				bgColor: "white"
				}
				when 'Gul-Svart' then {
				name: "gul / svart"
				textColor: "black"
				bgColor: "yellow"
				}
				when 'Grön-Vit' then {
				name: "grön / vit"
				textColor: "white"
				bgColor: "green"
				}
				when 'Brun-Vit' then {
				name: "brun / vit"
				textColor: "white"
				bgColor: "#964B00"
				}
				when 'Blå-Vit' then {
				name: "blå / vit"
				textColor: "white"
				bgColor: "blue"
				}
				when 'Svart-Vit' then {
				name: "svart / vit"
				textColor: "white"
				bgColor: "black"
				}
				else
					modelTemplate.theme
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
			for index in [1..json_sheet.length]
				row = json_sheet[index]
				if row? and row[1] and row[9]? # Rad 1
					console.log row
					model = copyObj(modelTemplate)

					if row[0]? # Antal
						model.order = parseInt(row[0])

					$scope.addTextRow(model, row, 1, 0, 9) # Rad 1
					$scope.addTextRow(model, row, 2, 1, 10) # Rad 2
					$scope.addTextRow(model, row, 3, 2, 11) # Rad 3
					$scope.addTextRow(model, row, 4, 3, 12) # Rad 4
					$scope.addTextRow(model, row, 5, 4, 13) # Rad 5
					$scope.addTextRow(model, row, 6, 5, 14) # Rad 6
					$scope.addTextRow(model, row, 7, 6, 15) # Rad 7
					$scope.addTextRow(model, row, 8, 7, 16) # Rad 1
					$scope.addTheme(model, row, 17) #theme
					if row[18]? #width
						model.size.width = parseInt(row[18])
						model.size.autoWidth = false
					if row[19]? #height
						model.size.height = parseInt(row[19])
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
					$scope.$apply ->
						$scope.models.push model
						$scope.updateCurrentModel($scope.models.length - 1)

			reader.onerror = (event) ->
				console.error("Problems reading file, code:  " + event.target.error.code)
	, true
	$scope.triggerImport = ->
		$('#file').trigger('click')
		return

	$scope.copySelected = ->
		$scope.newSign($scope.model)

	$scope.onChange = onChange
	$scope.models = getModels()
	$scope.current = 0 #by default

	$scope.newSign = (template = modelTemplate) ->
		$scope.models.push copyObj(template)
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
		unless $scope.blockRendering
			$scope.onChange($scope.stage, $scope.model, $scope.errorCallback, $scope.updateSize)
	, true
	$scope.calcPrice = (model = $scope.model) ->
		holes = 0
		for key, value of model.holes
			if value
				holes += 1
		price = model.size.width * model.size.height * 0.0075 + 5 + holes
		if model.shape == "rundad rektangulär" then price += 2
		Math.floor(price)
	$scope.orderBasicPrice = settings.orderBasicPrice
	$scope.summary = (models = $scope.models) ->
		summary = {}
		summary.price = $scope.orderBasicPrice
		summary.order = 0
		for model in models
			summary.price += $scope.calcPrice(model) * model.order
			summary.order += model.order
		summary
signs.controller 'orderController', ($scope, $rootScope, $http) ->
	$rootScope.order = (models) ->
		$scope.show = true
		$scope.models = []
		dirtyModels = copyObj(models)
		for model in dirtyModels
			unless model.order == 0
				model.holes = $rootScope.getHoleName(model)
				model.theme = model.theme.name
				delete model.holes_rect
				console.log model
				$scope.models.push model
	$scope.client =
		name:
			first: ""
			last: ""
		phone: ""
		email: ""
		company: ""
		number: ""
		address: ""
		comment: ""
		postCode: ""
		postTown: ""
	$scope.show = false
	$scope.finishOrder = () ->
		$scope.show = false
		$http.post "mail.php",
			client: JSON.stringify($scope.client, null, 2)
			models: JSON.stringify($scope.models, null, 2)
		swal
			title: "Thank you for ordering our signs"
			text: "We answer you asap"
			type: "success"