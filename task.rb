#!/usr/bin/env ruby
require './bitmap_editor'
require 'pry'

class Task
  X_MAX = 250
  Y_MAX = 250

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
    x, y = args[0].to_i, args[1].to_i

    if x < 1 || x > X_MAX
      p invalid_coordinate_message 'row', x, 250
      return
    end

    if y < 1 || y > Y_MAX
      p invalid_coordinate_message 'column', y, 250
      return
    end

    bitmap_editor.create_image(x, y)
  end

  def handle_colour(bitmap_editor, *args)
    unless bitmap_editor.image?
      p 'No image. Please, insert image.'
      return
    end

    x, y = args[0].to_i, args[1].to_i
    colour = args[2]

    max = max_coordinates(bitmap_editor)
    if x < 0 || x > max[:x]
      p invalid_coordinate_message 'row', x, max[:x] - 1
      return
    end

    if y < 0 || y > max[:y]
      p invalid_coordinate_message 'column', y, max[:y] - 1
      return
    end

    unless colour
      p invalid_colour_message
      return
    end

    bitmap_editor.colours_pixel(x, y, colour)
  end

  def handle_clear(bitmap_editor)
    bitmap_editor.clear_image
  end

  def handle_draw_horizontal(bitmap_editor, *args)
    unless bitmap_editor.image?
      p 'No image. Please, insert image.'
      return
    end

    x = args[0].to_i
    y1 = [args[1].to_i, args[2].to_i].min
    y2 = [args[1].to_i, args[2].to_i].max
    colour = args[3]

    max = max_coordinates(bitmap_editor)
    if x < 0 || x > max[:x]
      p invalid_coordinate_message 'row', x, max[:x] - 1
      return
    end

    if y1 < 0 || y1 > max[:y]
      p invalid_coordinate_message 'column', y1, max[:y] - 1
      return
    end

    if y2 < 0 || y2 > max[:y]
      p invalid_coordinate_message 'column', y2, max[:y] - 1
      return
    end

    unless colour
      p invalid_colour_message
      return
    end

    bitmap_editor.draw_horizontal_line(x, y1, y2, colour)
  end

  def handle_draw_vertical(bitmap_editor, *args)
    unless bitmap_editor.image?
      p 'No image. Please, insert image.'
      return
    end

    x1 = [args[0].to_i, args[1].to_i].min
    x2 = [args[0].to_i, args[1].to_i].max
    y = args[2].to_i
    colour = args[3]

    max = max_coordinates(bitmap_editor)
    if x1 < 0 || x1 > max[:x]
      p invalid_coordinate_message 'row', x1, max[:x] - 1
      return
    end

    if x2 < 0 || x2 > max[:x]
      p invalid_coordinate_message 'row', x2, max[:x] - 1
      return
    end

    if y < 0 || y > max[:y]
      p invalid_coordinate_message 'column', y, max[:y] - 1
      return
    end

    unless colour
      p invalid_colour_message
      return
    end

    bitmap_editor.draw_vertical_line(x1, x2, y, colour)
  end

  def handle_fill_region(bitmap_editor, *args)
    unless bitmap_editor.image?
      p 'No image. Please, insert image.'
      return
    end

    x, y = args[0].to_i, args[1].to_i
    colour = args[2]

    max = max_coordinates(bitmap_editor)
    if x < 0 || x > max[:x]
      p invalid_coordinate_message 'row', x, max[:x] - 1
      return
    end

    if y < 0 || y > max[:y]
      p invalid_coordinate_message 'column', y, max[:y] - 1
      return
    end

    unless colour
      p invalid_colour_message
      return
    end

    bitmap_editor.fill_region(x, y, colour)
  end

  def handle_show(bitmap_editor)
    unless bitmap_editor.image?
      p 'No image is entered'
      return
    end

    bitmap_editor.image.each { |line| pretty_print line }
  end

  def invalid_coordinate_message(type, coordinate, max)
    "Please enter valid #{type} number between 1 and #{max}. Your input is: #{coordinate}"
  end

  def invalid_colour_message
    "Please enter colour."
  end

  def max_coordinates(bitmap_editor)
    return {x: X_MAX, y: Y_MAX } unless bitmap_editor.image?

    image = bitmap_editor.image
    { x: image.size,
      y: image[0].size
    }
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
