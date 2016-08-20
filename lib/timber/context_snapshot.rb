module Timber
  class ContextSnapshot
    include Timber::Patterns::ToJSON

    CONTEXT_VERSION = 1.freeze

    attr_reader :indexes, :stack

    def initialize
      # Cloning arrays and hashes is extremely fast. This
      # should not be a concern for hindering performance as we are
      # only cloning the structures, not the content.
      @stack = CurrentContext.valid_stack.clone.freeze
      @indexes = CurrentLineIndexes.indexes.clone.freeze
    end

    def size
      stack.size
    end

    def to_logfmt(options = {})
      @to_logfmt ||= {}
      @to_logfmt[options] ||= Core::LogfmtEncoder.encode(context_hash(options))
    end

    private
      def context_hash(options = {})
        @context_hash ||= {}
        @context_hash[options] ||= {}.tap do |hash|
          hash["_version"] = CONTEXT_VERSION
          filtered = stack.select { |context| !(options[:except] || []).include?(context.class) }
          filtered.each do |context|
            specific_hash = context.as_json_with_index(indexes[context])
            hash.replace(Core::DeepMerger.merge(hash, specific_hash))
          end
        end
      end

      def hierarchy
        @hierarchy ||= stack.collect(&:_path).uniq
      end

      def json_payload
        @json_payload ||= {
          :context => context_hash,
          :context_hierarchy => hierarchy
        }
      end
  end
end
