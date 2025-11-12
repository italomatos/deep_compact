# frozen_string_literal: true

require_relative "deep_compact/version"
require "active_support/core_ext/object/blank"

module DeepCompact
  class Error < StandardError; end

  module HashExtensions
    # Remove nil values from hash recursively
    # Returns a new hash without modifying the original
    def deep_compact
      each_with_object({}) do |(key, value), result|
        compacted_value = compact_value(value, :nil?)
        result[key] = compacted_value unless compacted_value.nil? || empty_after_compact?(compacted_value)
      end
    end

    # Remove nil values from hash recursively (in-place)
    # Modifies the original hash and returns self
    def deep_compact!
      keys.each do |key|
        value = self[key]
        compacted_value = compact_value(value, :nil?)
        
        if compacted_value.nil? || empty_after_compact?(compacted_value)
          delete(key)
        else
          self[key] = compacted_value
        end
      end
      self
    end

    # Remove blank values from hash recursively
    # Returns a new hash without modifying the original
    def deep_compact_blank
      each_with_object({}) do |(key, value), result|
        compacted_value = compact_value(value, :blank?)
        result[key] = compacted_value unless compacted_value.blank? || empty_after_compact?(compacted_value)
      end
    end

    # Remove blank values from hash recursively (in-place)
    # Modifies the original hash and returns self
    def deep_compact_blank!
      keys.each do |key|
        value = self[key]
        compacted_value = compact_value(value, :blank?)
        
        if compacted_value.blank? || empty_after_compact?(compacted_value)
          delete(key)
        else
          self[key] = compacted_value
        end
      end
      self
    end

    private

    # Recursively compact a value based on the condition method
    def compact_value(value, condition_method)
      case value
      when Hash
        # Recursively compact nested hash
        compacted = value.each_with_object({}) do |(k, v), result|
          compacted_v = compact_value(v, condition_method)
          result[k] = compacted_v unless compacted_v.public_send(condition_method) || empty_after_compact?(compacted_v)
        end
        compacted
      when Array
        # Process array elements, compacting nested hashes
        compacted = value.map { |item| compact_value(item, condition_method) }
                        .reject { |item| item.public_send(condition_method) || empty_after_compact?(item) }
        compacted
      else
        # Return value as-is for non-hash, non-array values
        value
      end
    end

    # Check if a value is empty after compaction (empty hash or empty array)
    def empty_after_compact?(value)
      (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
    end
  end
end

Hash.include(DeepCompact::HashExtensions)
