//
//  TetrisGameView.swift
//  Tetris
//
//  Created by Hannah Friedman on 8/3/21.
//

import SwiftUI

struct TetrisGameView: View {
    
    @ObservedObject var tetrisGame = TetrisGameViewModel()
    
    var body: some View {
        GeometryReader{(geometry: GeometryProxy) in
            self.drawBoard(boundingRect: geometry.size)
        }
        .gesture(tetrisGame.getMoveGesture())
        .gesture(tetrisGame.getRotateGesture())
    }
    
    func drawBoard(boundingRect: CGSize) -> some View {
        let columns = self.tetrisGame.numColumns
        let rows = self.tetrisGame.numRows
        let blockSize = min(boundingRect.width/CGFloat(columns), boundingRect.height/CGFloat(rows))
        //horizontal (x) and vertical (y) padding for game board
        let xoffset = (boundingRect.width - blockSize*CGFloat(columns))/2
        let yoffset = (boundingRect.height - blockSize*CGFloat(rows))/2
        let gameBoard = self.tetrisGame.gameBoard
        
        return ForEach(0...columns-1, id:\.self) { (column: Int) in
            ForEach(0...rows-1, id:\.self) { (row: Int) in
                Path { path in
                    let x = xoffset + blockSize * CGFloat(column)
                    let y = boundingRect.height - yoffset - blockSize * CGFloat(row+1)
                    
                    let rect = CGRect(x: x, y: y, width: blockSize, height: blockSize)
                    path.addRect(rect)
                }
                .fill(gameBoard[column][row].color)
        }
    }
}

    struct TetrisGameView_Previews: PreviewProvider {
        static var previews: some View {
            TetrisGameView()
        }
    }
}
