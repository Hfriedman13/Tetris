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
    }
    
    func drawBoard(boundingRect: CGSize) -> some View {
        let columns = self.tetrisGame.numColumns
        let rows = self.tetrisGame.numRows
        let blockSize = min(boundingRect.width/CGFloat(columns), boundingRect.height/CGFloat(rows))
        //horizontal (x) and vertical (y) padding for game board
        let xoffset = (boundingRect.width - blockSize*CGFloat(columns))/2
        let yoffset = (boundingRect.height - blockSize*CGFloat(rows))/2
        
        return ForEach(0...columns-1, id:\.self) { (column: Int) in
            ForEach(0...rows-1, id:\.self) { (row: Int) in
                Path { path in
                    let x = xoffset + blockSize * CGFloat(column)
                    let y = boundingRect.height - yoffset - blockSize * CGFloat(row+1)
                    
                    let rect = CGRect(x: x, y: y, width: blockSize, height: blockSize)
                    path.addRect(rect)
                }
                .fill(self.tetrisGame.gameBoard[column][row].color)
                .onTapGesture {
                    self.tetrisGame.squareClicked(row: row, column: column)
                }
        }
    }
}

    struct TetrisGameView_Previews: PreviewProvider {
        static var previews: some View {
            TetrisGameView()
        }
    }
}
