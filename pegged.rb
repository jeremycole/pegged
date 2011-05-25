require 'board'

class Pegged
  attr_accessor :board
  attr_accessor :solutions, :total_solutions
  attr_accessor :move_stack, :move_count
  attr_accessor :time_start, :time_finish

  def initialize(initial_board=nil)
    @board              = initial_board
    @solutions          = Hash.new(0)
    @total_solutions    = 0
    @time_start         = nil
    @time_finish        = nil
    @move_stack         = []
    @move_count         = Hash.new(0)
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

  def print_solution
    r = board.remaining
    printf "Solution for %i peg%s remaining:\n", r, (r==1) ? "" : "s"
    step_n = 0
    move_stack.each do |step|
      from_row, from_col = step[:from]
      land_row, land_col = step[:land]
      printf "%2i: %i, %i -> %i, %i\n",
        step_n += 1,
        from_row, from_col,
        from_row+land_row, from_col+land_col
    end
  end

  def each_recursive_solution
    board.each_position(true).to_a.each do |from_row, from_col|
      board.each_possible_move(from_row, from_col).to_a.each do |move|
        this_move = move.dup
        this_move[:from] = [from_row, from_col]
        forward_move! from_row, from_col, this_move
        if board.solved? then
          yield move_stack
        else
          each_recursive_solution do |stack|
            yield stack
          end
        end
        reverse_move! from_row, from_col, this_move
      end
    end
  end

  def each_solution
    self.time_start = Time.now
    self.total_solutions = 0
    self.solutions.clear
    self.move_stack.clear
    self.move_count.clear
    each_recursive_solution do |stack|
      self.total_solutions += 1
      self.solutions[board.remaining] += 1
      self.time_finish = Time.now
      yield stack
    end
  end

  def solve!(maximum_remaining=nil)
    maximum_remaining ||= board.remaining
    each_solution do |stack|
      yield if block_given?
    end
    true
  end

  def solution_summary
    raise "Not solved yet" if time_start.nil?
    printf "Solutions: %8i (%8.2f/s)\n", total_solutions,
      total_solutions / (time_finish - time_start)
    solutions.sort.each do |pegs_remaining, solution_count|
      printf "  %2i remaining: %6i solutions\n", pegs_remaining, solution_count
    end
    printf "\n"
  end
  
  def reset!
    board.load!
    board.random!
  end
end
