#!/usr/bin/env ruby
require './bitmap_editor'

class Task
  def initialize
    @bitmap_editor = BitmapEditor.new
  end

  def run
    begin
      line = readline
      command, args =  parse_command(line)
      next if command == :terminate
      execute_command(command, args)
    end while command != :terminate
  end

  private

  def parse_command(command_line)
    command, *args = command_line.split(' ')
    command = normalize_command(command)
    case command
    when :i
      [:insert, args]
    when :c
      :clear
    when :s
      :show
    when :l
      [:colour, args]
    when :h
      [:draw_horizontal, args]
    when :v
      [:draw_vertical, args]
    when :f
      [:fill_region, args]
    when :x then :terminate
      :terminate
    end
  end

  def execute_command(command, args)
    unless command
      p 'Unknown command'
      return
    end

    send("handle_#{command}", @bitmap_editor, *args)
  end

  def normalize_command(command)
    return unless command

    command.downcase.to_sym
  end

  def handle_insert(bitmap_editor, *args)
    if !is_number?(args[0]) || !is_number?(args[1])
      p not_a_number_message
      return
    end

    x, y = args[0].to_i, args[1].to_i

    max = max_coordinates(bitmap_editor)
    if x < 1 || x > max[:x]
      p invalid_coordinate_message 'row', x, 1, max[:x]
      return
    end

    if y < 1 || y > max[:y]
      p invalid_coordinate_message 'column', y, 1, max[:y]
      return
    end

    bitmap_editor.create_image(x, y)
  end

  def handle_colour(bitmap_editor, *args)
    unless bitmap_editor.image?
      p no_image_message
      return
    end

    if !is_number?(args[0]) || !is_number?(args[1])
      p not_a_number_message
      return
    end

    x, y = args[0].to_i, args[1].to_i
    colour = args[2]

    max = max_coordinates(bitmap_editor)
    if x < 0 || x > max[:x] - 1
      p invalid_coordinate_message 'row', x, 0, max[:x] - 1
      return
    end

    if y < 0 || y > max[:y] - 1
      p invalid_coordinate_message 'column', y, 0, max[:y] - 1
      return
    end

    if !is_valid_colour? colour
      p invalid_colour_message colour
      return
    end

    bitmap_editor.colours_pixel(x, y, colour)
  end

  def handle_clear(bitmap_editor)
    bitmap_editor.clear_image
  end

  def handle_draw_horizontal(bitmap_editor, *args)
    if !is_number?(args[0]) || !is_number?(args[1]) || !is_number?(args[2])
      p not_a_number_message
      return
    end

    unless bitmap_editor.image?
      p no_image_message
      return
    end

    x = args[0].to_i
    y1 = [args[1].to_i, args[2].to_i].min
    y2 = [args[1].to_i, args[2].to_i].max
    colour = args[3]

    max = max_coordinates(bitmap_editor)
    if x < 0 || x > max[:x] - 1
      p invalid_coordinate_message 'row', x, 0, max[:x] - 1
      return
    end

    if y1 < 0 || y1 > max[:y] - 1
      p invalid_coordinate_message 'column', y1, 0, max[:y] - 1
      return
    end

    if y2 < 0 || y2 > max[:y] - 1
      p invalid_coordinate_message 'column', y2, 0, max[:y] - 1
      return
    end

    if !is_valid_colour? colour
      p invalid_colour_message colour
      return
    end

    bitmap_editor.draw_horizontal_line(x, y1, y2, colour)
  end

  def handle_draw_vertical(bitmap_editor, *args)
    if !is_number?(args[0]) || !is_number?(args[1]) || !is_number?(args[2])
      p not_a_number_message
      return
    end

    unless bitmap_editor.image?
      p no_image_message
      return
    end

    x1 = [args[0].to_i, args[1].to_i].min
    x2 = [args[0].to_i, args[1].to_i].max
    y = args[2].to_i
    colour = args[3]

    max = max_coordinates(bitmap_editor)
    if x1 < 0 || x1 > max[:x] - 1
      p invalid_coordinate_message 'row', x1, 0, max[:x] - 1
      return
    end

    if x2 < 0 || x2 > max[:x] - 1
      p invalid_coordinate_message 'row', x2, 0, max[:x] - 1
      return
    end

    if y < 0 || y > max[:y] - 1
      p invalid_coordinate_message 'column', y, 0, max[:y] - 1
      return
    end

    if !is_valid_colour? colour
      p invalid_colour_message colour
      return
    end

    bitmap_editor.draw_vertical_line(x1, x2, y, colour)
  end

  def handle_fill_region(bitmap_editor, *args)
    if !is_number?(args[0]) || !is_number?(args[1])
      p not_a_number_message
      return
    end

    unless bitmap_editor.image?
      p no_image_message
      return
    end

    x, y = args[0].to_i, args[1].to_i
    colour = args[2]

    max = max_coordinates(bitmap_editor)
    if x < 0 || x > max[:x] - 1
      p invalid_coordinate_message 'row', x, 0, max[:x] - 1
      return
    end

    if y < 0 || y > max[:y] - 1
      p invalid_coordinate_message 'column', y, 0, max[:y] - 1
      return
    end

    if !is_valid_colour? colour
      p invalid_colour_message colour
      return
    end

    bitmap_editor.fill_region(x, y, colour)
  end

  def handle_show(bitmap_editor)
    unless bitmap_editor.image?
      p no_image_message
      return
    end

    bitmap_editor.image.each { |line| pretty_print line }
  end

  def invalid_coordinate_message(type, coordinate, min, max)
    "Please enter valid #{type} number between #{min} and #{max}. Your input is: #{coordinate}."
  end

  def no_image_message
    'No image. Please, insert image.'
  end

  def invalid_colour_message(input)
    "Please enter valid colour (only characters). Your input is #{input}"
  end

  def not_a_number_message
    'Please, enter a number as a coordinate.'
  end

  def max_coordinates(bitmap_editor)
    {
      x: bitmap_editor.max_x,
      y: bitmap_editor.max_y
    }
  end

  def is_number?(number)
    number.is_a?(Integer) ||
    number.is_a?(Float) ||
    /\A[-+]?[0-9]+\z/.match(number)
  end

  def is_valid_colour?(colour)
    colour && colour.is_a?(String) && /\A[a-zA-Z]+\z/.match(colour)
  end

  def pretty_print(text)
    if text.is_a? Array
      p text.join(' ')
    else
      p text
    end
  end
end

Task.new.run
