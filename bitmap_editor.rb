require 'pry'
class BitmapEditor
  attr_accessor :image

  def create_image(x, y)
    return if !x || !y

    @image = Array.new(x).map do |line|
      line = Array.new(y, '0')
    end
  end

  def colours_pixel(x, y, colour)
    return if !x ||
              !y ||
              !colour ||
              !@image

    @image[x][y] = colour
  end

  def fill_region(x, y, colour)
    return if !x ||
              !y ||
              x < 0 ||
              y < 0 ||
              !colour ||
              !@image ||
              @image[x][y] == colour

    old_colour = @image[x][y]
    @image[x][y] = colour
    neighbours = get_neighbours(x, y)
    fill_region(x-1, y, colour) if neighbours[:top] == old_colour
    fill_region(x, y+1, colour) if neighbours[:right] == old_colour
    fill_region(x+1, y, colour) if neighbours[:bottom] == old_colour
    fill_region(x, y-1, colour) if neighbours[:left] == old_colour
  end

  def draw_horizontal_line(x, y1, y2, colour)
    return if !x ||
              !y1 ||
              !y2 ||
              !colour ||
              !@image

    line = @image[x][y1..y2]
    @image[x][y1..y2] = line.map { |pixel| pixel = colour }
  end

  def clear_image
    @image = nil
  end

  def draw_vertical_line(x1, x2, y, colour)
    return if !x1 ||
              !x1 ||
              !y ||
              !colour ||
              !@image

    lines = @image[x1..x2]
    @image[x1..x2] = lines.map do |line|
      line[y] = colour
      line
    end
  end

  private

  def get_neighbours(x, y)
    { top: x > 0 ? @image[x-1][y] : nil,
      right: @image[x][y+1],
      bottom: @image[x+1] ? @image[x+1][y] : nil,
      left: y > 0 ? @image[x][y-1] : nil
    }
  end
end
