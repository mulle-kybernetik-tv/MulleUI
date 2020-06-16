var ctx=$('nvgContext');

// various examples taken from 
// https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Drawing_shapes
// and mashed together.

      // Quadratric curves example
      ctx.beginPath();
      ctx.moveTo(75, 25);
      ctx.quadraticCurveTo(25, 25, 25, 62.5);
      ctx.quadraticCurveTo(25, 100, 50, 100);
      ctx.quadraticCurveTo(50, 120, 30, 125);
      ctx.quadraticCurveTo(60, 120, 65, 100);
      ctx.quadraticCurveTo(125, 100, 125, 62.5);
      ctx.quadraticCurveTo(125, 25, 75, 25);
      ctx.stroke();

      ctx.translate( 200, 0);
      ctx.beginPath();
      ctx.moveTo(75, 40);
      ctx.bezierCurveTo(75, 37, 70, 25, 50, 25);
      ctx.bezierCurveTo(20, 25, 20, 62.5, 20, 62.5);
      ctx.bezierCurveTo(20, 80, 40, 102, 75, 120);
      ctx.bezierCurveTo(110, 102, 130, 80, 130, 62.5);
      ctx.bezierCurveTo(130, 62.5, 130, 25, 100, 25);
      ctx.bezierCurveTo(85, 25, 75, 37, 75, 40);
      ctx.fillStyle = "red";
      ctx.fill();


ctx.translate(-200, 200);

function roundedRect(ctx, x, y, width, height, radius) {
   ctx.beginPath();
   ctx.moveTo(x, y + radius);
   ctx.lineTo(x, y + height - radius);
   ctx.arcTo(x, y + height, x + radius, y + height, radius);
   ctx.lineTo(x + width - radius, y + height);
   ctx.arcTo(x + width, y + height, x + width, y + height - radius, radius);
   ctx.lineTo(x + width, y + radius);
   ctx.arcTo(x + width, y, x + width - radius, y, radius);
   ctx.lineTo(x + radius, y);
   ctx.arcTo(x, y, x, y + radius, radius);
   ctx.stroke();
};



roundedRect(ctx, 12, 12, 150, 150, 15);
roundedRect(ctx, 19, 19, 150, 150, 9);
roundedRect(ctx, 53, 53, 49, 33, 10);
roundedRect(ctx, 53, 119, 49, 16, 6);
roundedRect(ctx, 135, 53, 49, 33, 10);
roundedRect(ctx, 135, 119, 25, 49, 10);

ctx.fillStyle = "yellow";

ctx.beginPath();
ctx.arc(37, 37, 13, Math.PI / 7, -Math.PI / 7, false);
ctx.lineTo(31, 37);
ctx.fill();


ctx.fillStyle = "red";


// dots
for (var i = 0; i < 8; i++) {
   ctx.fillRect(51 + i * 16, 35, 4, 4);
}

for (i = 0; i < 6; i++) {
   ctx.fillRect(115, 51 + i * 16, 4, 4);
}

for (i = 0; i < 8; i++) {
   ctx.fillRect(51 + i * 16, 99, 4, 4);
}


// clyde shape

ctx.fillStyle = "orange";

ctx.beginPath();
ctx.moveTo(83, 116);
ctx.lineTo(83, 102);
ctx.bezierCurveTo(83, 94, 89, 88, 97, 88);
ctx.bezierCurveTo(105, 88, 111, 94, 111, 102);
ctx.lineTo(111, 116);
ctx.lineTo(106.333, 111.333);
ctx.lineTo(101.666, 116);
ctx.lineTo(97, 111.333);
ctx.lineTo(92.333, 116);
ctx.lineTo(87.666, 111.333);
ctx.lineTo(83, 116);
ctx.fill();

// clyde eyes

ctx.fillStyle = 'white';
ctx.beginPath();
ctx.moveTo(91, 96);
ctx.bezierCurveTo(88, 96, 87, 99, 87, 101);
ctx.bezierCurveTo(87, 103, 88, 106, 91, 106);
ctx.bezierCurveTo(94, 106, 95, 103, 95, 101);
ctx.bezierCurveTo(95, 99, 94, 96, 91, 96);
ctx.moveTo(103, 96);
ctx.bezierCurveTo(100, 96, 99, 99, 99, 101);
ctx.bezierCurveTo(99, 103, 100, 106, 103, 106);
ctx.bezierCurveTo(106, 106, 107, 103, 107, 101);
ctx.bezierCurveTo(107, 99, 106, 96, 103, 96);
ctx.fill();

// clyde pupils
ctx.fillStyle = 'black';
ctx.beginPath();
ctx.arc(101, 102, 2, 0, Math.PI * 2, true);
ctx.fill();

ctx.beginPath();
ctx.arc(89, 102, 2, 0, Math.PI * 2, true);
ctx.fill();


/* end of pacman */

ctx.translate( 200, 0);

for (var i = 0; i < 4; i++) {
   for (var j = 0; j < 3; j++) {
      ctx.beginPath();
      var x = 25 + j * 50; // x coordinate
      var y = 25 + i * 50; // y coordinate
      var radius = 20; // Arc radius
      var startAngle = 0; // Starting point on circle
      var endAngle = Math.PI + (Math.PI * j) / 2; // End point on circle
      var anticlockwise = i % 2 !== 0; // clockwise or anticlockwise

      ctx.arc(x, y, radius, startAngle, endAngle, anticlockwise);

      if (i > 1) {
         ctx.fill();
      } else {
         ctx.stroke();
      }
   }
}


ctx.translate(200, 0);

for (var i = 0; i < 6; i++) {
   for (var j = 0; j < 6; j++) {
      ctx.strokeStyle = 'rgb( 0, ' + Math.floor(255 - 42.5 * i) + ', ' +
         Math.floor(255 - 42.5 * j) + ')';
      ctx.beginPath();
      ctx.arc(12.5 + j * 25, 12.5 + i * 25, 10, 0, Math.PI * 2, true);
      ctx.stroke();
   }
}

ctx.translate(0, -170);

for (var i = 0; i < 6; i++) {
   for (var j = 0; j < 6; j++) {
      ctx.fillStyle = 'rgb(' + Math.floor(255 - 42.5 * i) + ', ' +
         Math.floor(255 - 42.5 * j) + ', 0)';
      ctx.fillRect(j * 25, i * 25, 25, 25);
   }
}
