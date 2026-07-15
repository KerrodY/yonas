# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game do
  describe '.current' do
    it 'returns the New World profile' do
      expect(described_class.current).to be_a(Game::NewWorld)
    end

    it 'memoizes the profile' do
      expect(described_class.current).to equal(described_class.current)
    end
  end
end
