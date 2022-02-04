defmodule LeetcodeBot do
  @moduledoc """
  Documentation for `LeetcodeBot`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> LeetcodeBot.hello()
      nil

  """
  def hello do
    size = 5
    colorless = {:rand.uniform(size) - 1, :rand.uniform(size) - 1}
    world = make_world(size)

    find_mapping(world, colorless, %{})
  end

  defp find_mapping(world, {x, y} = cell, mapping) do
    IO.inspect(world)
    IO.inspect(mapping)
    cond do
      x == 0 and y == 0 -> mapping
      Enum.at(world, x) |> Enum.at(y) == -1 -> false
      true ->
        world = set_colorless(world, cell)
        colors = [north(world, cell), south(world, cell), east(world, cell), west(world, cell)]
        [n, s, e, w] = colors
        [n_m, s_m, e_m, w_m] = [
          update_mapping(world, :north, n, mapping),
          update_mapping(world, :south, s, mapping),
          update_mapping(world, :east, e, mapping),
          update_mapping(world, :west, w, mapping),
        ]

        [n, s, e, w]
        |> Enum.zip([n_m, s_m, e_m, w_m])
        |> Enum.filter(fn {cell, mapping} -> !!cell and !!mapping end)
        |> Enum.find(fn {cell, mapping} ->
          find_mapping(world, cell, mapping)
        end)
    end
  end

  def update_mapping(_world, _dir, cell, mapping) when is_nil(cell), do: mapping
  def update_mapping(world, direction, {x, y} = _cell, mapping) do
    color = Enum.at(world, x) |> Enum.at(y)
    case Map.get(mapping, color) do
      nil -> Map.put(mapping, color, opposite(direction))
      saved_direction ->
        if saved_direction == opposite(direction), do: mapping, else: false
    end
  end

  defp opposite(direction) do
    case direction do
      :north -> :south
      :south -> :north
      :west -> :east
      :east -> :west
      _ -> nil
    end
  end

  @doc """
  Return the cell south of `cell`.

  ## Examples

    iex> LeetcodeBot.south([[0, 1],[2, 3]], {0, 1})
    {1, 1}

    iex> LeetcodeBot.south([[0, 1],[2, 3]], {1, 1})
    nil
  """
  def south(world, {x, y} = cell) do
    if x == Enum.count(world) - 1, do: nil, else: {x + 1, y}
  end

  @doc """
  Return the cell east of `cell`.

  ## Examples

    iex> LeetcodeBot.east([[0, 1],[2, 3]], {0, 1})
    nil

    iex> LeetcodeBot.east([[0, 1],[2, 3]], {0, 0})
    {0, 1}
  """
  def east(world, {x, y} = cell) do
    if y == Enum.count(Enum.at(world, x)) - 1, do: nil, else: {x, y + 1}
  end

  @doc """
  Return the cell west of `cell`.

  ## Examples

    iex> LeetcodeBot.west([[0, 1],[2, 3]], {1, 1})
    {1, 0}

    iex> LeetcodeBot.west([[0, 1],[2, 3]], {1, 0})
    nil
  """
  def west(world, {x, 0}), do: nil
  def west(world, {x, y} = cell) do
    {x, y - 1}
  end

  @doc """
  Return the cell north of `cell`.

  ## Examples

    iex> LeetcodeBot.north([[0, 1],[2, 3]], {0, 1})
    nil

    iex> LeetcodeBot.north([[0, 1],[2, 3]], {1, 1})
    {0, 1}
  """
  def north(_world, {0, y}), do: nil
  def north(world, {x, y}) do
    {x - 1, y}
  end

  defp set_colorless(world, {x, y}) do
    world
    |> Enum.with_index()
    |> Enum.map(fn {row, index} ->
      if index == x do
        List.replace_at(row, y, -1)
      else
        row
      end
    end)
  end

  defp make_world(size) do
    Stream.repeatedly(fn ->
      Stream.repeatedly(fn -> :rand.uniform(8) - 1 end) |> Enum.take(size)
    end) |> Enum.take(size)
  end
end
