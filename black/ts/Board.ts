

class Board {

    // количество клеток на доске
    static N = 5;

    active: Cell;
    board: Tile[];

    // смещение доски на экране
    x: number;
    y: number;

    // размер плитки
    cellSize: number;

    // размер холста
    sizeX: number;
    sizeY: number;

    constructor(private ctx: CanvasRenderingContext2D) {
        this.ctx.fillStyle = "#f8f4d0";
        this.resetGame();
    }

    resetGame() {
        // текущее состояние доски
        this.board = [Tile.CENTER];

        // последняя активная клетка
        this.active = { x: 0, y: 0 };
    }

    setSize(dx: number, dy: number, sizeX: number, sizeY: number) {
        // размер плитки
        this.cellSize = sizeX / Board.N;

        // смещение доски на экране
        this.x = dx;
        this.y = dy;

        // размер холста
        this.sizeX = sizeX;
        this.sizeY = sizeY;
    }
}
