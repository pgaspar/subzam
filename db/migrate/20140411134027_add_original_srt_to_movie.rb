class AddOriginalSrtToMovie < ActiveRecord::Migration
  def change
    add_column :movies, :original_srt, :text
  end
end
