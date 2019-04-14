require 'chunky_png'
require 'digest'

require_relative './enum'
require_relative './image'
require_relative './string'

class Identicon
  def main(input)
    exec = HashInput \
      >> PickColor \
      >> BuildGrid \
      >> FilterOddSquares \
      >> BuildPixelMap \
      >> DrawImage \
      >> SaveImage.(input)

    exec.call(input)
  end

  HashInput = ->(input) do
    hex = Digest::MD5.method(:hexdigest) \
      >> String::Bytes \
      >> Enum::EachSlice.(2) \
      >> Enum::FlatMap.(Proc.new { |a, b| a + b })

    Image.new(hex: hex.call(input))
  end

  PickColor = ->(image) do
    r, g, b = image.hex.take(3)

    Image.new(hex: image.hex, r: r, g: g, b: b)
  end

  BuildGrid = ->(image) do
    grid = Enum::EachSlice.(3) \
      >> Enum::Select.(Proc.new { |arr| arr.size == 3 }) \
      >> Enum::FlatMap.(MirrorRow) \
      >> Enum::EachWithIndex \
      >> Enum::Map.(Proc.new { |v, i| [i, v] }) \

    attributes = image.attributes.merge(grid: grid.call(image.hex))
    Image.new(attributes)
  end

  MirrorRow = ->(row) do
    first, second = row.take(2)

    row + [second, first]
  end

  FilterOddSquares = ->(image) do
    grid = Enum::Select.(Proc.new { |_k, v| v.odd? }, image.grid)

    attributes = image.attributes.merge(grid: grid)
    Image.new(attributes)
  end

  BuildPixelMap = ->(image) do
    block = Proc.new do |index, value|
      horizontal = (index % 5) * 50
      vertical = (index / 5) * 50

      top_left = [horizontal, vertical]
      bottom_right = [horizontal + 50, vertical + 50]

      [top_left, bottom_right]
    end

    attributes = image.attributes.merge(pixel_map: Enum::Map.(block, image.grid))
    Image.new(attributes)
  end

  DrawImage = ->(image) do
    png = ChunkyPNG::Image.new(250, 250, ChunkyPNG::Color::TRANSPARENT)
    color = ChunkyPNG::Color(*image.color)

    fill = Proc.new do |start, stop|
      (start.first...stop.first).each do |x|
        (start.last...stop.last).each do |y|
          png[x,y] = color
        end
      end
    end

    Enum::Each.(fill, image.pixel_map)

    png
  end

  SaveImage = ->(filename, image) do
    image.save("#{filename}.png")
  end.curry
end

input = ARGV[0].strip
Identicon.new.main(input)
