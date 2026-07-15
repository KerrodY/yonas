# frozen_string_literal: true

require 'rails_helper'
require './lib/data'

RSpec.describe DATA do
  describe 'REACT_ROLES' do
    it 'has a title and roles for every group' do
      DATA::REACT_ROLES.each do |group|
        expect(group[:title]).to be_present
        expect(group[:roles]).to be_present
      end
    end

    it 'has unique titles across groups' do
      titles = DATA::REACT_ROLES.pluck(:title)
      expect(titles.uniq).to eq(titles)
    end

    it 'has unique emojis within each group so reactions map to exactly one role' do
      DATA::REACT_ROLES.each do |group|
        emojis = group[:roles].map { |role| role[:emoji] }
        expect(emojis.uniq).to eq(emojis), "duplicate emojis in '#{group[:title]}': #{emojis.tally.select { |_, count| count > 1 }.keys.join(', ')}"
      end
    end

    it 'has an emoji and a name for every react role' do
      DATA::REACT_ROLES.flat_map { |group| group[:roles] }.each do |role|
        expect(role[:name]).to be_present
        expect(role[:emoji]).to be_present
      end
    end

    it 'only references roles created during server setup' do
      created_role_names = DATA::SERVER_ROLES.pluck(:name) + DATA::WEAPONS_PARAMS.keys
      react_role_names = DATA::REACT_ROLES.flat_map { |group| group[:roles] }.pluck(:name)

      expect(created_role_names).to include(*react_role_names)
    end
  end
end
