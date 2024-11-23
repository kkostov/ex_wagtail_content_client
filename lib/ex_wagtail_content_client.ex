defmodule ExWagtailContentClient do
  @moduledoc """
  Documentation for `ExWagtailContentClient`.
  """

  def detail(detail_url, opts \\ []) do
    req_opts = Keyword.get(opts, :req_opts, [])

    get_request(detail_url, nil, req_opts, nil)
    |> cleanup_block_types(["body"], ["paragraph"])
  end

  @doc """
  For each of the specified fields, sanitizes the `value` field, if one is present.

  To sanitize a field, the library depends on https://github.com/rrrene/html_sanitize_ex by calling `HtmlSanitizeEx.basic_html(value)`.
  """
  def cleanup_block_types({:ok, body}, fields, block_types)
      when is_list(fields) and is_list(block_types) do
    cleanup_field_block_types(body, fields, block_types)
  end

  defp cleanup_field_block_types(body, [], _block_types) do
    body
  end

  defp cleanup_field_block_types(body, [field | fields], block_types) do
    if Map.has_key?(body, field) do
      Map.update!(body, field, fn field_blocks ->
        cleanup_block_types(field_blocks, block_types)
      end)
      |> cleanup_field_block_types(fields, block_types)
    else
      body
    end
  end

  def cleanup_block_types(blocks, []) do
    blocks
  end

  def cleanup_block_types(blocks, block_types) do
    blocks
    |> Enum.map(fn block ->
      if Map.has_key?(block, "type") and Enum.member?(block_types, block["type"]) and
           Map.has_key?(block, "value") do
        Map.put(block, "value", block["value"] |> HtmlSanitizeEx.basic_html())
      else
        block
      end
    end)
  end

  @doc """
  Fetches a list of pages from the default pages API.

  ## Options

    - `:base_url` - (required) The root url of the server
    - `:offset` - (optional) the number of items to skip during pagination, default 0 (see https://docs.wagtail.org/en/latest/advanced_topics/api/v2/usage.html#pagination)
    - `:limit` - (optional) the number of items to fetch during pagination, default 20 (see https://docs.wagtail.org/en/latest/advanced_topics/api/v2/usage.html#pagination)
    - `:req_opts` - (optional) List of options to pass to Req.get when executing the request
    - `:extra_params` - (optional) a list of tuples for additional parameters to be added to the query e.g. `[{"locale", "fr"}]`

  ## Examples

      iex> ExWagtailContentClient.list :pages, base_url: "https://iamkonstantin.eu"
      {:ok, [%{"id" => 1, ...}], %{"total_count" => 38}, %{pagination}}

      iex> ExWagtailContentClient.list :pages, base_url: "https://iamkonstantin.eu", extra_params: [{"locale", "fr"}]
      {:ok, [%{"id" => 1, ...}], %{"total_count" => 38}, %{pagination}}

      iex> ExWagtailContentClient.list :pages, base_url: "https://doesntexist"
      {:error, %Req.TransportError{reason: :nxdomain}}
  """
  def list(resource, opts \\ []) do
    base_url = Keyword.get(opts, :base_url)
    req_opts = Keyword.get(opts, :req_opts, [])

    # create pagination map
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)
    pagination = %{"limit" => limit, "offset" => offset}

    # additional parameters
    extra_params =
      Keyword.get(opts, :extra_params, []) |> Map.new() |> Map.merge(pagination)

    get_request(base_url, get_path_for_resource(resource), req_opts, extra_params)
    |> extract_pagination(pagination)
  end

  def get_path_for_resource(resource) do
    case resource do
      :pages -> "/api/v2/pages/"
      :images -> "/api/v2/images/"
      :documents -> "/api/v2/documents/"
    end
  end

  def extract_pagination({:ok, body}, pagination) do
    if Map.has_key?(body, "items") and Map.has_key?(body, "meta") do
      received_items_cnt = length(body["items"])
      limit = pagination["limit"]
      offset = pagination["offset"]

      has_next = received_items_cnt >= limit
      has_previous = offset > 0

      {:ok, body["items"], body["meta"],
       %{
         pagination: %{
           total_count: body["meta"]["total_count"],
           has_next?: has_next,
           next:
             (has_next &&
                %{limit: limit, offset: offset + received_items_cnt}) || nil,
           has_previous?: has_previous,
           previous:
             (has_previous &&
                %{limit: limit, offset: offset - received_items_cnt}) || nil
         }
       }}
    else
      {:error, :response_not_list_of_items}
    end
  end

  def extract_pagination(result, _) do
    result
  end

  def get_request(nil, _, _, _) do
    {:error, :invalid_base_url}
  end

  def get_request(host_url, path, req_opts, params) do
    case Req.new(
           url: url_with_path(host_url, path, params),
           headers: [{"accept", "application/json"}, {"content-type", "application/json"}]
         )
         |> Req.get(req_opts) do
      {:ok, %{status: _status, headers: _headers, body: body} = _} -> {:ok, body}
      {:error, err} -> {:error, err}
    end
  end

  def url_with_path(host_url, nil, params) do
    host_url
    |> URI.parse()
    |> append_query(params)
    |> URI.to_string()
  end

  def url_with_path(host_url, path, params) do
    host_url
    |> URI.parse()
    |> URI.merge(path)
    |> append_query(params)
    |> URI.to_string()
  end

  def append_query(uri, nil) do
    uri
  end

  def append_query(%{} = uri, params) do
    uri
    |> Map.update(:query, URI.encode_query(params), fn existing_query ->
      [existing_query, URI.encode_query(params)]
      |> Enum.reject(&is_nil/1)
      |> Enum.join("&")
    end)
  end
end
