var ctx=$('nvgContext');

   ctx.translate( 50, 50);


// various examples taken from 
// https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Tutorial/Drawing_shapes
// and mashed together.

   // draw background
   ctx.fillStyle = '#FD0';
   ctx.fillRect(0, 0, 75, 75);
   ctx.fillStyle = '#6C0';
   ctx.fillRect(75, 0, 75, 75);
   ctx.fillStyle = '#09F';
   ctx.fillRect(0, 75, 75, 75);
   ctx.fillStyle = '#F30';
   ctx.fillRect(75, 75, 75, 75);
   ctx.fillStyle = '#FFF';

   // set transparency value
   ctx.globalAlpha = 0.2;

   // Draw semi transparent circles
   for (var i = 0; i < 7; i++) {
      ctx.beginPath();
      ctx.arc(75, 75, 10 + 10 * i, 0, Math.PI * 2, true);
      ctx.fill();
   }

ctx.globalAlpha = 1.0;

ctx.translate(200, 0);


ctx.fillStyle = 'rgb(255, 221, 0)';
ctx.fillRect(0, 0, 150, 37.5);
ctx.fillStyle = 'rgb(102, 204, 0)';
ctx.fillRect(0, 37.5, 150, 37.5);
ctx.fillStyle = 'rgb(0, 153, 255)';
ctx.fillRect(0, 75, 150, 37.5);
ctx.fillStyle = 'rgb(255, 51, 0)';
ctx.fillRect(0, 112.5, 150, 37.5);


// Draw semi transparent rectangles
for (var i = 0; i < 10; i++) {
   ctx.fillStyle = 'rgba(255, 255, 255, ' + (i + 1) / 10 + ')';
   for (var j = 0; j < 4; j++) {
      ctx.fillRect(5 + i * 14, 5 + j * 37.5, 14, 27.5);
   }
}

ctx.translate(200, 0);

for (var i = 0; i < 10; i++) {
   ctx.lineWidth = 1 + i;
   ctx.beginPath();
   ctx.moveTo(5 + i * 14, 5);
   ctx.lineTo(5 + i * 14, 140);
   ctx.stroke();
}

ctx.translate( -400, 200);

var lineCap = ['butt', 'round', 'square'];

// Draw guides
ctx.lineWidth = 1;
ctx.strokeStyle = '#09f';
ctx.beginPath();
ctx.moveTo(10, 10);
ctx.lineTo(140, 10);
ctx.moveTo(10, 140);
ctx.lineTo(140, 140);
ctx.stroke();

// Draw lines
ctx.strokeStyle = 'black';
for (var i = 0; i < lineCap.length; i++) {
   ctx.lineWidth = 15;
   ctx.lineCap = lineCap[i];
   ctx.beginPath();
   ctx.moveTo(25 + i * 50, 10);
   ctx.lineTo(25 + i * 50, 140);
   ctx.stroke();
}

ctx.translate(200, 0);

var lineJoin = ['round', 'bevel', 'miter'];
ctx.lineWidth = 10;
for (var i = 0; i < lineJoin.length; i++) {
   ctx.lineJoin = lineJoin[i];
   ctx.beginPath();
   ctx.moveTo(-5, 5 + i * 40);
   ctx.lineTo(35, 45 + i * 40);
   ctx.lineTo(75, 5 + i * 40);
   ctx.lineTo(115, 45 + i * 40);
   ctx.lineTo(155, 5 + i * 40);
   ctx.stroke();
}


ctx.translate(200, 0);

// Clear canvas
//ctx.clearRect(0, 0, 150, 150);

// Draw guides
ctx.strokeStyle = '#09f';
ctx.lineWidth = 2;
ctx.strokeRect(-5, 50, 160, 50);

// Set line styles
ctx.strokeStyle = '#000';
ctx.lineWidth = 10;

ctx.miterLimit = 22.0;

// Draw lines
ctx.beginPath();
ctx.moveTo(0, 100);
for (i = 0; i < 24; i++) {
   var dy = i % 2 == 0 ? 25 : -25;
   ctx.lineTo(Math.pow(i, 1.5) * 2, 75 + dy);
}
ctx.stroke();