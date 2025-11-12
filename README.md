# DeepCompact

A Ruby gem that adds deep (recursive) compaction methods to the `Hash` class. While Ruby has a native `compact` method that only removes `nil` values at the first level, `DeepCompact` removes `nil` or `blank` values at all nesting levels, including inside arrays and nested hashes.

## Features

- 🔍 **Recursive**: Processes nested hashes and arrays at any depth
- 🧹 **Auto-cleanup**: Removes hashes and arrays that become empty after compaction
- 🎯 **Two modes**: `deep_compact` (nil only) and `deep_compact_blank` (Rails blank values)
- ⚡ **Bang versions**: `!` methods that modify the original hash
- 🔒 **Preserves originals**: Non-bang methods return new hashes without modifying the original

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'deep_compact'
```

And execute:

```bash
bundle install
```

Or install it directly:

```bash
gem install deep_compact
```

## Usage

### deep_compact

Recursively removes `nil` values, including from nested hashes and arrays:

```ruby
require 'deep_compact'

hash = {
  name: "John",
  age: nil,
  address: {
    street: nil,
    number: nil,
    city: "NYC"
  }
}

hash.deep_compact
# => { name: "John", address: { city: "NYC" } }
```

### deep_compact!

Version that modifies the original hash:

```ruby
hash = { name: "John", age: nil, city: "NYC" }
hash.deep_compact!
# => { name: "John", city: "NYC" }

# The original hash was modified
hash
# => { name: "John", city: "NYC" }
```

### deep_compact_blank

Recursively removes `blank` values (using ActiveSupport's definition):

- `nil`
- Empty strings (`""`)
- Whitespace-only strings (`"   "`)
- Empty arrays (`[]`)
- Empty hashes (`{}`)
- `false`

```ruby
hash = {
  name: "John",
  age: nil,
  bio: "",
  tags: [],
  metadata: {
    title: "   ",
    active: false,
    count: 0
  }
}

hash.deep_compact_blank
# => { name: "John", metadata: { count: 0 } }
# Note: 0 is not blank, so it's kept
```

### deep_compact_blank!

Version that modifies the original hash:

```ruby
hash = { name: "John", bio: "", tags: [] }
hash.deep_compact_blank!
# => { name: "John" }
```

## Advanced Examples

### With Nested Arrays

```ruby
hash = {
  users: [
    { id: 1, name: "John", email: nil },
    { id: 2, name: nil, email: nil },
    { id: 3, name: "Mary", email: "mary@example.com" }
  ]
}

hash.deep_compact
# => { 
#   users: [
#     { id: 1, name: "John" },
#     { id: 2 },
#     { id: 3, name: "Mary", email: "mary@example.com" }
#   ]
# }
```

### Removing Empty Structures

Hashes and arrays that become empty after compaction are automatically removed:

```ruby
hash = {
  name: "John",
  address: {
    street: nil,
    number: nil
  },
  tags: [nil, nil]
}

hash.deep_compact
# => { name: "John" }
# address and tags were removed because they became empty
```

### Deeply Nested Structures

```ruby
hash = {
  level1: {
    level2: {
      level3: {
        level4: {
          value: nil,
          data: "deep"
        }
      }
    }
  }
}

hash.deep_compact
# => { level1: { level2: { level3: { level4: { data: "deep" } } } } }
```

## Difference between deep_compact and deep_compact_blank

- **`deep_compact`**: Removes only `nil` values
- **`deep_compact_blank`**: Removes `blank` values (nil, "", "  ", [], {}, false)

```ruby
hash = {
  name: "John",
  age: nil,
  bio: "",
  active: false,
  count: 0
}

hash.deep_compact
# => { name: "John", bio: "", active: false, count: 0 }

hash.deep_compact_blank
# => { name: "John", count: 0 }
# "" and false are blank, but 0 is not
```

## Requirements

- Ruby >= 3.1.0
- ActiveSupport >= 6.0 (for `*_blank` methods)

## How It Works

DeepCompact adds methods to the `Hash` class that:

1. Recursively iterate through all key-value pairs
2. Process nested hashes by applying compaction recursively
3. Process arrays, compacting each element (especially hashes inside arrays)
4. Remove nil/blank values
5. Remove keys whose values become empty hashes or arrays after compaction

Methods with `!` modify the original hash, while those without `!` return a new hash.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/deep_compact. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/deep_compact/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DeepCompact project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/deep_compact/blob/master/CODE_OF_CONDUCT.md).
