class GameOfLife
  def initialize(matrix = nil)
    if matrix
      @start_matrix = matrix
    else
      @start_matrix = generate_matrix
    end

    @next_matrix = @start_matrix.map(&:dup) # object.dup => creates a reference only
  end

  def start
    while true
      pp @start_matrix

      compute_new_grid!

      # To prevent from memory leaks, we use only two matrix and swap them
      @start_matrix = @next_matrix

      sleep(0.5)
    end
  end

  private

  def compute_new_grid!
    # Prevent from having irregular size of rows or cols with `each`
    for x in 0...@start_matrix.size
      for y in 0...@start_matrix[x].size
        calculate_cell_new_state(x, y)
      end
    end
  end

  def calculate_cell_new_state(x, y)
    current_state = @start_matrix[x][y]
    total_neighbors = count_neighbors(x, y)

    # If I'm died but with 3 alive neighbors
    if current_state == 0 && total_neighbors == 3
      @next_matrix[x][y] = 1 # become alive
    # If I'm alive with less than 2 or more than 3 neighbors alive
    elsif current_state == 1 && (total_neighbors < 2 || total_neighbors > 3)
      @next_matrix[x][y] = 0 # must die
    else
      @next_matrix[x][y] = current_state # nothing to change
    end
  end

  def count_neighbors(current_x, current_y)
    sum = 0

    #                                           x   y      x  y      x  y
    #  {x-1,y-1} | {x-1, y} | {x-1,y+1}       (-1, -1) | (-1, 0) | (-1, 1)
    # -----------|----------|-----------     ----------|---------|---------
    #  {x  ,y-1} | {x  , y} | {x,  y+1}       ( 0, -1) | ( 0, 0) | ( 0, 1)
    # -----------|----------|-----------     ----------|---------|---------
    #  {x+1,y-1} | {x+1, y} | {x+1,y+1}       ( 1, -1) | ( 1, 0) | ( 1, 1)

    # When I'm at (0, 0)
    # -1..1        => [-1, 0, 1]
    # When I'm at (2, 3)
    # (2-1)..(2+1) => 1..3
    # 1..3         => [1, 2, 3]

    # Create coordinates dinamically realative to the values of (current_x, current_y)
    ((current_x - 1)..(current_x + 1)).each do |x|
      ((current_y - 1)..(current_y + 1)).each do |y|
        next if x == current_x && y == current_y # not to evaluate the (current_x, current_y) only cells around it
        sum += @start_matrix[x][y] if cell_exists?(x, y)
      end
    end

    sum
  end

  def cell_exists?(x, y)
    # Validate if (x, y) are within the matrix cols and rows size
    # Considere that @start_matrix[x].size will return nil at some point (x | y is out of index)
    # (0...@start_matrix[x].size).to_a.include?(x) && (0...@start_matrix.size).to_a.include?(y)
    # (0...@start_matrix[x].size) === x && (0...@start_matrix.size) === y
    (x >= 0 && @start_matrix[x] && x < @start_matrix[x].size) && (y >= 0 && y < @start_matrix.size)
  end

  def generate_matrix(rows = 5, cols = 5)
    Array.new(rows) { Array.new(cols) { rand(0..1) } }
  end
end

sample_grid = [[1, 0, 0, 0, 0],
               [0, 0, 0, 1, 0],
               [0, 1, 1, 0, 0],
               [0, 0, 1, 1, 0],
               [1, 0, 0, 0, 0]]

matrix_solver = GameOfLife.new
matrix_solver.start
