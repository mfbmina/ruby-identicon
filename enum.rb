class Enum
  Each = ->(block, enum) { enum.each(&block) }.curry
  EachSlice = ->(slice, enum) { enum.each_slice(slice) }.curry
  EachWithIndex = ->(enum) { enum.each_with_index }
  FlatMap = ->(block, enum) { enum.flat_map(&block) }.curry
  Map = ->(block, enum) { enum.map(&block) }.curry
  Select = ->(block, enum) { enum.select(&block) }.curry
end
