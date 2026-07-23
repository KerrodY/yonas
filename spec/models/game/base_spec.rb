# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game::Base do
  subject(:base) { described_class.new }

  it 'raises NotImplementedError for every contract method' do
    %i[display_name hierarchy_roles access_roles game_roles weapons weapon_params
       react_role_groups heartrunes armour_weights builds servers].each do |contract_method|
      expect { base.public_send(contract_method) }
        .to raise_error(NotImplementedError, /#{contract_method}/)
    end
  end

  it 'defaults to no notifiers' do
    expect(base.notifiers).to eq([])
  end

  describe 'permission building blocks' do
    it 'are cumulative — each includes the one below it' do
      expect(base.member_permissions).to include(*base.guest_permissions)
      expect(base.officer_permissions).to include(*base.member_permissions)
      expect(base.management_permissions).to include(*base.officer_permissions)
    end
  end

  describe '#role_names_for' do
    let(:profile) do
      Class.new(described_class) do
        def access_roles
          { admin: %w[Boss], staff: %w[Mod], member: %w[Player], guest: %w[Visitor] }
        end
      end.new
    end

    it 'ranks — a level admits every level above it' do
      expect(profile.role_names_for(:staff)).to contain_exactly('Boss', 'Mod')
    end

    it 'exact — returns only the given level' do
      expect(profile.role_names_for(:staff, exact: true)).to contain_exactly('Mod')
    end

    it ':any matches every mapped role' do
      expect(profile.role_names_for(:any)).to contain_exactly('Boss', 'Mod', 'Player', 'Visitor')
    end

    it 'treats an unmapped level (e.g. :helper) as no roles' do
      expect(profile.role_names_for(:helper, exact: true)).to eq([])
    end
  end
end
