<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>“опологическа€ игра блэк</title>

<link rel="stylesheet" type="text/css" href="../stylesheets/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="../stylesheets/plotnik.css">
<style>
  .footnote {
	font-size: initial;
	font-style: italic;
	margin-top: 70px;
  }
  .play-button {
    margin-top: 30px;
  }
</style>

  </head>
  <body>
  
<div class="container">  

<h1>HTML markup</h1>

@o black.html
@{<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>Black</title>
	<meta name="viewport"
		  content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, target-densitydpi=device-dpi"/>

	<style>
		html, body {
			overflow: hidden;
			width: 100%;
			height: 100%;
			margin:0;
			padding:0;
			border: 0;
			background-color: #f8f4d0;
		}

	</style>

	<script src="lib/utils.js"></script>
	<script src="lib/EventEmitter.js"></script>
	<script src="lib/input/InputHandlerBase.js"></script>
	<script src="lib/input/TouchInputHandler.js"></script>
	<script src="lib/input/MouseInputHandler.js"></script>
	<script src="lib/input/InputHandler.js"></script>
	<script src="Board.js"></script>

	<script>
		var ctx;
		var canvas;
        var game;
		var imageManager;
        
		function init() {

			canvas = initFullScreenCanvas("mainCanvas");
			ctx = canvas.getContext("2d");

			game = new Board(ctx);
            var sizeX = canvas.width-5;
            var sizeY = Math.round(sizeX*70/50);
            if (sizeY>canvas.height) {
                var k = sizeY/canvas.height;
                sizeX = sizeX/k;
                sizeY = canvas.height;
            }
            var dx = Math.round((canvas.width-sizeX)/2);
            var dy = Math.round((canvas.height-sizeY)/2);
			game.setSize(dx,dy,sizeX,sizeY);
			
			animateCanvas();

			var input = new InputHandler(canvas);

			// Picking phase
			input.on("down", function(e) {
			    game.selectTile(e.x, e.y);
			});

			// Movement phase
			input.on("move", function(e) {
			    game.dragTile(e.x, e.y);
			});

			// Release phase
			input.on("up", function(e) {
			    game.dropTile(e.x, e.y);
			});

		}

		function animateCanvas() {
			ctx.clearRect(0, 0, canvas.width, canvas.height);
            game.drawBoard();
            requestAnimationFrame(arguments.callee);
		}
		
		function initFullScreenCanvas(canvasId) {
			var canvas = document.getElementById("mainCanvas");
			resizeCanvas(canvas);
			window.addEventListener("resize", function() {
				resizeCanvas(canvas);
			});
			return canvas;
		}

		function resizeCanvas(canvas) {
			canvas.width  = document.width || document.body.clientWidth;
			canvas.height = document.height || document.body.clientHeight;
		}
	</script>
</head>
<body onload="init()">
<div id="lobby">
	<canvas id="mainCanvas" width="30" height="30"></canvas>
</div>
</body>
</html>
@}

<h1>JavaScript code</h1>

@o Board.js
@{
function Board(context) {
	this.ctx = context;
	this.ctx.fillStyle = "#f8f4d0"; //"white";
	this.resetGame();
}

_p = Board.prototype;

// количество клеток на доске
Board.N = 5;

// коды плиток
Board.LEFT   = 1;
Board.CENTER = 2;
Board.RIGHT  = 3;

_p.resetGame = function() {
	// текущее состо€ние доски
	this.board = [Board.CENTER];
	
	// последн€€ активна€ клетка
	this.active = {x:0,y:0};
	
	// маска выделенной линии дл€ клетки
	this.mask = [];
	
    // x-координаты плиток панели управлени€
	this.xpanel = [0, 0.5, 2, 3.5];
	
	// перемещаема€ плитка
	this.dragged = -1;
	
	// флаг окончани€ игры
	this.gameOver = false;
}

_p.setSize = function(dx,dy,sizeX,sizeY) {
	// размер плитки
	this.cellSize = sizeX/Board.N;
	
	// смещение доски на экране
	this.x = dx;
	this.y = dy;
	
	// размер холста
	this.sizeX = sizeX;
	this.sizeY = sizeY;
}

/* 
  ‘ункци€ прорисовки игрового пол€. 
 */
_p.drawBoard = function() {
    var ctx = this.ctx;
    ctx.strokeRect(this.x, this.y, this.sizeX, this.sizeY);
    // нарисовать сетку на доске
    ctx.save();
    ctx.translate(this.x, this.y);
    var boardSize = this.sizeX;
    ctx.beginPath();
    for (var i=1; i<=Board.N; i++) {
        ctx.moveTo(0, this.cellSize*i);
        ctx.lineTo(boardSize, this.cellSize*i);
        ctx.moveTo(this.cellSize*i, 0);
        ctx.lineTo(this.cellSize*i, boardSize);
    }
    ctx.stroke();  
    // нарисовать текущее состо€ние плиток
    var k = 0;        
    for (var i=0; i<Board.N; i++) {
        for (var j=0; j<Board.N; j++) {
            this.drawTile(this.board[k], j,i, this.mask[k]);
            k++;
        }
    }    
    // нарисовать плитки дл€ drag & drop
    var ypanel = Board.N+0.5;
    this.drawLeftTile(   this.xpanel[Board.LEFT],   ypanel);
    this.drawCenterTile( this.xpanel[Board.CENTER], ypanel);
    this.drawRightTile(  this.xpanel[Board.RIGHT],  ypanel);
    
    this.drawTile(this.dragged, this.xsel-0.5, this.ysel-0.5);
    if (this.next) {
		this.debugDrawNext(this.next.x, this.next.y);
	}

    ctx.restore();
}

_p.debugDrawNext = function(kx,ky) {
    var ctx = this.ctx;
    var tileSize = this.cellSize;
    ctx.save();
    ctx.translate(kx*tileSize, ky*tileSize);
    var w = 5;
    ctx.strokeRect(w,w, tileSize-2*w, tileSize-2*w);
    ctx.restore();
}

_p.drawTile = function(n,kx,ky,m) {
    switch (n) {
        case Board.LEFT:    this.drawLeftTile(kx,ky,m); break;
        case Board.CENTER:  this.drawCenterTile(kx,ky,m); break;
        case Board.RIGHT:   this.drawRightTile(kx,ky,m); break;
    }
}

_p.drawLeftTile = function(kx,ky,m) {
    var ctx = this.ctx;
    var tileSize = this.cellSize;
    ctx.save();
    ctx.translate(kx*tileSize, ky*tileSize);
    ctx.fillRect(0,0, tileSize, tileSize);
    ctx.strokeRect(0,0, tileSize, tileSize);
    
	ctx.lineWidth = m & 1? 5:1;
    ctx.beginPath();
	ctx.moveTo(tileSize/2,0);
	ctx.arcTo(tileSize/2,tileSize/2, tileSize,tileSize/2, tileSize/2);
    ctx.stroke();           

	ctx.lineWidth = m & 2? 5:1;
    ctx.beginPath();
	ctx.moveTo(tileSize/2,tileSize);
	ctx.arcTo(tileSize/2,tileSize/2, 0,tileSize/2, tileSize/2);
    ctx.stroke(); 
              
    ctx.restore();
}

_p.drawCenterTile = function(kx,ky,m) {
    var ctx = this.ctx;
    var tileSize = this.cellSize;
    ctx.save();
    ctx.translate(kx*tileSize, ky*tileSize);
    ctx.fillRect(0,0, tileSize, tileSize);
    ctx.strokeRect(0,0, tileSize, tileSize);

    ctx.lineWidth = m & 1? 5:1;
    ctx.beginPath();
	ctx.moveTo(tileSize/2,0);
	ctx.lineTo(tileSize/2,tileSize);
    ctx.stroke();            

	ctx.lineWidth = m & 2? 5:1;
    ctx.beginPath();
	ctx.moveTo(0,tileSize/2);
	ctx.lineTo(tileSize,tileSize/2);
    ctx.stroke();            

    ctx.restore();
}

_p.drawRightTile = function(kx,ky,m) {
    var ctx = this.ctx;
    var tileSize = this.cellSize;
    ctx.save();
    ctx.translate(kx*tileSize, ky*tileSize);
    ctx.fillRect(0,0, tileSize, tileSize);
    ctx.strokeRect(0,0, tileSize, tileSize);

	ctx.lineWidth = m & 1? 5:1;
    ctx.beginPath();
	ctx.moveTo(tileSize/2,0);
	ctx.arcTo(tileSize/2,tileSize/2, 0,tileSize/2, tileSize/2);
    ctx.stroke();            

	ctx.lineWidth = m & 2? 5:1;
    ctx.beginPath();
	ctx.moveTo(tileSize/2,tileSize);
	ctx.arcTo(tileSize/2,tileSize/2, tileSize,tileSize/2, tileSize/2);
    ctx.stroke();            

    ctx.restore();
}

/* 
  ќбработчик событи€ ``down``.
  ¬ыбирает, кака€ плитка будет использоватьс€ в следующем ходе.
 */
_p.selectTile = function(xp, yp)  {
	if (this.gameOver) {
		this.resetGame();
		return;
	}
    this.dragged = this.getPanelTile((xp-this.x)/this.cellSize, (yp-this.y)/this.cellSize);
    if (this.dragged!=-1) {
        this.xsel = this.xpanel[this.dragged]; 
        this.ysel = Board.N+0.5;
    }
}

/*
  ќпредел€ет, на какую плитку в панели управлени€ был клик мышкой.
  ¬озвращает номер плитки: (LEFT,CENTER,RIGHT) или -1.
 */
_p.getPanelTile = function(nx, ny)  {
    //console.log('---- nx='+nx+', ny='+ny);
    var cy = ny-(Board.N+0.5);
    if (cy<0 || cy>1)
        return -1;
    for (var i=1; i<=3; i++) {
        var cx = nx-this.xpanel[i];
        if (cx>=0 && cx<=1)
            return i;
    }
    return -1;
}

/*
  ќбработчик событи€ ``move``.
  ѕрорисовывает промежуточное состо€ние перемещаемой плитки.
 */
_p.dragTile = function(xp, yp) {
    this.xsel = (xp-this.x)/this.cellSize; 
    this.ysel = (yp-this.y)/this.cellSize;
}

/*
  ќбработчик событи€ ``up``.
  ‘иксирует перемещаемую плитку на доске, заверша€ тем самым ход.
 */
_p.dropTile = function(xp, yp) {
    var tile = this.dragged;
	if (tile==-1) 
	    return;
    this.dragged = -1;
    // проверить, что мы попадаем в квадрат сетки
    var nx = (xp-this.x)/this.cellSize; 
    var ny = (yp-this.y)/this.cellSize;
    if (nx<0 || nx>=Board.N || ny<0 || ny>=Board.N)
        return;
    nx = Math.floor(nx);
    ny = Math.floor(ny);  
    // проверить, что выбрана пуста€ клетка
    if (this.board[nx+Board.N*ny]>0)
        return;
    if (this.board.length==1) {
		if (nx+ny!=1)
		    return;
		this.setMask(0,Board.CENTER,nx);    
	} else {
		if (nx!=this.next.x || ny!=this.next.y)
		    return;
	}    
	// поместить плитку в клетку
	this.board[nx+Board.N*ny] = tile;
	// ќпределить, на какую следующую клетку выходит крива€.
	do {
		// ќпределим относительное смещение выставленной плитки
		var dx = nx-this.active.x;
		var dy = ny-this.active.y;
		// ”становить начальное значение следующего смещени€ (dx2,dy2)
		// как дл€ плитки CENTER.
		var dx2 = dx;
		var dy2 = dy;
		if (tile==Board.LEFT) {
			dx2 = dy;
			dy2 = dx;
		} else
		if (tile==Board.RIGHT) {
			dx2 = -dy;
			dy2 = -dx;
		}
		// выставить маску выделенной линии дл€ текущей плитки
		console.log('---- tile: '+tile+', dx='+dx+', dy='+dy+', dx2='+dx2+', dy2='+dy2);
		this.setMask(nx+Board.N*ny,tile,dx+2*dx2);
		// вычислить клетку следующего хода
		var nx2 = nx+dx2;
		var ny2 = ny+dy2;
		if (nx2<0 || nx2>=Board.N || ny2<0 || ny2>=Board.N) {
			this.gameOver = true;
	        // сбросим клетку следующего хода
	        this.next = null;
			return;
		}
		this.active = {x:nx,y:ny}; 
		this.next = {x:nx2,y:ny2}; 
		// если next - уже заполненна€ клетка? 
		tile = this.board[nx2+Board.N*ny2];
		if (tile>0) {
			nx = nx2;
			ny = ny2;
		}
	} while (tile>0);	
}

_p.setMask = function(k,tile,z) {
	var m = 0;
	if (this.mask[k]) 
	    m = this.mask[k];
	switch (tile) {
		case Board.LEFT:
		    m |= z==2 || z==-1? 1:2;
		    break;
		case Board.CENTER:
		    m |= z==0? 1:2;  
		    break;
		case Board.RIGHT:
		    m |= z==-2 || z==1? 1:2;
		    break;
	}      
	console.log('---- k='+k+', tile='+tile+', z='+z+', m='+m);
	this.mask[k] = m;    
}
@}

</div><!--.row-->


</div><!--.container-->

<script src="../javascripts/jquery-2.1.4.min.js"></script>
<script src="../javascripts/bootstrap.min.js"></script>

  </body>
</html>