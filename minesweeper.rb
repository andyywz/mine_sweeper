class Minesweeper
  def initialize
    @solution_board = []
    @player_board = []
    @mine_coordinates = []
    @neighbors_key = [
      [-1,-1],
      [-1,0],
      [-1,1],
      [0,-1],
      [0,1],
      [1,-1],
      [1,0],
      [1,1]
    ]
  end

  def start_game
    puts "Welcome to Minesweeper!"
    print "Pick board size (1: 9x9 or 2: 16x16): "
    board_size = gets.chomp
    set_boards(board_size)

    until game_over?
      display_board
      player_turn
    end

    puts "game over!"
  end

  def player_turn
    puts "choose an action (f: flag or r: reveal):"
    action = gets.chomp
    puts "please enter the coordinates (e.g.: 2,3)"
    input = gets.chomp.split(",").map(&:to_i)
    x,y = input

    if action == 'f'
      flag(x,y)
    elsif action == 'r'
      reveal(x,y)
      if @solution_board[x][y] == "_"
        check_neighbors(x,y)
      end
    end
  end

  def reveal(x,y)
    @player_board[x][y] = @solution_board[x][y]
  end

  def flag(x,y)
    @player_board[x][y] = 'F'
  end

  def check_neighbors(x1,y1)
    adjacent_squares = []
    @neighbors_key.each do |diff|
      x, y = x1 + diff[0], y1 + diff[1]
      location = [x,y]
      if x.between?(0,8) && y.between?(0,8) && !@mine_coordinates.include?([x,y])
        adjacent_squares << location
      end
    end

    adjacent_squares.each do |coord|
      next if @player_board[coord[0]][coord[1]] != "*"
      next if @solution_board[coord[0]][coord[1]] == "B"
      if @solution_board[coord[0]][coord[1]] == "_"
        reveal(coord[0],coord[1])
        check_neighbors(coord[0],coord[1])
      else
        reveal(coord[0],coord[1])
      end
    end
  end

  def flagged_mines?
    count = 0
    @player_board.each_index do |row|
      @player_board.each_index do |col|
        if @player_board[row][col] == "F" && @solution_board[row][col] = "B"
          count += 1
        end
      end
    end

    if count == 10 && @player_board.length == 9
      true
    elsif count == 40
      true
    else
      false
    end
  end

  def game_over?
    unexplored_count = 0
    @player_board.each_index do |row|
      @player_board.each_index do |col|
        if @player_board[row][col] == "B"
          @solution_board[row][col] = "X"
          display_board(true)
          return true
        elsif @player_board[row][col] == "*"
          unexplored_count += 1
        end
      end
    end
    return true if flagged_mines?
    return true if unexplored_count == 0
    false
  end

  def display_board(solution_board = false)
    @solution_board.each {|line| p line} if solution_board == true
    @player_board.each {|line| p line}
  end

  def set_boards(board_size)
    if board_size == "1"
      size = 9
      num_of_mines = 10
    else
      size = 16
      num_of_mines = 40
    end

    set_solution_board(num_of_mines, size)
    set_player_board(size)
  end

  def set_solution_board(num_of_mines, size)
    @solution_board += create_default_board(size,true)

    mine_location(num_of_mines,size) # adds mines to the board
    number_generator                 # adds numbers to the board

    @solution_board.each { |line| p line }
  end

  def set_player_board(size)
    @player_board += create_default_board(size)
  end

  def create_default_board(size,solution_board = false)
    board = []
    size.times do |row|
      board << []
      size.times do |col|
        board[row][col] = '_' if solution_board == true
        board[row][col] = '*' if solution_board == false
      end
    end
    board
  end

  def mine_location(num_of_mines,size)
    until @mine_coordinates.length == num_of_mines
      coordinate = [rand(size),rand(size)]
      @mine_coordinates << coordinate if !@mine_coordinates.include?(coordinate)
    end

    @mine_coordinates.each do |coord|
      x,y = coord
      @solution_board[x][y] = 'B'
    end
  end

  def number_generator
    adjacent_hash = get_adjacent_hash
    adjacent_hash.each do |coord, count|
      x,y = coord
      @solution_board[x][y] = "#{count}"
    end
  end

  def get_adjacent_squares
    adjacent_squares = []

    @mine_coordinates.each do |coord|
      @neighbors_key.each do |diff|
        x, y = coord[0] + diff[0], coord[1] + diff[1]
        location = [x,y]
        if x.between?(0,8) && y.between?(0,8) && !@mine_coordinates.include?([x,y])
          adjacent_squares << location
        end
      end
    end
    adjacent_squares
  end

  def get_adjacent_hash
    adjacent_squares = get_adjacent_squares
    adjacent_hash = Hash.new(0)
    adjacent_squares.each do |coord|
      adjacent_hash[coord] += 1
    end
    adjacent_hash
  end

  def answer
    @solution_board.each { |line| p line }
  end
end

mines = Minesweeper.new
mines.start_game























