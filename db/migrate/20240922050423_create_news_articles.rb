class CreateNewsArticles < ActiveRecord::Migration[7.2]
  def change
    create_table :news_articles do |t|
      t.string :url, null: false
      t.timestamps
    end
  end
end