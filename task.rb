#!/usr/bin/env ruby

class Task
  def initialize
    @image = nil
  end

  def run
    begin
      line = readline
      command, args =  parse_command(line)
      execute_command(command, args)
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
    when :show
      show_image
    end
  end

  def create_image(x, y)
    return if !x && !y

    line = Array.new(y, '0')
    @image = Array.new(x, line)
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
