var ctx = $('nvgContext');

ctx.translate( 20, 20);


ctx.fillStyle = '#070';
ctx.fillRect( 5, 5, 115, 60);


ctx.font = '60px sans';
var text = 'VfL Bochum 1848'
var info = ctx.measureText(text);

ctx.fillStyle = '#ff0';
ctx.fillRect(10-5, 65, info.width+5, 3);

ctx.fillStyle = 'white';
ctx.fillText(text, 10, 50);



/*
var yPosMin = 125;
var yPosStart = 150;
var xPosStart = -50;
var yPosChangeMultiplier = 60;
var xPosChangeMin = 125;
var xPosChangeMultiplier = 25;
var yControlMultiplier = 20;
var yControlMin = 40;

//
// End Config Vars
//


var context = $('nvgContext');
var lastX;
var yPosMax;
var controlX;
var controlY;

context.fillStyle = '#ecf0f1';
var xPos = xPosStart;
var yPos = yPosStart;
context.beginPath();
context.moveTo(xPos, yPos);
while (xPos < $('width')) {
   lastX = xPos;
   xPos += Math.floor(Math.random() * xPosChangeMultiplier + xPosChangeMin);
   yPos += Math.floor(Math.random() * yPosChangeMultiplier - yPosChangeMultiplier / 2);
   while (yPos < yPosMin) {
      yPos += Math.floor(Math.random() * yPosChangeMultiplier / 2);
   }
   while (yPos > yPosMax) {
      yPos -= Math.floor(Math.random() * yPosChangeMultiplier / 2);
   }
   controlX = (lastX + xPos) / 2;
   controlY = yPos - Math.floor(Math.random() * yControlMultiplier + yControlMin);
   context.quadraticCurveTo(controlX, controlY, xPos, yPos);
}
context.lineTo($('width'), yPos);
context.lineTo($('width'), $('height'));
context.lineTo(0, $('height'));
context.fill();
*/

ctx.translate(0, 100);


var canvasWidth = 200;
var canvasHeight = 200;
var heightScale = 0.866;


function rnd(min, max) {
   return Math.floor((Math.random() * (max - min + 1)) + min);
};


function render() {
   ctx.fillStyle = 'rgb(0,0,0)';
   ctx.fillRect(0, 0, canvasWidth, canvasHeight);
   ctx.lineWidth = 1;

   var hueStart = rnd(0, 360);
   var triSide = 40;
   var halfSide = triSide / 2;
   var rowHeight = Math.floor(triSide * heightScale);
   var columns = Math.ceil(canvasWidth / triSide) + 1;
   var rows = Math.ceil(canvasHeight / rowHeight);

   var col, row;
   for (row = 0; row < rows; row++) {
      var hue = hueStart + (row * 3);

      for (col = 0; col < columns; col++) {

         var x = col * triSide;
         var y = row * rowHeight;
         var clr;

         if (row % 2 != 0) {
            x -= halfSide;
         }

         // upward pointing triangle
         clr = 'hsl(' + hue + ', 40%, ' + rnd(0, 60) + '%)';
         ctx.fillStyle = clr;
         ctx.strokeStyle = clr;
         ctx.beginPath();
         ctx.moveTo(x, y);
         ctx.lineTo(x + halfSide, y + rowHeight);
         ctx.lineTo(x - halfSide, y + rowHeight);
         ctx.closePath();
         ctx.fill();
         ctx.stroke(); // needed to fill antialiased gaps on edges

         // downward pointing triangle
         clr = 'hsl(' + hue + ', 100%, ' + rnd(0, 60) + '%)';
         ctx.fillStyle = clr;
         ctx.strokeStyle = clr;
         ctx.beginPath();
         ctx.moveTo(x, y);
         ctx.lineTo(x + triSide, y);
         ctx.lineTo(x + halfSide, y + rowHeight);
         ctx.closePath();
         ctx.fill();
         ctx.stroke();

      };
   };
};

render();

