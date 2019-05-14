require 'spec_helper'

RSpec.describe ROTP::Base32 do
  describe '.random_base32' do
    context 'without arguments' do
      let(:base32) { ROTP::Base32.random_base32 }

      it 'is 32 characters long' do
        expect(base32.length).to eq 32
      end

      it 'is base32 charset' do
        expect(base32).to match(/\A[a-z2-7]+\z/)
      end
    end

    context 'with arguments' do
      let(:base32) { ROTP::Base32.random_base32 32 }

      it 'allows a specific length' do
        expect(base32.length).to eq 32
      end
    end
  end

  describe '.decode' do
    context 'corrupt input data' do
      it 'raises a sane error' do
        expect { ROTP::Base32.decode('4BCDEFG234BCDEF1') }.to \
          raise_error(ROTP::Base32::Base32Error, "Invalid Base32 Character - '1'")
      end
    end

    context 'valid input data' do
      it 'correctly decodes a string' do
        expect(ROTP::Base32.decode('23').unpack('H*').first).to eq 'd6'
        expect(ROTP::Base32.decode('234A').unpack('H*').first).to eq 'd6f8'
        expect(ROTP::Base32.decode('234BCD').unpack('H*').first).to eq 'd6f811'
        expect(ROTP::Base32.decode('234BCDE').unpack('H*').first).to eq 'd6f8110c'
        expect(ROTP::Base32.decode('234BCDEFG').unpack('H*').first).to eq 'd6f8110c85'
      end

      it 'correctly decode strings with trailing bits (not a multiple of 8)' do
        # Dropbox style 26 characters (130 bits, but chopped to 128)
        # Matches the behavior of Google Authenticator
        expect(ROTP::Base32.decode('HQQE3KKCST7YEEB64NHJN52LJA').unpack('H*').first).to eq '3c204da94294ff82103ee34e96f74b48'
      end

      context 'with padding' do
        it 'correctly decodes a string' do
          expect(ROTP::Base32.decode('234A===').unpack('H*').first).to eq 'd6f8'
        end
      end

    end
  end
end
