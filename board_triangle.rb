require 'board'

class BoardTriangle < Board
  def initialize
    self.legal_moves = [
      {:jump => [ 0, +1], :land => [ 0, +2]}, # Across, right
      {:jump => [ 0, -1], :land => [ 0, -2]}, # Across, left
      {:jump => [+1,  0], :land => [+2,  0]}, # Diagonal, down, left
      {:jump => [+1, +1], :land => [+2, +2]}, # Diagonal, down, right
      {:jump => [-1,  0], :land => [-2,  0]}, # Diagonal, up, right
      {:jump => [-1, -1], :land => [-2, -2]}, # Diagonal, up, left
    ]

    self.filled_board = [
      [true, nil,  nil,  nil,  nil ],
      [true, true, nil,  nil,  nil ],
      [true, true, true, nil,  nil ],
      [true, true, true, true, nil ],
      [true, true, true, true, true],
    ]

    super
  end

  def to_s
    return nil unless board
    s = ""
    board.each_with_index do |row, row_index|
      s += (" " * (5 - row_index))
      row.each_with_index do |col, col_index|
        s += "* " if col == true
        s += ". " if col == false
        s += "  " if col == nil
      end
      s += "\n"
    end
    s
  end
  alias inspect to_s
end
