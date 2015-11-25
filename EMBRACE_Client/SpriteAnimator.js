var canvas = document.getElementById('overlay');
var ctx = canvas.getContext('2d');
var sheet;

var spritePosition = 0;
var spriteWidth = 140;
var spriteHeight = 140;
var spriteCount = 8;
var spritePlayCount = 0;
var maxSpritePlays = 2;

//////////////////////////
function loadSpriteSheet() {
    console.log("Calling animate");
    sheet = document.createElement("div");
    //sheet.src = "../Images/roll_spritesheet.png"; //load image

    //Adjust image style
    //sheet.style.width = "1120px";
    //sheet.style.left = "16%";
    //sheet.style.top = "32%";
    //sheet.style.zIndex = "3";
    //sheet.style.opacity = "1";

    //sheet.alt = "ball";
    sheet.className = "ball";
    sheet.id = "ball";

    var images = document.getElementById('body');
    images.appendChild(sheet);
    console.log(images.innerHTML);
    //animate();
    //positionSpriteSheet();
}

function positionSpriteSheet() {
    sheet.style.left = "16px";
    sheet.style.top = "32px";
}

//////////////////////////

var fps = 10;

function animate() {
    console.log("Calling animate...");
    //sheet.style.opacity = "1";
    setTimeout(function () {

        if (spritePlayCount < maxSpritePlays) {
            requestAnimationFrame(animate);
        }

        // Drawing code goes here
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.drawImage(sheet,
        spritePosition * spriteWidth, 0, spriteWidth, spriteHeight,
        50, 50, spriteWidth, spriteHeight);

        spritePosition++;
        if (spritePosition > spriteCount - 1) {
            spritePosition = 0;
            spritePlayCount++;
        }

    }, 1000 / fps);
}

function playAnimation() {
    console.log("PLAYING ANIMATION");
    $('.ball').addClass('roll');
    setTimeout(function() { $ball.removeClass('roll'); }, 800);
}

// Debug
// Use console.log(message); message is of type string
console = new Object();

console.log = function(log) {
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", "ios-log:#iOS#" + log);
    document.documentElement.appendChild(iframe);
    iframe.parentNode.removeChild(iframe);
    iframe = null;
};

console.debug = console.log;
console.info = console.log;
console.warn = console.log;
console.error = console.log;