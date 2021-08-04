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
    
    init(numRows: Int = 23, numColumns: Int = 10) {
        self.numRows = numRows
        self.numColumns = numColumns
        
        //allowing access to gameboard -> gameBoard[][] columns / rows respectivly
        gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
    }
    
    func blockClicked(row: Int, column: Int){
        print("Column: \(column), Row: \(row)")
        if gameBoard[column][row] == nil{
            gameBoard[column][row] = TetrisGameBlock(blockType: BlockType.allCases.randomElement()!)
        }else {
            gameBoard[column][row] = nil
        }
    }
}

struct TetrisGameBlock {
    var blockType: BlockType
}

enum BlockType: CaseIterable {
    case i, t, o, j, l, s, z
}
