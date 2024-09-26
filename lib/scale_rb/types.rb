# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module ScaleRb
  module Types
    include Dry.Types()

    Primitive = Types::Strict::String.enum(
      'I8', 'U8', 'I16', 'U16', 'I32', 'U32', 'I64', 'U64', 'I128', 'U128', 'I256', 'U256',
      'Bool', 'Str', 'Char'
    )
    Ti = Types::Strict::Integer.constrained(gt: 0)
    U8 = Types::Strict::Integer.constrained(gteq: 0, lt: 256)
    U8Array = Types::Strict::Array.of(U8)
    Hex = Types::Strict::String.constrained(format: /\A0x[0-9a-fA-F]+\z/)

    Registry = Types::Hash.map(Ti, Any)

    class Base < Dry::Struct
      attribute? :registry, Registry

      def t(type_id)
        raise 'No registry' unless registry

        pt = registry[type_id]
        raise "Unknown type: #{type_id}" unless pt

        pt
      end
    end

    class PrimitiveType < Base
      attribute :primitive, Primitive

      def to_s
        primitive
      end
    end

    class CompactType < Base
      attribute? :type, Ti

      def to_s
        if type
          "Compact<#{t(type)}>"
        else
          'Compact'
        end
      end
    end

    class SequenceType < Base
      attribute :type, Ti

      def to_s
        "[#{t(type)}]"
      end
    end

    class BitSequenceType < Base
      attribute :bit_store_type, Ti
      attribute :bit_order_type, Ti

      def to_s
        "BitSequence<#{t(bit_store_type)}, #{t(bit_order_type)}>"
      end
    end

    class ArrayType < Base
      attribute :len, Types::Strict::Integer
      attribute :type, Ti

      def to_s
        "[#{t(type)}; #{len}]"
      end
    end

    class TupleType < Base
      attribute :tuple, Types::Strict::Array.of(Ti)

      def to_s
        tuple_str = tuple.map { |t| t(t) }.join(', ')
        "(#{tuple_str})"
      end
    end

    class Field < Dry::Struct
      attribute :name, Types::Strict::String
      attribute :type, Ti
    end

    class StructType < Base
      attribute :fields, Types::Strict::Array.of(Field)

      def to_s
        fields_str = fields.map { |f| "#{f.name}: #{t(f.type)}" }.join(', ')
        "{ #{fields_str} }"
      end
    end

    class UnitType < Base
      def to_s
        '()'
      end
    end

    class SimpleVariant < Dry::Struct
      attribute :name, Types::Strict::Symbol
      attribute :index, Types::Strict::Integer

      def to_s
        name.to_s
      end
    end

    class TupleVariant < Dry::Struct
      attribute :name, Types::Strict::Symbol
      attribute :index, Types::Strict::Integer
      attribute :tuple, TupleType

      def to_s
        "#{name}#{tuple}"
      end
    end

    class StructVariant < Dry::Struct
      attribute :name, Types::Strict::Symbol
      attribute :index, Types::Strict::Integer
      attribute :struct, StructType

      def to_s
        "#{name} #{struct}"
      end
    end

    VariantKind = Types::Instance(SimpleVariant) | Types::Instance(TupleVariant) | Types::Instance(StructVariant)

    class VariantType < Base
      attribute :variants, Types::Array.of(VariantKind)

      def to_s
        variants.map(&:to_s).join(' | ')
      end
    end
  end
end

p1 = ScaleRb::Types::PrimitiveType.new(primitive: 'U8')
puts "p1: #{p1}"

registry = { 1 => p1 }

p2 = ScaleRb::Types::CompactType.new
puts "p2: #{p2}"

p3 = ScaleRb::Types::CompactType.new(type: 1, registry:)
puts "p3: #{p3}"

p4 = ScaleRb::Types::SequenceType.new(type: 1, registry:)
puts "p4: #{p4}"

p5 = ScaleRb::Types::ArrayType.new(type: 1, len: 3, registry:)
puts "p5: #{p5}"

# p6 = ScaleRb::Types::BitSequenceType.new(bit_store_type: 1, bit_order_type: 2, registry:)
# puts "p6: #{p6}"

registry = { 1 => p1, 2 => p2, 3 => p3, 4 => p4, 5 => p5 }
p7 = ScaleRb::Types::TupleType.new(tuple: [1, 2, 3], registry:)
puts "p7: #{p7}"

p8 = ScaleRb::Types::StructType.new(
  fields: [
    ScaleRb::Types::Field.new(name: 'name', type: 1),
    ScaleRb::Types::Field.new(name: 'age', type: 2)
  ],
  registry:
)
puts "p8: #{p8}"

p9 = ScaleRb::Types::UnitType.new
puts "p9: #{p9}"

p10 = ScaleRb::Types::VariantType.new(
  variants: [
    ScaleRb::Types::TupleVariant.new(name: :Bar, index: 1, tuple: p7),
    ScaleRb::Types::SimpleVariant.new(name: :Foo, index: 0),
    ScaleRb::Types::StructVariant.new(name: :Baz, index: 2, struct: p8)
  ],
  registry:
)
puts "p10: #{p10}"
