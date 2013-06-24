class Minesweeper
  def initialize
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

    @board = [ ['_'] * size ] * size
    mine_location(num_of_mines,size)
    number_generator

    @board.each { |line| p line }
  end

  def mine_location(num_of_mines,size)
    coordinates = []
    until coordinates.length == num_of_mines
      new_coordinate = [rand(size),rand(size)]
      coordinates << new_coordinate if !coordinates.include?(new_coordinate)
    end
    puts coordinates.length
    coordinates.each do |coord|
      x,y = coord
      @board[x][y] = "*"
    end
  end

  def number_generator

  end

  def reveal

  end
end

mines = Minesweeper.new
mines.start_game























