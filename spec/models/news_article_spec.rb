require 'rails_helper'

RSpec.describe NewsArticle, type: :model do
  describe 'persistence' do
    it 'saves with a url' do
      article = described_class.create!(url: 'https://www.newworld.com/en-gb/news/article-1')
      expect(article).to be_persisted
      expect(article.url).to eq('https://www.newworld.com/en-gb/news/article-1')
    end
  end

  describe 'upsert for tracking latest article' do
    it 'creates a new record when none exists' do
      described_class.upsert({ url: 'https://www.newworld.com/news/first', id: 1 }, unique_by: :id)

      expect(described_class.count).to eq(1)
      expect(described_class.first.url).to eq('https://www.newworld.com/news/first')
    end

    it 'updates the existing record on subsequent upserts' do
      described_class.upsert({ url: 'https://www.newworld.com/news/first', id: 1 }, unique_by: :id)
      described_class.upsert({ url: 'https://www.newworld.com/news/second', id: 1 }, unique_by: :id)

      expect(described_class.count).to eq(1)
      expect(described_class.first.url).to eq('https://www.newworld.com/news/second')
    end
  end

  describe 'new news detection' do
    it 'returns nil url when no articles exist' do
      expect(described_class.first&.url).to be_nil
    end

    it 'returns the stored url when an article exists' do
      described_class.create!(url: 'https://www.newworld.com/news/latest')
      expect(described_class.first.url).to eq('https://www.newworld.com/news/latest')
    end
  end
end
