class Image
  attr_reader :hex, :r, :g, :b, :grid, :pixel_map

  def initialize(**attr)
    @hex = attr[:hex]
    @r = attr[:r]
    @g = attr[:g]
    @b = attr[:b]
    @grid = attr[:grid]
    @pixel_map = attr[:pixel_map]
  end

  def color
    [r, g, b]
  end

  def attributes
    { hex: hex, r: r, g: g, b: b, grid: grid, pixel_map: pixel_map }
  end
end
