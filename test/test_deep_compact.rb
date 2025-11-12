# frozen_string_literal: true

require "test_helper"

class TestDeepCompact < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DeepCompact::VERSION
  end

  # Tests for deep_compact
  def test_deep_compact_removes_nil_values_from_simple_hash
    hash = { name: "John", age: nil, city: "NYC" }
    result = hash.deep_compact
    
    assert_equal({ name: "John", city: "NYC" }, result)
    # Original should not be modified
    assert_nil hash[:age]
  end

  def test_deep_compact_removes_nil_values_from_nested_hash
    hash = {
      name: "John",
      age: nil,
      address: {
        street: nil,
        number: nil,
        city: "NYC"
      }
    }
    
    result = hash.deep_compact
    assert_equal({ name: "John", address: { city: "NYC" } }, result)
  end

  def test_deep_compact_removes_hash_that_becomes_empty
    hash = {
      name: "John",
      address: {
        street: nil,
        number: nil
      }
    }
    
    result = hash.deep_compact
    assert_equal({ name: "John" }, result)
  end

  def test_deep_compact_with_arrays
    hash = {
      name: "John",
      tags: ["ruby", nil, "rails"],
      items: [
        { id: 1, value: nil },
        { id: 2, value: "test" }
      ]
    }
    
    result = hash.deep_compact
    expected = {
      name: "John",
      tags: ["ruby", "rails"],
      items: [{ id: 1 }, { id: 2, value: "test" }]
    }
    
    assert_equal expected, result
  end

  def test_deep_compact_removes_arrays_that_become_empty
    hash = {
      name: "John",
      empty_array: [nil, nil],
      items: [
        { value: nil },
        { another: nil }
      ]
    }
    
    result = hash.deep_compact
    assert_equal({ name: "John" }, result)
  end

  def test_deep_compact_with_deeply_nested_structures
    hash = {
      level1: {
        level2: {
          level3: {
            value: nil,
            data: "deep"
          }
        }
      }
    }
    
    result = hash.deep_compact
    assert_equal({ level1: { level2: { level3: { data: "deep" } } } }, result)
  end

  def test_deep_compact_does_not_modify_hash_without_nils
    hash = { name: "John", age: 30, city: "NYC" }
    result = hash.deep_compact
    
    assert_equal hash, result
  end

  def test_deep_compact_with_empty_hash
    hash = {}
    result = hash.deep_compact
    
    assert_equal({}, result)
  end

  def test_deep_compact_with_arrays_of_arrays
    hash = {
      data: [
        [nil, "a"],
        [nil, nil],
        ["b", "c"]
      ]
    }
    
    result = hash.deep_compact
    assert_equal({ data: [["a"], ["b", "c"]] }, result)
  end

  # Tests for deep_compact!
  def test_deep_compact_bang_modifies_original_hash
    hash = { name: "John", age: nil }
    result = hash.deep_compact!
    
    assert_equal({ name: "John" }, hash)
    assert_equal hash, result
    assert_same hash, result
  end

  def test_deep_compact_bang_with_nested_hash
    hash = {
      name: "John",
      address: {
        street: nil,
        city: "NYC"
      }
    }
    
    hash.deep_compact!
    assert_equal({ name: "John", address: { city: "NYC" } }, hash)
  end

  def test_deep_compact_bang_returns_self
    hash = { name: "John", age: nil }
    result = hash.deep_compact!
    
    assert_same hash, result
  end

  # Tests for deep_compact_blank
  def test_deep_compact_blank_removes_blank_values
    hash = {
      name: "John",
      age: nil,
      city: "",
      spaces: "   ",
      active: false,
      empty_hash: {},
      empty_array: []
    }
    
    result = hash.deep_compact_blank
    assert_equal({ name: "John" }, result)
  end

  def test_deep_compact_blank_with_nested_structures
    hash = {
      name: "John",
      metadata: {
        title: "",
        description: nil,
        tags: []
      },
      settings: {
        enabled: false
      }
    }
    
    result = hash.deep_compact_blank
    assert_equal({ name: "John" }, result)
  end

  def test_deep_compact_blank_with_arrays_containing_blanks
    hash = {
      items: ["", nil, "valid", "  ", []],
      nested: [
        { value: "" },
        { value: "keep" }
      ]
    }
    
    result = hash.deep_compact_blank
    expected = {
      items: ["valid"],
      nested: [{ value: "keep" }]
    }
    
    assert_equal expected, result
  end

  def test_deep_compact_blank_keeps_valid_falsey_values
    # Note: blank? considers false as blank, so it will be removed
    hash = {
      name: "John",
      count: 0,
      active: false
    }
    
    result = hash.deep_compact_blank
    # false is blank, 0 is not blank
    assert_equal({ name: "John", count: 0 }, result)
  end

  def test_deep_compact_blank_with_whitespace_strings
    hash = {
      name: "John",
      title: "   ",
      description: "\n\t  ",
      valid: "test"
    }
    
    result = hash.deep_compact_blank
    assert_equal({ name: "John", valid: "test" }, result)
  end

  def test_deep_compact_blank_deeply_nested
    hash = {
      level1: {
        level2: {
          level3: {
            blank: "",
            nil_value: nil,
            data: "keep"
          },
          empty: {}
        },
        another: []
      }
    }
    
    result = hash.deep_compact_blank
    assert_equal({ level1: { level2: { level3: { data: "keep" } } } }, result)
  end

  # Tests for deep_compact_blank!
  def test_deep_compact_blank_bang_modifies_original
    hash = { name: "John", age: nil, city: "" }
    result = hash.deep_compact_blank!
    
    assert_equal({ name: "John" }, hash)
    assert_same hash, result
  end

  def test_deep_compact_blank_bang_with_nested_structures
    hash = {
      user: {
        name: "John",
        bio: "",
        tags: []
      }
    }
    
    hash.deep_compact_blank!
    assert_equal({ user: { name: "John" } }, hash)
  end

  def test_deep_compact_blank_bang_returns_self
    hash = { name: "John", city: "" }
    result = hash.deep_compact_blank!
    
    assert_same hash, result
  end

  # Edge cases
  def test_all_methods_handle_empty_hash
    hash = {}
    
    assert_equal({}, hash.deep_compact)
    assert_equal({}, hash.deep_compact_blank)
    
    hash.deep_compact!
    assert_equal({}, hash)
    
    hash.deep_compact_blank!
    assert_equal({}, hash)
  end

  def test_deep_compact_with_mixed_array_types
    hash = {
      data: [1, nil, "string", { nested: nil }, [], { keep: "this" }]
    }
    
    result = hash.deep_compact
    assert_equal({ data: [1, "string", { keep: "this" }] }, result)
  end

  def test_preserves_non_string_keys
    hash = {
      1 => "one",
      2 => nil,
      :symbol => "value",
      "string" => nil
    }
    
    result = hash.deep_compact
    assert_equal({ 1 => "one", :symbol => "value" }, result)
  end

  def test_real_world_example_from_spec
    hash = {
      name: "John",
      age: nil,
      address: {
        street: nil,
        number: nil
      }
    }
    
    result = hash.deep_compact
    assert_equal({ name: "John" }, result)
  end
end
