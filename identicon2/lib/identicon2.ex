defmodule Identicon2 do
  def main(input) do
    input
    |> hash_input
    |> pick_colors
    |> tritalize
    |> build_grid
    |> filter_zeroes
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    bin = :crypto.hash(:md5, input)
    |> bin_to_list
    
    %Identicon2.Image{bin: bin}
  end
  
  def bin_to_list(bin) do
    <<head, tail::binary>> = bin
    <<a::1, b::1, c::1, d::1, e::1, f::1, g::1, h::1>> = <<head>>
    case tail do
      "" -> [a, b, c, d, e, f, g, h]
      _ -> [a, b, c, d, e, f, g, h | bin_to_list tail]
    end
  end

  def pick_colors(image) do
    {color1, bin} = extract_color image.bin
    {color2, bin} = extract_color bin
    %Identicon2.Image{image | color1: color1, color2: color2, bin: bin}
  end

  def extract_color(bin) do
    {red, bin} = extract_number bin
    {green, bin} = extract_number bin
    {blue, bin} = extract_number bin

    {{red, green, blue}, bin}
  end

  def extract_number(bin) do
    [a, b, c, d, e, f, g, h | tail] = bin
    <<number>> = <<a::1, b::1, c::1, d::1, e::1, f::1, g::1, h::1>>
    {number, tail}
  end

  def tritalize(image) do
    trits = image.bin
    |> grind
    |> switch

    %Identicon2.Image{image | trits: trits}
  end

  def grind(bin) do
    [a, b | tail] = bin
    case tail do
      [] -> [a + b]
      _ -> [a + b | grind [b | tail]]
    end
  end

  def switch(trits) do
    Enum.map trits, fn(trit) ->
      case trit do
        1 -> 0
        0 -> 1
        x -> x
      end
    end
  end

  def build_grid(image) do
    grid = image.trits
    |> Enum.slice(0..71)
    |> Enum.chunk_every(6, 6, :discard)
    |> Enum.map(fn row -> row ++ Enum.reverse(row) end)
    |> List.flatten
    |> Enum.with_index

    %Identicon2.Image{image | grid: grid}
  end

  def filter_zeroes(image) do
    grid = Enum.filter image.grid, fn({value, _index}) -> value != 0 end
    %Identicon2.Image{image | grid: grid}
  end

  def build_pixel_map(image) do
    pixel_map = Enum.map image.grid, fn({value, index}) ->
      x = rem(index, 12) * 50
      y = div(index, 12) * 50

      top_left = {x, y}
      bottom_right = {x+50, y+50}

      {value, top_left, bottom_right}
    end

    %Identicon2.Image{image | pixel_map: pixel_map}
  end

  def draw_image(image) do
    size = 50 * 12
    raw = :egd.create(size, size)
    fill1 = :egd.color(image.color1)
    fill2 = :egd.color(image.color2)

    Enum.each image.pixel_map, fn({value, top_left, bottom_right}) ->
      case value do
        1 -> :egd.filledRectangle(raw, top_left, bottom_right, fill1)
        2 -> :egd.filledRectangle(raw, top_left, bottom_right, fill2)
      end
    end

    :egd.render raw
  end

  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
end
