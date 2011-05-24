class Board
  attr_accessor :board, :legal_moves, :filled_board

  def initialize(board=nil)
    # All possible moves from a given position, as arrays of [row, col].
    #   :jump is the peg that is jumped over (and removed).
    #   :land is where the peg will land (and must be empty at start).
    @legal_moves ||= nil

    # A fully filled peg board used for initialization.
    @filled_board   ||= nil

    @board        = nil
  end

  def to_s
    return nil unless board
    s = ""
    board.each_with_index do |row, row_index|
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

  def load!(load_board=nil)
    self.board = Marshal.load(Marshal.dump(load_board ? load_board : filled_board))
  end

  def is_possible_move?(row, col, move, direction=true)
    j_row, j_col = move[:jump]
    l_row, l_col = move[:land]
  
    return false if row + j_row < 0
    return false if col + j_col < 0
    return false if row + l_row < 0
    return false if col + l_col < 0

    # Bounds checking
    begin
      return false if board.fetch(row + j_row).fetch(col + j_col) == nil
      return false if board.fetch(row + l_row).fetch(col + l_col) == nil
    rescue IndexError
      return false
    end
  
    # Legality checking
    return false unless board[row][col] == direction
    return false unless board[row + j_row][col + j_col] == direction
    return false unless board[row + l_row][col + l_col] == !direction
  
    true
  end

  def count_state(state)
    board.inject(0) do |count, row|
      count += row.count(state)
    end
  end

  def remaining
    count_state true
  end

  def each_position(state)
    if block_given?
      board.each_with_index do |row, row_index|
        row.each_with_index do |col, col_index|
          yield row_index, col_index if col == state
        end
      end
      true
    else
      Enumerable::Enumerator.new(self, :each_position, state)
    end
  end

  def each_possible_move(row, col)
    if block_given?
      legal_moves.each do |move|
        yield move if is_possible_move?(row, col, move)
      end
      true
    else
      Enumerable::Enumerator.new(self, :each_possible_move, row, col)
    end
  end

  def solved?
    each_position(true) do |from_row, from_col|
      each_possible_move(from_row, from_col) do |move|
        return false
      end
    end
    true
  end

  def get(row, col)
    board[row][col]
  end

  def set!(row, col, value)
    board[row][col] = value
  end

  def remove!(row, col)
    set! row, col, false
  end

  def place!(row, col)
    set! row, col, true
  end

  def random!
    remove! row = (rand*board.size).floor, (rand*board[row].size).floor
  end

  def move!(row, col, move, direction)
    j_row, j_col = move[:jump]
    l_row, l_col = move[:land]
    set! row, col, !direction
    set! row + j_row, col + j_col, !direction
    set! row + l_row, col + l_col, direction
    move
  end
end
