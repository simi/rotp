module ROTP
  class Base32
    class Base32Error < RuntimeError; end
    CHARS = 'abcdefghijklmnopqrstuvwxyz234567'.each_char.to_a
    MASK = 31

    class << self

      def decode(str)
        shift = 5
        buffer = 0
        idx = 0
        bitsLeft = 0
        str = str.tr('=', '').downcase
        result = []
        str.split('').each do |char|
          buffer = buffer << shift
          buffer = buffer | (decode_quint(char) & MASK)
          bitsLeft = bitsLeft + shift
          if bitsLeft >= 8
            result[idx] = (buffer >> (bitsLeft - 8)) & 255
            idx = idx + 1
            bitsLeft = bitsLeft - 8
          end
        end
        result.pack('c*')
      end

      def random_base32(length = 32)
        b32 = ''
        SecureRandom.random_bytes(length).each_byte do |b|
          b32 << CHARS[b % 32]
        end
        b32
      end

      private

      def decode_quint(q)
        CHARS.index(q) || raise(Base32Error, "Invalid Base32 Character - '#{q}'")
      end
    end
  end
end
