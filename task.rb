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

    send("handle_#{command}", @bitmap_editor, args)
  end

  def normalize_command(command)
    return unless command

    command.downcase.to_sym
  end

  def handle_insert(bitmap_editor, args)
    x, y = args[0].to_i, args[1].to_i
    bitmap_editor.create_image(x, y)
  end

  def handle_colour(bitmap_editor, args)
    x, y = args[0].to_i, args[1].to_i
    colour = args[2]
    bitmap_editor.colours_pixel(x, y, colour)
  end

  def handle_clear(bitmap_editor, args)
    bitmap_editor.clear_image
  end

  def handle_draw_horizontal(bitmap_editor, args)
    x = args[0].to_i
    y1 = [args[1].to_i, args[2].to_i].min
    y2 = [args[1].to_i, args[2].to_i].max
    colour = args[3]
    bitmap_editor.draw_horizontal_line(x, y1, y2, colour)
  end

  def handle_draw_vertical(bitmap_editor, args)
    x1 = [args[0].to_i, args[1].to_i].min
    x2 = [args[0].to_i, args[1].to_i].max
    y = args[2].to_i
    colour = args[3]
    bitmap_editor.draw_vertical_line(x1, x2, y, colour)
  end

  def handle_fill_region(bitmap_editor, args)
    x, y = args[0].to_i, args[1].to_i
    colour = args[2]
    bitmap_editor.fill_region(x, y, colour)
  end

  def handle_show(bitmap_editor, args)
    image = bitmap_editor.image
    unless image
      p 'No image is entered'
      return
    end

    image.each { |line| pretty_print line }
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
