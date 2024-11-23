# ExWagtailContentClient ![Hex.pm Version](https://img.shields.io/hexpm/v/ex_wagtail_content_client) [![Hex Docs](https://img.shields.io/badge/docs-hexpm-blue.svg)](https://hexdocs.pm/ex_wagtail_content_client/) [![CI](https://github.com/kkostov/ex_wagtail_content_client/actions/workflows/ci.yml/badge.svg)](https://github.com/kkostov/ex_wagtail_content_client/actions/workflows/ci.yml)

Elixir library for consuming the [Wagtail content API](https://docs.wagtail.org/en/stable/advanced_topics/api/v2/usage.html)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_wagtail_content_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_wagtail_content_client, "~> 0.2.0"},
  ]
end
```

## Usage

The library is a simple REST API client fo the default Wagtail Content API. It's intended for accessing content based on the `/v2/pages`, `/v2/images` and `/v2/documents` endpoints.

There are two key methods to consider.

### Listing collections

Use the `list` method to list the contents of a collection:

```elixir
{:ok, items, meta, info} = ExWagtailContentClient.list :pages, base_url: "https://iamkonstantin.eu"
```

The returned items are:

- `items` - a list of the JSON objects returned by the Wagtail API (the nested `items` field from the raw response).

- `meta` - the JSON meta object returned bu the Wagtail API.

- `info` - a map created by the library to include pagination information like the total number of items and helpers for the next and previous query.

### Get detail of a resource

Individual items can be retrieved by their `detail_url`:

```elixir
{:ok, content} = ExWagtailContentClient.detail "https://iamkonstantin.eu/api/v2/pages/45/"
```

## License

Copyright [2024] [Konstantin <hi@iamkonstantin.eu>]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
