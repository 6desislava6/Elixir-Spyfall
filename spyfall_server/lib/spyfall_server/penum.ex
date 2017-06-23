defmodule PEnum do
  def map(enumerable, func) do
    enumerable
    |> Enum.map(&(Task.async(fn -> func.(&1) end)))
    |> Enum.map(&Task.await/1)
  end
end