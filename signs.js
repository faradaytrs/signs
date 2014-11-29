// Generated by CoffeeScript 1.8.0
(function() {
  $(function() {
    var buildSelects, getConfiguration, render, settings;
    settings = {
      shapes: {
        round: "link image",
        square: "link image"
      },
      holes: ["Top left corner", "Top right corner", "Middle left", "Middle right", "Bottom left corner", "Bottom right corner"],
      fonts: ["Times New Roman", "Arial"],
      materials: ["Steel", "Mystic material"],
      color: "#ffffff"
    };
    buildSelects = function() {
      var bgColor, hole, holes, input, label, material, materials, selects, shape, shapes, span, _i, _j, _len, _len1, _ref, _ref1, _results;
      selects = $('.selects');
      $('<h4>Background color:</h4>').appendTo(selects);
      bgColor = $("<input type='text' value=\"" + settings.color + "\" name=\"bgcolor\" class='color form-control'>");
      bgColor.appendTo(selects);
      $('<h4>Shapes:</h4>').appendTo(selects);
      for (shape in settings.shapes) {
        shapes = $('<div></div>').addClass("radio");
        label = $("<label></label>");
        input = $("<input type='radio'>");
        input.addClass(shape);
        input.attr('value', shape);
        input.attr('name', "shapes");
        input.appendTo(label);
        span = $("<span>" + shape + "</span>");
        span.appendTo(label);
        label.appendTo(shapes);
        shapes.appendTo(selects);
      }
      $('<h4>Holes:</h4>').appendTo(selects);
      _ref = settings.holes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        hole = _ref[_i];
        holes = $('<div></div>').addClass("checkbox");
        label = $("<label></label>");
        input = $("<input type='checkbox'>");
        input.addClass(hole);
        input.attr('value', hole);
        input.attr('name', "holes");
        input.appendTo(label);
        span = $("<span>" + hole + "</span>");
        span.appendTo(label);
        label.appendTo(holes);
        holes.appendTo(selects);
      }
      $('<h4>Materials:</h4>').appendTo(selects);
      _ref1 = settings.materials;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        material = _ref1[_j];
        materials = $('<div></div>').addClass("radio");
        label = $("<label></label>");
        input = $("<input type='radio'>");
        input.addClass(material);
        input.attr('value', material);
        input.attr('name', "materials");
        input.appendTo(label);
        span = $("<span>" + material + "</span>");
        span.appendTo(label);
        label.appendTo(materials);
        _results.push(materials.appendTo(selects));
      }
      return _results;
    };
    getConfiguration = function() {
      var color, configuration, holes, material, shape;
      shape = $('input[name=shapes]:checked').val();
      holes = [];
      $('input[name=holes]:checked').each(function() {
        return holes.push(this.value);
      });
      material = $('input[name=materials]:checked').val();
      color = $('input[name=bgcolor]').val();
      configuration = {
        shape: shape,
        holes: holes,
        material: material,
        bgcolor: color
      };
      return console.log(configuration);
    };
    render = function() {
      var conf, field;
      conf = getConfiguration();
      return field = $('preview');
    };
    buildSelects();
    $(".color").pickAColor();
    return $('input').each(function() {
      this.onclick = render;
      return this.onchange = render;
    });
  });

}).call(this);

//# sourceMappingURL=signs.js.map
