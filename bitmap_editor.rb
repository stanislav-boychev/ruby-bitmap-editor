class BitmapEditor
  attr_accessor :image
  X_MAX = 250
  Y_MAX = 250

  def create_image(x, y)
    return if !x || !y

    @image = Array.new(x).map do |line|
      line = Array.new(y, 'O')
    end
  end

  def colours_pixel(x, y, colour)
    return if !valid_coordinates?(x: [x], y: [y]) || !colour

    @image[x][y] = normalize_colour(colour)
  end

  def fill_region(x, y, colour)
    normalized_colour = normalize_colour(colour)
    # Exit condtions for recursive:
    # 1. If x or y are less than zero we cannot access such
    #    elements in the image
    # 2. If a image element is the same colour as new there isn't point
    #    to change it. Also it avoids endless cycling between two neighbouring
    #    elemens
    return if !valid_coordinates?(x: [x], y: [y]) ||
              !colour ||
              @image[x][y] == normalized_colour

    old_colour = @image[x][y]
    @image[x][y] = normalized_colour

    neighbours = get_neighbours(x, y)

    # Recursively call fill_region on each neighbour
    fill_region(x-1, y, colour) if neighbours[:top] == old_colour
    fill_region(x, y+1, colour) if neighbours[:right] == old_colour
    fill_region(x+1, y, colour) if neighbours[:bottom] == old_colour
    fill_region(x, y-1, colour) if neighbours[:left] == old_colour
  end

  def draw_horizontal_line(x, y1, y2, colour)
    return if !valid_coordinates?(x: [x], y: [y1, y2]) || !colour

    line = @image[x][y1..y2]
    @image[x][y1..y2] = line.map { |pixel| pixel = normalize_colour(colour) }
  end

  def clear_image
    @image = nil
  end

  def draw_vertical_line(x1, x2, y, colour)
    return if !valid_coordinates?(x: [x1, x2], y: [y]) || !colour

    lines = @image[x1..x2]
    @image[x1..x2] = lines.map do |line|
      line[y] = normalize_colour(colour)
      line
    end
  end

  def image?
    @image && @image.any? && @image.first.is_a?(Array) && @image.first.any?
  end

  def max_x
    return X_MAX unless image?
    return @image.size
  end

  def max_y
    return Y_MAX unless image?
    return @image.first.size
  end

  private

  def normalize_colour(colour)
    colour[0].upcase
  end

  def valid_coordinates?(coordinates = {})
    return unless image?

    x_coordinates_valid = coordinates[:x].reduce(true) do |product, x|
      product &&
      x &&
      x >= 0 &&
      x < max_x
   end

    y_coordinates_valid = coordinates[:y].reduce(true) do |product, y|
      product &&
      y &&
      y >= 0 &&
      y < max_y
    end

    x_coordinates_valid && y_coordinates_valid
  end

  def get_neighbours(x, y)
    { top: x > 0 ? @image[x-1][y] : nil,
      right: @image[x][y+1],
      bottom: @image[x+1] ? @image[x+1][y] : nil,
      left: y > 0 ? @image[x][y-1] : nil
    }
  end
end
