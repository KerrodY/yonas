# frozen_string_literal: true

# Contract every game profile must satisfy. New game? One line in its spec:
#   it_behaves_like 'a game profile'
RSpec.shared_examples 'a game profile' do
  subject(:profile) { described_class.new }

  it 'has a display name' do
    expect(profile.display_name).to be_present
  end

  describe 'hierarchy roles' do
    it 'have a name, colour and permissions' do
      profile.hierarchy_roles.each do |role|
        expect(role[:name]).to be_present
        expect(role[:colour]).to be_present
        expect(role[:permissions]).to be_present
      end
    end

    it 'have unique names' do
      names = profile.hierarchy_roles.pluck(:name)
      expect(names.uniq).to eq(names)
    end
  end

  describe 'access roles' do
    it 'only use defined access levels' do
      expect(Game::Base::ACCESS_LEVELS).to include(*profile.access_roles.keys)
    end

    it 'only reference roles the profile actually creates' do
      role_names = profile.hierarchy_roles.pluck(:name)
      expect(role_names).to include(*profile.access_roles.values.flatten)
    end

    it 'resolve more roles for a ranked check than an exact one at the same level' do
      # a mid ladder level should admit the levels above it when ranked
      ranked = profile.role_names_for(:member)
      exact = profile.role_names_for(:member, exact: true)
      expect(ranked).to include(*exact)
    end
  end

  it 'defines game roles with names' do
    expect(profile.game_roles).to all(include(:name))
  end

  it 'defines weapons with a name and emoji' do
    expect(profile.weapons).to all(include(:name, :emoji))
  end

  it 'provides weapon params for slash command choices' do
    expect(profile.weapon_params).to be_a(Hash)
    expect(profile.weapon_params).to be_present
  end

  describe 'react role groups' do
    it 'have a title and roles' do
      profile.react_role_groups.each do |group|
        expect(group[:title]).to be_present
        expect(group[:roles]).to be_present
      end
    end

    it 'have unique titles so setup can identify each embed' do
      titles = profile.react_role_groups.pluck(:title)
      expect(titles.uniq).to eq(titles)
    end

    it 'have unique emojis within each group so a reaction maps to exactly one role' do
      profile.react_role_groups.each do |group|
        emojis = group[:roles].map { |role| role[:emoji] }
        expect(emojis.uniq).to eq(emojis),
                               "duplicate emojis in '#{group[:title]}': #{emojis.tally.select { |_, c| c > 1 }.keys.join(', ')}"
      end
    end

    it 'only reference roles the game creates' do
      created = profile.game_roles.pluck(:name) + profile.weapons.pluck(:name)
      referenced = profile.react_role_groups.flat_map { |group| group[:roles] }.pluck(:name)

      expect(created).to include(*referenced)
    end
  end

  it 'provides slash command choice hashes for build registration' do
    expect(profile.heartrunes).to be_a(Hash)
    expect(profile.armour_weights).to be_a(Hash)
    expect(profile.builds).to be_a(Hash)
    expect(profile.servers).to be_a(Hash)
  end

  it 'returns startable notifiers' do
    expect(profile.notifiers).to all(respond_to(:new))
    profile.notifiers.each do |notifier|
      expect(notifier.instance_method(:start)).to be_a(UnboundMethod)
    end
  end
end
