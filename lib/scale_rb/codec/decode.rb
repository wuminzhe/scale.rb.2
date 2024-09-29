# frozen_string_literal: true

# rubocop:disable all
module ScaleRb
  module Codec
    class << self
      extend TypeEnforcer
      include Types

      sig :decode, [Ti, Hex, Registry], DecodeResult
      def decode(id, bytes, registry)
        ScaleRb.logger.debug("Decoding #{id}, bytes: #{bytes}")
        type = registry[id]
        raise TypeNotFound, "id: #{id}" if type.nil?

        case type
        when PrimitiveType then decode_primitive(type, bytes)
        when CompactType then decode_compact(bytes)
        when ArrayType then decode_array(type, bytes, registry)
        when SequenceType then decode_sequence(type, bytes, registry)
        when TupleType then decode_tuple(type, bytes, registry)
        when StructType then decode_struct(type, bytes, registry)
        when UnitType then [[], bytes]
        when VariantType then decode_variant(type, bytes, registry)
        else raise TypeNotImplemented, "id: #{id}, type: #{type}"
        end
      end

      sig :decode_primitive, [PrimitiveType, Hex], DecodeResult
      def decode_primitive(type, bytes)
        primitive = type.primitive
        ScaleRb.logger.debug("Decoding primitive: #{primitive}, bytes: #{bytes}")

        return ScaleRb.decode_uint(primitive, bytes) if primitive.start_with?('U')
        return ScaleRb.decode_int(primitive, bytes) if primitive.start_with?('I')
        return ScaleRb.decode_string(bytes) if primitive == 'Str'
        return ScaleRb.decode_boolean(bytes) if primitive == 'Bool'

        raise TypeNotImplemented, "decoding primitive: #{primitive}"
      end

      sig :decode_compact, [Hex], DecodeResult
      def decode_compact(bytes)
        ScaleRb.logger.debug("Decoding compact: bytes: #{bytes}")

        ScaleRb.decode_compact(bytes)
      end

      sig :decode_array, [ArrayType, Hex, Registry], DecodeResult
      def decode_array(type, bytes, registry)
        ScaleRb.logger.debug("Decoding array: #{type}, bytes: #{bytes}")

        len = type.len
        inner_type_id = type.type

        _decode_types([inner_type_id] * len, bytes, registry)
      end

      sig :decode_sequence, [SequenceType, Hex, Registry], DecodeResult
      def decode_sequence(sequence_type, bytes, registry)
        ScaleRb.logger.debug("Decoding sequence: #{sequence_type}, bytes: #{bytes}")

        len, remaining_bytes = decode_compact(bytes)
        _decode_types([sequence_type.type] * len, remaining_bytes, registry)
      end

      sig :decode_tuple, [TupleType, Hex, Registry], DecodeResult
      def decode_tuple(tuple_type, bytes, registry)
        ScaleRb.logger.debug("Decoding tuple: #{tuple_type}, bytes: #{bytes}")

        type_ids = tuple_type.tuple

        # NOTE: If the tuple has only one element, decode that element directly.
        # This is to make the structure of the decoded result clear.
        if type_ids.length == 1
          decode(type_ids.first, bytes, registry)
        else
          _decode_types(type_ids, bytes, registry)
        end
      end

      sig :decode_struct, [StructType, Hex, Registry], DecodeResult
      def decode_struct(struct_type, bytes, registry)
        ScaleRb.logger.debug("Decoding struct: #{struct_type}, bytes: #{bytes}")

        fields = struct_type.fields

        names = fields.map { |f| f.name.to_sym }
        type_ids = fields.map(&:type)

        values, remaining_bytes = _decode_types(type_ids, bytes, registry)
        [
          [names, values].transpose.to_h,
          remaining_bytes
        ]
      end

      sig :decode_variant, [VariantType, Hex, Registry], DecodeResult
      def decode_variant(variant_type, bytes, registry)
        ScaleRb.logger.debug("Decoding variant: #{variant_type}, bytes: #{bytes}")

        # find the variant by the index
        index = bytes[0].to_i
        variant = variant_type.variants.find { |v| v.index == index }
        raise VariantIndexOutOfRange, "type: #{variant_type}, index: #{index}, bytes: #{bytes}" if variant.nil?

        # decode the variant
        case variant
        when SimpleVariant
          [
            variant.name,
            bytes[1..]
          ]
        when TupleVariant
          value, remainning_bytes = decode_tuple(variant.tuple, bytes[1..], registry)
          [
            { variant.name => value },
            remainning_bytes
          ]
        when StructVariant
          value, remainning_bytes = decode_struct(variant.struct, bytes[1..], registry)
          [
            { variant.name => value },
            remainning_bytes
          ]
        else raise 'Unreachable'
        end
      end

      private

      # _u8? :: Ti -> Array<PortableType> -> Bool
      def _u8?(type_id, registry)
        type = registry[type_id]
        raise TypeNotFound, "id: #{type_id}" if type.nil?

        type.is_a?(ScaleRb::PrimitiveType) && type.primitive == 'U8'
      end

      # _decode_types :: Array<Ti> -> U8Array -> Array<PortableType> -> (Array<Any>, U8Array)
      def _decode_types(ids, bytes, registry = {})
        remaining_bytes = bytes
        values = ids.map do |id|
          value, remaining_bytes = decode(id, remaining_bytes, registry)
          value
        end
        [values, remaining_bytes]
      end
    end
  end
end
