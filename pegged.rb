require 'board'

class Pegged
  attr_accessor :board, :solutions, :move_stack, :move_count, :move_progress

  def initialize(initial_board=nil)
    @board        = initial_board
    @solutions    = []
    @move_stack   = []
    @move_count   = Hash.new(0)
    @move_progress = []
  end

  def forward_move!(row, col, move)
    move_count[move_stack.length] += 1
    move_stack.push move
    board.move! row, col, move, true
  end

  def reverse_move!(row, col, move)
    move_stack.pop
    move_count[move_stack.length] += 1
    board.move! row, col, move, false
  end

  def print_solution(stack)
    r = board.remaining
    printf "Solution for %i peg%s remaining:\n", r, (r==1) ? "" : "s"
    step_n = 0
    stack.each do |step|
      from_row, from_col = step[:from]
      land_row, land_col = step[:land]
      printf "%2i: %i, %i -> %i, %i\n",
        step_n += 1,
        from_row, from_col,
        from_row+land_row, from_col+land_col
    end
  end

  def each_solution
    all_positions = board.each_position(true).to_a
    all_positions.each_with_index do |from, position_index|
      move_progress[move_stack.size] = [position_index+1, all_positions.size]
      from_row, from_col = *from
      all_moves = board.each_possible_move(from_row, from_col).to_a
      all_moves.each_with_index do |move, move_index|
        this_move = move.dup
        this_move[:from] = [from_row, from_col]
        forward_move! from_row, from_col, this_move
        if board.solved? then
          yield move_stack
        else
          each_solution do |stack|
            yield stack
          end
        end
        reverse_move! from_row, from_col, this_move
      end
    end
  end

  def solve!(maximum_remaining=nil)
    maximum_remaining ||= board.remaining
    each_solution do |stack|
      if board.remaining <= maximum_remaining
        puts board
        print_solution stack
      end
    end
    true
  end

  def solution_summary!
    solutions = Hash.new(0)
    each_solution do |stack|
      solutions[board.remaining] += 1
      move_progress.each_with_index do |level, depth|
        printf "%2i: %3i / %3i (%8i)\n", depth, level[0], level[1], move_count[depth]
      end
      printf "\n"
    end
    solutions.sort.each do |pegs_remaining, solution_count|
      printf "%2i remaining: %6i solutions\n", pegs_remaining, solution_count
    end
    true
  end
  
  def reset!
    board.load!
  end
end
