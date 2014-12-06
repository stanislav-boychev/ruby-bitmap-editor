#!/usr/bin/env ruby

class Task
  def initialize
    @image = nil
  end

  def run
    begin
      line = readline
      command, args =  parse_command(line)
      if command
        execute_command(command, args)
      else
        p 'Unknown command'
      end
    end while command != :terminate
  end

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
    when :x then :terminate
      :terminate
    end
  end

  def normalize_command(command)
    return unless command

    command.downcase.to_sym
  end

  def execute_command(command, args)
    case command
    when :insert
      x, y = args[0].to_i, args[1].to_i
      create_image(x, y)
    when :colour
      x, y = args[0].to_i, args[1].to_i
      colour = args[2]
      colours_pixel(x, y, colour)
    when :clear
      clear_image
    when :draw_horizontal
      x = args[0].to_i
      y1 = [args[1].to_i, args[2].to_i].min
      y2 = [args[1].to_i, args[2].to_i].max
      colour = args[3]
      draw_horizontal_line(x, y1, y2, colour)
    when :draw_vertical
      x1 = [args[0].to_i, args[1].to_i].min
      x2 = [args[0].to_i, args[1].to_i].max
      y = args[2].to_i
      colour = args[3]
      draw_vertical_line(x1, x2, y, colour)
    when :show
      show_image
    end
  end

  def create_image(x, y)
    return if !x || !y

    @image = Array.new(x).map do |line|
      line = Array.new(y, '0')
    end
  end

  def show_image
    unless @image
      p 'No image is entered'
      return
    end

    @image.each { |line| pretty_print line }
  end

  def colours_pixel(x, y, colour)
    return if !x ||
              !y ||
              !colour ||
              !@image

    @image[x][y] = colour
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

  def pretty_print(text)
    if text.is_a? Array
      p text.join(' ')
    else
      p text
    end
  end

  def clear_image
    @image = nil
  end
end

Task.new.run
