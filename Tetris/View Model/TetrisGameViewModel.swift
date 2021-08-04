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
        tetrisGameModel.gameBoard.map{$0.map(convertToSquare)}
    }
    
    var anyCancellable: AnyCancellable?
    
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
}

struct TetrisGameSquare{
    var color: Color
}
