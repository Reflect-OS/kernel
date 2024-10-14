defmodule ReflectOS.Kernel.Components do
  alias Scenic.Graph
  alias Scenic.Assets.Stream
  alias Scenic.Assets.Static
  import Scenic.Primitives

  import ReflectOS.Kernel.Typography

  def render_section_label(graph, config, opts \\ [])

  def render_section_label(%Graph{} = graph, %{show_label?: true, label: label}, opts) do
    graph
    |> section_label(label, opts)
  end

  def render_section_label(%Graph{} = graph, %{show_label?: false}, _opts), do: graph

  def section_label(%Graph{} = graph, label, opts \\ []) when is_binary(label) do
    {left, top, right, _bottom} =
      case Graph.bounds(graph) do
        nil ->
          {0, 0, 0, 0}

        bounds ->
          bounds
      end

    {:ok, {Static.Font, fm}} = Static.meta(:roboto_light)
    label_width = FontMetrics.width(label, 48, fm)

    section_width = right - left

    width =
      if is_number(opts[:width]) do
        opts[:width]
      else
        max(section_width, label_width + 24)
      end

    left =
      case opts[:align] do
        :right ->
          diff = width - section_width
          left - diff

        :center ->
          left + width / 2

        _ ->
          left
      end

    v_offset = top - 16

    graph =
      graph
      |> text(label, [t: {left, v_offset - 4}, text_align: :left] |> h5 |> light())
      |> line({{left, v_offset}, {left + width, v_offset}}, stroke: {2, :white})

    graph
  end

  def qr_code(%Graph{} = graph, content, opts \\ []) do
    qr_code_spec(content, opts).(graph)
  end

  def qr_code_spec(content, opts \\ []) do
    default_width = 250

    {stream_id, opts} = Keyword.pop(opts, :stream_id, UUID.uuid1())

    {qr_opts, opts} =
      opts
      |> Keyword.put_new(:width, default_width)
      |> Enum.split_with(fn {k, _v} -> k in [:color, :background_color, :width] end)

    {:ok, qr_code} =
      content
      |> QRCodeEx.encode()
      |> QRCodeEx.png(qr_opts)
      |> Stream.Image.from_binary()

    {qr_width, qr_height, _} = elem(qr_code, 1)

    Stream.put(stream_id, qr_code)

    opts =
      opts
      |> Keyword.put(:fill, {:stream, stream_id})

    rectangle_spec({qr_width, qr_height}, opts)
  end
end
