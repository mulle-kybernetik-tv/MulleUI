function drawPieSlice(ctx, centerX, centerY, radius, startAngle, endAngle, color) {
   nvgFillColor(ctx, MulleColorCreateFromCString( color));
   //ctx.beginPath();
   nvgBeginPath( ctx);
   // ctx.moveTo( centerX, centerY);
   nvgMoveTo( ctx, centerX, centerY);
   // ctx.arc(centerX, centerY, radius, startAngle, endAngle);
   nvgArc( ctx, centerX, centerY, radius, startAngle, endAngle);
   // ctx.closePath();
   nvgClosePath( ctx);
   //ctx.fill();
   nvgFill(ctx);
}


var Piechart = function (options) {
   this.options = options;
   this.canvas = options.canvas;
   this.ctx = options.ctx
   this.colors = options.colors;

   this.draw = function () {
      var total_value = 0;
      var color_index = 0;

      for (var categ in this.options.data) {
         var val = this.options.data[categ];
         total_value += val;
      }

      var start_angle = 0;
      for (categ in this.options.data) {
         val = this.options.data[categ];
         var slice_angle = 2 * Math.PI * val / total_value;

         drawPieSlice(
            this.ctx,
            this.canvas.width / 2,
            this.canvas.height / 2,
            Math.min(this.canvas.width / 2, this.canvas.height / 2),
            start_angle,
            start_angle + slice_angle,
            this.colors[color_index % this.colors.length]
         );

         start_angle += slice_angle;
         color_index++;
      }

      //drawing a white circle over the chart
      //to create the doughnut chart
      if (this.options.doughnutHoleSize) {
         drawPieSlice(
            this.ctx,
            this.canvas.width / 2,
            this.canvas.height / 2,
            this.options.doughnutHoleSize * Math.min(this.canvas.width / 2, this.canvas.height / 2),
            0,
            2 * Math.PI,
            "#007"
         );
      }

      start_angle = 0;
      for (categ in this.options.data) {
        val = this.options.data[categ];
        slice_angle = 2 * Math.PI * val / total_value;
        var pieRadius = Math.min(this.canvas.width / 2, this.canvas.height / 2);
        var labelX = this.canvas.width / 2 + (pieRadius / 2) * Math.cos(start_angle + slice_angle / 2);
        var labelY = this.canvas.height / 2 + (pieRadius / 2) * Math.sin(start_angle + slice_angle / 2);

       if (this.options.doughnutHoleSize) {
          var offset = (pieRadius * this.options.doughnutHoleSize) / 2;
          labelX = this.canvas.width / 2 + (offset + pieRadius / 2) * Math.cos(start_angle + slice_angle / 2);
          labelY = this.canvas.height / 2 + (offset + pieRadius / 2) * Math.sin(start_angle + slice_angle / 2);
       }

        var labelText = Math.round(100 * val / total_value);

        nvgTextColor(this.ctx, MulleColorCreateFromCString('white'), MulleColorCreateFromCString('blue'));
        
        // this.ctx.fillStyle = "black";
        nvgFontFace( this.ctx, "sans");
//        this.ctx.font = "32px sans";
        nvgFontSize(this.ctx, 40);
        nvgText(this.ctx, labelX, labelY, labelText + "%", NULL);
        //this.ctx.fillText(labelText + "%", labelX, labelY);
        start_angle += slice_angle;

      }      
   }
}

var myVinyls = {
   "Classical music": 10,
   "Alternative rock": 14,
   "Pop": 2,
   "Jazz": 12
};


var myDougnutChart = new Piechart(
   {
      canvas: { "width": $('width'), "height": $('height') },
      ctx: $('nvgContext'),
      data: myVinyls,
      colors: ["#fde23e", "#f16e23", "#57d9ff", "#937e88"],
      doughnutHoleSize: 0.5
   }
);

myDougnutChart.draw();


var ctx = $('nvgContext')
var image = loadImage( "bengal");
var paint = nvgImagePattern( ctx, 0, 0, 200, 200, 0, image, 1.0);
nvgBeginPath( ctx);
nvgTranslate(ctx, 255, 115);
nvgCircle( ctx, 100, 100, 100);
nvgFillPaint( ctx, paint);
nvgFill( ctx);
