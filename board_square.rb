require 'board'

class BoardSquare < Board
  def initialize
    self.legal_moves = [
      {:jump => [ 0, +1], :land => [ 0, +2]}, # Across, right
      {:jump => [ 0, -1], :land => [ 0, -2]}, # Across, left
      {:jump => [+1,  0], :land => [+2,  0]}, # Vertical, down
      {:jump => [-1,  0], :land => [-2,  0]}, # Vertical, up
    ]

    self.filled_board = [
      [true, true, true, true, true],
      [true, true, true, true, true],
      [true, true, true, true, true],
      [true, true, true, true, true],
      [true, true, true, true, true],
    ]

    super
  end
end
