defmodule Rename do
  def run(path) do
    File.ls!(path)
    |> Enum.each(&(rename(path, &1)))
  end

  defp rename(path, filename) do
    old = Path.join(path, filename)

    contents = File.read!(old)

    [_, date] = Regex.run(~r/date\s*[:=]\s*['"]?(\d{4}-\d\d-\d\d)/, contents)

    File.rename(old, Path.join(path, "#{date}-#{filename}"))
  end
end
