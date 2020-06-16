var ctx=$('nvgContext');

var colors = ['#4CAF50', '#00BCD4', '#E91E63', '#FFC107', '#9E9E9E', '#CDDC39', '#18FFFF', '#F44336', '#FFF59D', '#6D4C41'];
var angles = [Math.PI * 0.3, Math.PI * 0.7, Math.PI * 0.2, Math.PI * 0.4, Math.PI * 0.4];

// Base offset distance of 10
var offset = 10;
var beginAngle = 0;
var endAngle = 0;

// Used to calculate the X and Y offset
var offsetX, offsetY, medianAngle;

for (var i = 0; i < angles.length; i = i + 1) {
   beginAngle = endAngle;
   endAngle = endAngle + angles[i];

   // The medium angle is the average of two consecutive angles
   medianAngle = (endAngle + beginAngle) / 2;

   // X and Y calculations
   offsetX = Math.cos(medianAngle) * offset;
   offsetY = Math.sin(medianAngle) * offset;

   ctx.beginPath();
   ctx.fillStyle = colors[i % colors.length];

   // Adding the offsetX and offsetY to the center of the arc
   ctx.moveTo(200 + offsetX, 200 + offsetY);
   ctx.arc(200 + offsetX, 200 + offsetY, 120, beginAngle, endAngle);
   ctx.lineTo(200 + offsetX, 200 + offsetY);
   ctx.stroke();
   ctx.fill();
}