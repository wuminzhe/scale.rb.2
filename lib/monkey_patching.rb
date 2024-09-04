# frozen_string_literal: true

# https://www.rubyguides.com/2017/01/read-binary-data/
class String
  def _to_bytes
    data = start_with?('0x') ? self[2..] : self
    raise 'Not valid hex string' if data =~ /[^\da-f]+/i

    data = "0#{data}" if data.length.odd?
    data.scan(/../).map(&:hex)
  end

  def _to_camel
    split('_').collect(&:capitalize).join
  end

  def _underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end
end

class Integer
  def _to_bytes(bit_length = nil)
    return to_s(16)._to_bytes unless bit_length

    hex = to_s(16).rjust(bit_length / 4, '0')
    hex._to_bytes
  end

  # unsigned to signed
  def _to_signed(bit_length)
    unsigned_mid = 2**(bit_length - 1)
    unsigned_ceiling = 2**bit_length
    self >= unsigned_mid ? self - unsigned_ceiling : self
  end

  # signed to unsigned
  def _to_unsigned(bit_length)
    unsigned_mid = 2**(bit_length - 1)
    unsigned_ceiling = 2**bit_length
    raise 'out of scope' if self >= unsigned_mid || self <= -unsigned_mid

    negative? ? unsigned_ceiling + self : self
  end

  # unix timestamp to utc
  def _to_utc
    Time.at(self).utc.asctime
  end

  # utc to unix timestamp
  def _from_utc(utc_asctime)
    Time.parse(utc_asctime)
  end
end

class Array
  def _to_hex
    raise 'Not a byte array' unless _byte_array?

    reduce('0x') { |hex, byte| hex + byte.to_s(16).rjust(2, '0') }
  end

  def _to_bin
    raise 'Not a byte array' unless _byte_array?

    reduce('0b') { |bin, byte| bin + byte.to_s(2).rjust(8, '0') }
  end

  def _to_utf8
    raise 'Not a byte array' unless _byte_array?

    pack('C*').force_encoding('utf-8')
  end

  def _to_uint
    _to_hex.to_i(16)
  end

  def _to_int(bit_length)
    _to_uint._to_signed(bit_length)
  end

  def _flip
    reverse
  end

  def _byte_array?
    all? { |e| e >= 0 and e <= 255 }
  end
end

class Hash
  def _key?(key)
    if key.instance_of?(String)
      key?(key) || key?(key.to_sym)
    else
      key?(key) || key?(key.to_s)
    end
  end

  def _get(*keys)
    keys.reduce(self) do |hash, key|
      break nil unless hash.is_a?(Hash)

      if key.instance_of?(String)
        hash[key] || hash[key.to_sym]
      elsif key.instance_of?(Symbol)
        hash[key] || hash[key.to_s]
      else
        hash[key]
      end
    end
  end
end
