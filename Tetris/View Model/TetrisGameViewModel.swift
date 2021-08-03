//
//  TetrisGameViewModel.swift
//  Tetris
//
//  Created by Hannah Friedman on 8/3/21.
//

import SwiftUI

class TetrisGameModelView: ObservableObject {
    var numRows: Int
    var numColumns: Int
    @Published var gameBoard: [[TetrisGameSquare]]
    
    init(numRows: Int = 23, numColumns: Int = 10) {
        self.numRows = numRows
        self.numColumns = numColumns
        
        //allowing access to gameboard -> gameBoard[][] columns / rows respectivly 
        gameBoard = Array(repeating: Array(repeating: TetrisGameSquare(color: Color.black), count: numRows), count: numColumns)
    }
}

struct TetrisGameSquare{
    var color: Color
}
