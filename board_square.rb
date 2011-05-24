require 'board'

class BoardSquare < Board
  def initialize(size=5)
    self.legal_moves = [
      {:jump => [ 0, +1], :land => [ 0, +2]}, # Across, right
      {:jump => [ 0, -1], :land => [ 0, -2]}, # Across, left
      {:jump => [+1,  0], :land => [+2,  0]}, # Vertical, down
      {:jump => [-1,  0], :land => [-2,  0]}, # Vertical, up
    ]

    self.filled_board = []
    size.times do |row_index|
      self.filled_board[row_index] = []
      size.times do |col_index|
        self.filled_board[row_index][col_index] = true
      end
    end

    super
  end
end
