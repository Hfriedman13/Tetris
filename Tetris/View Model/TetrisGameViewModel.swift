//
//  TetrisGameViewModel.swift
//  Tetris
//
//  Created by Hannah Friedman on 8/3/21.
//

import SwiftUI
import Combine

class TetrisGameViewModel: ObservableObject {
    @Published var tetrisGameModel = TetrisGameModel()
    
    var numRows: Int {tetrisGameModel.numRows}
    var numColumns: Int {tetrisGameModel.numColumns}
    var gameBoard: [[TetrisGameSquare]] {
        var board = tetrisGameModel.gameBoard.map{$0.map(convertToSquare)}
        
        if let tetromino = tetrisGameModel.tetromino{
            for blockLocation in tetromino.blocks{
                board[blockLocation.column + tetromino.origin.column][blockLocation.row + tetromino.origin.row] = TetrisGameSquare(color: getColor(blockType: tetromino.blockType))
            }
        }
        return board
    }
    
    var anyCancellable: AnyCancellable?
    var lastMoveLocation: CGPoint?
    
    init() {
        anyCancellable = tetrisGameModel.objectWillChange.sink {
            self.objectWillChange.send()
        }
    }
    
    func convertToSquare(block: TetrisGameBlock?) -> TetrisGameSquare {
        return TetrisGameSquare(color: getColor(blockType: block?.blockType))
    }
    
    func getColor(blockType: BlockType?) -> Color {
        switch blockType {
        case .i:
            return .tetrisLightBlue
        case .j:
            return .tetrisDarkBlue
        case .l:
            return .tetrisOrange
        case .o:
            return .tetrisYellow
        case .s:
            return .tetrisGreen
        case .t:
            return .tetrisPurple
        case .z:
            return .tetrisRed
        case .none:
            return .tetrisBlack
        }
    }
    
    func squareClicked(row: Int, column: Int){
        tetrisGameModel.blockClicked(row: row, column: column)
    }
    
    func getMoveGesture() -> some Gesture {
        return DragGesture()
        .onChanged(onMoveChanged(value:))
        .onEnded(onMoveEnded(_:))
    }
    
    func onMoveChanged(value: DragGesture.Value){
        guard  let start = lastMoveLocation else {
            lastMoveLocation = value.location
            return
        }
        let xDiff = value.location.x - start.x
        if xDiff > 10 {
            print("Moving right")
            let _ = tetrisGameModel.moveTetrominoRight()
            lastMoveLocation = value.location
            return
        }
        if xDiff < -10 {
            print("Moving left")
            let _ = tetrisGameModel.moveTetrominoLeft()
            lastMoveLocation = value.location
            return
        }
        
        let yDiff = value.location.y - start.y
        if yDiff > 10 {
            print("Moving down")
            let _ = tetrisGameModel.moveTetrominoDown()
            lastMoveLocation = value.location
            return
            
        }
        if yDiff < -10 {
            print("Dropping")
            tetrisGameModel.dropTetromino()
            lastMoveLocation = value.location
            return
        }
    }
    
    func onMoveEnded(_: DragGesture.Value) {
        lastMoveLocation = nil
    }
}

struct TetrisGameSquare{
    var color: Color
}
