//
//  TetrisGameModel.swift
//  Tetris
//
//  Created by Hannah Friedman on 8/4/21.
//

import SwiftUI

class TetrisGameModel: ObservableObject {
    var numRows: Int
    var numColumns: Int
    @Published var gameBoard: [[TetrisGameBlock?]]
    @Published var tetromino: Tetromino?
    
    var timer: Timer?
    var speed: Double
    
    //showing where piece will fall
    
    var shadow: Tetromino? {
        guard var lastShadow = tetromino else {return nil}
        var testShadow = lastShadow
        while(isValidTetromino(testTetromino: testShadow)) {
            lastShadow = testShadow
            testShadow = lastShadow.moveBy(row: -1, column: 0)
        }
        return lastShadow
    }
    
    init(numRows: Int = 23, numColumns: Int = 10) {
        self.numRows = numRows
        self.numColumns = numColumns
        
        //allowing access to gameboard -> gameBoard[][] columns / rows respectivly
        gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        speed = 0.5
        resumeGame()
    }
    
    func resumeGame() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: runEngine)
    }
    
    func pauseGame() {
        timer?.invalidate()
    }
    
    func runEngine(timer: Timer) {
        //check if need to clear line
        if clearLines() {
            print("Line Cleared")
            return
        }
        
        //spawn new block if needed
        guard tetromino != nil else {
            print("Spawning new Tetromino")
            tetromino = Tetromino.createNewTetromino(numRows: numRows, numColumns: numColumns)
            if !isValidTetromino(testTetromino: tetromino!) {
                print("Game Over!")
                pauseGame()
            }
            return
        }
        //see about moving block down
        if moveTetrominoDown() {
            print("Moving tetromino down")
            return
        }
        //see if need to place block
        print("Placing tetromino")
        placeTetromino()
    }
    
    //moving tetrominos for gameplay
    func dropTetromino() {
        while(moveTetrominoDown()) { }
    }
    
    func moveTetrominoRight() -> Bool {
        return moveTetromino(rowOffset: 0, columnOffset: 1)
    }
    
    func moveTetrominoLeft() -> Bool {
        return moveTetromino(rowOffset: 0, columnOffset: -1)
    }
    
    func moveTetrominoDown() -> Bool {
        moveTetromino(rowOffset: -1, columnOffset: 0)
    }
    
    func moveTetromino(rowOffset: Int, columnOffset: Int) -> Bool {
        guard let currentTetromino = tetromino else {return false}
        
        let newTetromino = currentTetromino.moveBy(row: rowOffset, column: columnOffset)
        if isValidTetromino(testTetromino: newTetromino) {
            tetromino = newTetromino
            return true
        }
        return false
    }
    
    func rotateTetromino(clockwise: Bool) {
        guard let currentTetromino = tetromino else { return }
        
        let newTetrominoBase = currentTetromino.rotate(clockwise: clockwise)
        let kicks = currentTetromino.getKicks(clockwise: clockwise)
        
        for kick in kicks{
            let newTetromino = newTetrominoBase.moveBy(row: kick.row, column: kick.column)
            if isValidTetromino(testTetromino: newTetromino) {
                tetromino = newTetromino
                return
            }
        }
    }
    
    func isValidTetromino(testTetromino: Tetromino) -> Bool {
        for block in testTetromino.blocks {
            let row = testTetromino.origin.row + block.row
            if row < 0 || row >= numRows {return false}
            
            let column = testTetromino.origin.column + block.column
            if column < 0 || column >= numColumns {return false}
            
            if gameBoard[column][row] != nil {return false}
        }
        return true
        
    }
    
    func placeTetromino() {
        guard let currentTetromino = tetromino else {
            return
        }
        
        for block in currentTetromino.blocks {
            let row = currentTetromino.origin.row + block.row
            if row < 0 || row >= numRows {continue}
            
            let column = currentTetromino.origin.column + block.column
            if column < 0 || column >= numColumns {continue}
            
            gameBoard[column][row] = TetrisGameBlock(blockType: currentTetromino.blockType)
        }
        tetromino = nil
    }
    //creating extra gameboard and going row by row to see if need to copy line
    //making sure entire row is full of null pieces - if entire row is full
    //dont copy that row over
    func clearLines() -> Bool {
        var newBoard: [[TetrisGameBlock?]] = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        var boardUpdated = false
        var nextRowToCopy = 0
        
        for row in 0...numRows-1 {
            var clearLine = true
            for column in 0...numColumns-1 {
                clearLine = clearLine && gameBoard[column][row] != nil
            }
            
            if !clearLine {
                for column in 0...numColumns-1 {
                    newBoard[column][nextRowToCopy] = gameBoard[column][row]
                }
                nextRowToCopy += 1
            }
            boardUpdated = boardUpdated || clearLine
        }
        if boardUpdated {
            gameBoard = newBoard
        }
        return boardUpdated
    }
}

struct TetrisGameBlock {
    var blockType: BlockType
}

enum BlockType: CaseIterable {
    case i, t, o, j, l, s, z
}

struct Tetromino {
    var origin: BlockLocation
    var blockType: BlockType
    var rotation: Int
    
    var blocks: [BlockLocation] {
        return Tetromino.getBlocks(blockType: blockType, rotation: rotation)
    }
    
    func moveBy(row: Int, column: Int) -> Tetromino {
        let newOrigin = BlockLocation(row: origin.row + row, column: origin.column + column)
        return Tetromino(origin: newOrigin, blockType: blockType, rotation: rotation)
    }
    
    func rotate(clockwise: Bool) -> Tetromino {
        return Tetromino(origin: origin, blockType: blockType, rotation: rotation + (clockwise ? 1 : -1))
    }
    
    func getKicks(clockwise: Bool) -> [BlockLocation] {
        return Tetromino.getKicks(blockType: blockType, rotation: rotation, clockwise: clockwise)
    }
    
    static func getBlocks(blockType: BlockType, rotation: Int = 0) -> [BlockLocation] {
        let allBlocks = getAllBlocks(blockType: blockType)
        
        var index = rotation % allBlocks.count
        if (index < 0) {
            index += allBlocks.count
        }
        
        return allBlocks[index]
    }
    //all block rotations
    static func getAllBlocks(blockType: BlockType) -> [[BlockLocation]] {
        switch blockType {
        case .i:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                BlockLocation(row: 0, column: 2) ],
                    [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1),
                            BlockLocation(row: -2, column: 2)],
                    [BlockLocation(row: -1, column: -1), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1),
                            BlockLocation(row: -1, column: 2)],
                    [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0),
                            BlockLocation(row: -2, column: 0)]]
        case .o:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1),
                BlockLocation(row: 1, column: 0)]]
            
        case .t:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                BlockLocation(row: 1, column: 0)],
                    [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                        BlockLocation(row: 1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                        BlockLocation(row: -1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0),
                        BlockLocation(row: -1, column: 0)]]
        case .j:
            return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0),
                BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0),
                        BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0),
                        BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0),
                        BlockLocation(row: -1, column: -1)]]
                    
        case .l:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0),
                        BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                        BlockLocation(row: -1, column: -1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0),
                        BlockLocation(row: 1, column: -1)]]
                    
        case .s:
            return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0),
                BlockLocation(row: 1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1),
                        BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0),
                        BlockLocation(row: -1, column: -1)],
                    [BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0),
                        BlockLocation(row: -1, column: 0)]]
                    
        case .z:
            return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0),
                BlockLocation(row: 0, column: 1)],
                    [BlockLocation(row: 1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0),
                        BlockLocation(row: -1, column: 0)],
                    [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0),
                        BlockLocation(row: -1, column: 1)],
                    [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1),
                        BlockLocation(row: -1, column: -1)]]
        }
    }
    //creating new
    //going through all blocks and making sure none are above gameboard
    static func createNewTetromino(numRows: Int, numColumns: Int) -> Tetromino {
        let blockType = BlockType.allCases.randomElement()!
        
        var maxRow = 0
        for block in getBlocks(blockType: blockType) {
            maxRow = max(maxRow, block.row)
        }
        let origin = BlockLocation(row: numRows - 1 - maxRow, column: (numColumns-1)/2)
        return Tetromino(origin: origin, blockType: blockType, rotation: 0)
    }
    
    static func getKicks(blockType: BlockType, rotation: Int, clockwise: Bool) -> [BlockLocation] {
        let rotationCount = getBlocks(blockType: blockType).count
        
        var index = rotation % rotationCount
        if index < 0 { index += rotationCount}
        
        var kicks = getAllKicks(blockType: blockType)[index]
        if !clockwise {
            var counterKicks: [BlockLocation] = []
            for kick in kicks {
                counterKicks.append(BlockLocation(row: -1 * kick.row, column: -1 * kick.column))
            }
            kicks = counterKicks
        }
        return kicks
    }
    
    static func getAllKicks(blockType: BlockType) -> [[BlockLocation]] {
        switch blockType {
        case .o:
            return [[BlockLocation(row: 0, column: 0)]]
        case .i:
            return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -2), BlockLocation(row: 0, column: 1),
                BlockLocation(row: -1, column: -2), BlockLocation(row: 2, column: -1)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 2),
                        BlockLocation(row: 2, column: -1), BlockLocation(row: -1, column: 2)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 2), BlockLocation(row: -2, column: -1),
                        BlockLocation(row: 1, column: 2), BlockLocation(row: 1, column: -2)],
                    [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: -2),
                        BlockLocation(row: -2, column: 1), BlockLocation(row: 1, column: -2)]
            ]
        case .j, .l, .s, .z, .t:
            return  [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: 1, column: -1),
                BlockLocation(row: 0, column: -2), BlockLocation(row: -2, column: -1)],
                      [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 1),
                          BlockLocation(row: 2, column: 0), BlockLocation(row: 1, column: 2)],
                      [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1),
                          BlockLocation(row: -2, column: 0), BlockLocation(row: -2, column: 1)],
                      [BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: -1),
                          BlockLocation(row: 2, column: 0), BlockLocation(row: 2, column: -1)]
              ]
        }
    }
}

struct BlockLocation {
    var row: Int
    var column: Int
}
