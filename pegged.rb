class Pegged
  attr_accessor :board, :stack, :solutions

  # A fully filled peg board used for initialization.
  FILLED_BOARD = [
    [true, nil,  nil,  nil,  nil ],
    [true, true, nil,  nil,  nil ],
    [true, true, true, nil,  nil ],
    [true, true, true, true, nil ],
    [true, true, true, true, true],
  ]

  # All possible moves from a given position, as arrays of [row, col].
  #   :jump is the peg that is jumped over (and removed).
  #   :land is where the peg will land (and must be empty at start).
  POSSIBLE_MOVES = [
    {:jump => [ 0, +1], :land => [ 0, +2]}, # Across, right
    {:jump => [ 0, -1], :land => [ 0, -2]}, # Across, left
    {:jump => [+1,  0], :land => [+2,  0]}, # Diagonal, down, left
    {:jump => [+1, +1], :land => [+2, +2]}, # Diagonal, down, right
    {:jump => [-1,  0], :land => [-2,  0]}, # Diagonal, up, right
    {:jump => [-1, -1], :land => [-2, -2]}, # Diagonal, up, left
  ]

  def initialize(board=nil)
    @board        = nil
    @stack        = []
    @solutions    = []
    load! board
  end

  def to_s
    return nil unless @board
    s = ""
    (0..4).each do |row|
      s += (" " * (5 - row))
      (0..4).each do |col|
        s += "* " if @board[row][col] == true
        s += ". " if @board[row][col] == false
        s += "  " if @board[row][col] == nil
      end
      s += "\n"
    end
    s
  end

  alias inspect to_s
  
  def is_possible_move?(row, col, move)
    j_row, j_col = move[:jump]
    l_row, l_col = move[:land]
  
    # Bounds checking
    return false unless (0..4).include?(row + l_row)
    return false unless (0..4).include?(col + l_col)
    return false if @board[row + j_row][col + j_col] == nil
    return false if @board[row + l_row][col + l_col] == nil
  
    # Legality checking
    return false if @board[row + j_row][col + j_col] == false
    return false if @board[row + l_row][col + l_col] == true
  
    true
  end

  def count_state(state)
    count = 0
    @board.each do |row|
      row.each do |cell|
        count += 1 if cell == state
      end
    end
    count
  end

  def remaining
    count_state true
  end

  def each_position(state)
    (0..4).each do |row|
      (0..4).each do |col|
        yield row, col if @board[row][col] == state
      end
    end
  end

  def array_each_position(state)
    result = []
    each_position(state) do |row, col|
      result << [row, col]
    end
    result
  end

  def each_possible_move(row, col)
    POSSIBLE_MOVES.each do |move|
      l_row, l_col = move[:land]
      yield move if is_possible_move?(row, col, move)
    end
  end

  def array_each_possible_move(row, col)
    result = []
    each_possible_move(row, col) do |move|
      result << move
    end
    result
  end

  def solved?
    each_position(true) do |from_row, from_col|
      each_possible_move(from_row, from_col) do |move|
        return false
      end
    end
    true
  end

  def set!(row, col, value)
    @board[row][col] = value
    @board
  end

  def remove!(row, col)
    set! row, col, false
  end

  def place!(row, col)
    set! row, col, true
  end

  def random!
    remove! row = (rand*5).floor, (rand*row).floor
  end

  def move!(row, col, move, direction)
    return false unless is_possible_move? row, col, move
    j_row, j_col = move[:jump]
    l_row, l_col = move[:land]
    remove! row, col
    remove! row + j_row, col + j_col
    place!  row + l_row, col + l_col
    move
  end

  def forward_move!(row, col, move)
    move! row, col, move, true
  end

  def reverse_move!(row, col, move)
    move! row, col, move, false
  end

  def solution
    printf "Solution for %i pegs remaining:\n", remaining
    @stack.each do |step|
      from_row, from_col = step[:from]
      land_row, land_col = step[:land]
      printf "%i, %i -> %i, %i\n",
        from_row, from_col,
        from_row+land_row, from_col+land_col
    end
  end

  def solve!
    array_each_position(true).each do |from_row, from_col|
      array_each_possible_move(from_row, from_col).each do |move|
        move[:from] = [from_row, from_col]
        printf "Position: %i, %i | Possible move: %2i, %2i\n",
          from_row, from_col, *move[:land]
        @stack << move
        forward_move! from_row, from_col, move
        if solved? then
          puts "Solved!"
          puts self
          solution
          reverse_move! from_row, from_col, @stack.pop
        else
          solve!
        end
      end
    end
    true
  end

  def load!(board=nil)
    @board = Marshal.load(Marshal.dump(board ? board : FILLED_BOARD))
  end
end
