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
	// текущее состояние доски
	this.board = [Board.CENTER];
	
	// последняя активная клетка
	this.active = {x:0,y:0};
	
	// маска выделенной линии для клетки
	this.mask = [];
	
    // x-координаты плиток панели управления
	this.xpanel = [0, 0.5, 2, 3.5];
	
	// перемещаемая плитка
	this.dragged = -1;
	
	// флаг окончания игры
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
  Функция прорисовки игрового поля. 
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
    // нарисовать текущее состояние плиток
    var k = 0;        
    for (var i=0; i<Board.N; i++) {
        for (var j=0; j<Board.N; j++) {
            this.drawTile(this.board[k], j,i, this.mask[k]);
            k++;
        }
    }    
    // нарисовать плитки для drag & drop
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
  Обработчик события ``down``.
  Выбирает, какая плитка будет использоваться в следующем ходе.
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
  Определяет, на какую плитку в панели управления был клик мышкой.
  Возвращает номер плитки: (LEFT,CENTER,RIGHT) или -1.
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
  Обработчик события ``move``.
  Прорисовывает промежуточное состояние перемещаемой плитки.
 */
_p.dragTile = function(xp, yp) {
    this.xsel = (xp-this.x)/this.cellSize; 
    this.ysel = (yp-this.y)/this.cellSize;
}

/*
  Обработчик события ``up``.
  Фиксирует перемещаемую плитку на доске, завершая тем самым ход.
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
    // проверить, что выбрана пустая клетка
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
	// Определить, на какую следующую клетку выходит кривая.
	do {
		// Определим относительное смещение выставленной плитки
		var dx = nx-this.active.x;
		var dy = ny-this.active.y;
		// Установить начальное значение следующего смещения (dx2,dy2)
		// как для плитки CENTER.
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
		// выставить маску выделенной линии для текущей плитки
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
		// если next - уже заполненная клетка? 
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

