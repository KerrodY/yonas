# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game::Base do
  subject(:base) { described_class.new }

  it 'raises NotImplementedError for every contract method' do
    %i[display_name game_roles weapons weapon_params react_role_groups
       heartrunes armour_weights builds servers].each do |contract_method|
      expect { base.public_send(contract_method) }
        .to raise_error(NotImplementedError, /#{contract_method}/)
    end
  end

  it 'defaults to no notifiers' do
    expect(base.notifiers).to eq([])
  end
end
