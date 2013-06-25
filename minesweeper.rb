# REV: Mostly looks good! The game works ok, could use some added user checks to make sure a valid coordinate is used (crashed otherwise), and allow for unflagging and don't allow for revealing a coordinate that you had already flagged. (And maybe get rid of the quotes on your printed screen.) The biggest concern I had is the hard coding of some "magic numbers" into the code (i mention below in my comments).

require 'time'
require 'yaml'

class Minesweeper
  def initialize
    @solution_board = []
    @player_board = []
    @mine_coordinates = []
    @neighbors_key = [ # REV I like to make these class constants. Not really something that is unique to the instance, or anything that ever changes 
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

  def start_game # REV: excellent! Clear and doesn't contain any logic it shouldn't. 
    puts "Welcome to Minesweeper!"
    puts "new game, load game, or show scoreboard? (n: new, l: load, s: scoreboard)"
    input = gets.chomp
    case input
    when "n"
      print "Pick board size (1: 9x9 or 2: 16x16): "
      board_size = gets.chomp
      set_boards(board_size)
      game
    when "l"
      load
      game
    when"s"
      puts "9: 9x9 or 16: 16x16"
      number = gets.chomp.to_i
      display_scoreboard(number)
      start_game
    when "reset"
      print "Password: "
      password = gets.chomp
      if password == "andyisfreakingawesome"
        reset_scoreboard
      else
        puts "invalid password!"
        start_game
      end
    else
      puts "invalid input!"
      puts
      start_game
    end
  end

  def game # REV: again, nice short method with logic lodged elsewhere. Could be good to make those methods private to further make clear that they are just to be used within the class.
    @start_time = Time.now
    until game_over?
      display_board
      player_turn
    end
    display_scoreboard
  end

  def player_turn 
    puts "choose an action (s: save game, f: flag or r: reveal):"
    action = gets.chomp

    case action
    when "f"
      x,y = get_user_xy
      flag(x,y)
    when "r"
      x,y = get_user_xy
      reveal(x,y)
      if @solution_board[x][y] == "_"
        check_neighbors(x,y)
      end
    when "s"
      save
    when "cheat"
      print "Password: "
      password = gets.chomp
      answer if password == "andyisfreakingawesome"
    else
      puts "invalid input!"
      player_turn
    end
  end

  def game_over?
    unexplored_count = 0

    @player_board.each_index do |row|
      @player_board.each_index do |col|
        if @player_board[row][col] == "B"
          @solution_board[row][col] = "X"
          display_board(true)
          puts "You lose! GAME OVER!"
          return true
        elsif @player_board[row][col] == "*"
          unexplored_count += 1
        end
      end
    end

    if flagged_mines? || unexplored_count == 0
      puts "You Win!"
      @time_taken = Time.now - @start_time
      save_score
      return true
    end

    false
  end

  def get_user_xy
    puts "please enter the coordinates (e.g.: 2,3)"
    input = gets.chomp.split(",").map(&:to_i) # REV: slick
  end
  
  # REV: You have a whole bunch of scoreboard methods bunched together. Why not make a new Scoreboard class?
  
  def display_scoreboard(number = @player_board.length) # REV: Seems to limit you to square board!
    puts "High Scores for #{number}x#{number}!"
    load_scores(number)[0..9].each_with_index do |score,index|
      name, time = score
      time = time.to_s
      puts "#{index + 1}. #{name} #{time.rjust(20)} seconds"
    end
  end

  def reset_scoreboard
    File.open("high_scores_9", 'w') do |file|
      file.puts [].to_yaml
    end

    File.open("high_scores_16", 'w') do |file|
      file.puts [].to_yaml
    end
  end

  def load_scores(number = @player_board.length)
    scoreboard = YAML::load(File.read("high_scores_#{number}"))
  end

  def save_score
    print "Enter your name: "
    name = gets.chomp
    entry = [name, @time_taken]
    number = @player_board.length

    old_scoreboard = load_scores(number)
    new_scoreboard = old_scoreboard << entry

    new_scoreboard = new_scoreboard.sort_by {|name,time| time}

    File.open("high_scores_#{number}", "w") do |file|
      file.puts new_scoreboard.to_yaml
    end

    puts "Scoreboard Updated!"
  end

  def save
    print "file name: "
    file_name = gets.chomp

    temp = [@player_board, @solution_board]

    File.open(file_name, 'w') do |file| # REV: good use of block, no need to close file this way! I probably should have done this too...
      file.puts temp.to_yaml
    end

    puts "game saved!"
    start_game
  end

  def load
    print "enter file name or quit to go back to menu: "
    file_name = gets.chomp

    if File.exists?(file_name)
      load_file = YAML::load(File.read(file_name))
    elsif file_name == "quit"
      start_game
    else
      puts "invalid file name!"
      load
    end
    @player_board, @solution_board = load_file
  end
  
  # REV: interesting way to save and load game. it's good that you only need to keep track of two variables! But it seems like you aren't keeping track of time between save and load. ie, if you load a game that is one move away from winning, won't that give you a high score?

  def reveal(x,y)
    @player_board[x][y] = @solution_board[x][y]
  end

  def flag(x,y)
    @player_board[x][y] = 'F'
  end

  def check_neighbors(x1,y1)
    adjacent_squares = []  # REV: could be good to break off into separate adjacent_squares method, that returns an array of coordinates
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

    if count == 10 && @player_board.length == 9 # REV: might be better not to hard code in constants like this. You can set them as class constants so you can see exactly where they come from
      true
    elsif count == 40
      true
    else
      false
    end
  end

  def display_board(solution_board = false)
    print "   "
    @solution_board.each_index {|index| print "#{index}".center(5)}
    puts
    if solution_board == true # REV: if solution_board, no need for == true
      @solution_board.each_with_index do |line, i|
        print "#{i}".center(3)
        print line
        puts
      end
    end
    @player_board.each_with_index do |line, i|
      print "#{i}".center(3)
      print line
      puts
    end
  end

  def set_boards(board_size)
    if board_size == "1"
      size = 9 # REV: another place with a 'magic number' hard coded into code. A good idea to avoid these, and define some constants up top. Something like BEGINNER_SIZE = 9, then you can do size = BEGINNER_SIZE and everyone knows what you are talking about
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

    @mine_coordinates.each do |coord| # REV: Could you shovel coordinate onto @mine_coordinates and set @solution_board at the same time? If so, maybe that means that you don't really need both instance variables
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
    size = @solution_board.length - 1 # REV: seems to be hard coding in square boards

    @mine_coordinates.each do |coord|
      @neighbors_key.each do |diff|
        x, y = coord[0] + diff[0], coord[1] + diff[1]
        location = [x,y]
        if x.between?(0,size) && y.between?(0,size) && !@mine_coordinates.include?([x,y])
          adjacent_squares << location
        end
      end
    end
    adjacent_squares
  end

  def get_adjacent_hash # REV: Seems like you could just make an adjacent hash without making the array, no? Instead of adjacent_squares << location, you could just do adjacent_squares[location] += 1
    adjacent_squares = get_adjacent_squares 
    adjacent_hash = Hash.new(0)
    adjacent_squares.each do |coord|
      adjacent_hash[coord] += 1
    end
    adjacent_hash
  end

  def answer
    print "   "
    @solution_board.each_index {|index| print "#{index}".center(5)}
    puts
    @solution_board.each_with_index do |line, i|
      print "#{i}".center(3)
      print line
      puts
    end
  end
end

mines = Minesweeper.new
mines.start_game