class Minesweeper
  def initialize
    @solution_board = []
    @mine_coordinates = []
  end

  def start_game
    puts "Welcome to Minesweeper!"
    print "Pick board size (1: 9x9 or 2: 16x16): "
    board_size = gets.chomp
    set_board(board_size)
  end

  def set_board(board_size)
    if board_size == "1"
      size = 9
      num_of_mines = 10
    else
      size = 16
      num_of_mines = 40
    end

    size.times do |row|
      @solution_board << []
      size.times do |col|
        @solution_board[row][col] = '_'
      end
    end

    mine_location(num_of_mines,size) # adds mines to the board
    number_generator                 # adds numbers to the board

  end

  def mine_location(num_of_mines,size)
    until @mine_coordinates.length == num_of_mines
      coordinate = [rand(size),rand(size)]
      @mine_coordinates << coordinate if !@mine_coordinates.include?(coordinate)
    end

    @mine_coordinates.each do |coord|
      x,y = coord
      @solution_board[x][y] = '*'
    end
  end

  def number_generator
    adjacent_hash = get_adjacent_hash
    adjacent_hash.each do |coord, count|
      x,y = coord
      @solution_board[x][y] = "#{count}"
    end
    @solution_board.each { |line| p line }
  end

  def reveal

  end

  def display_board

  end

  def get_adjacent_squares
    adjacent_squares = []
    @mine_coordinates.each do |coord|
      x_diff = -1
      3.times do
        y_diff = -1
        3.times do
          if x_diff == 0 && y_diff == 0
            y_diff += 1
            next
          end
          x, y = coord[0] + x_diff, coord[1] + y_diff
          location = [x, y]
          if x.between?(0,8) && y.between?(0,8) && !@mine_coordinates.include?([x,y])
            adjacent_squares << location
          end
          y_diff += 1
        end
        x_diff += 1
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























