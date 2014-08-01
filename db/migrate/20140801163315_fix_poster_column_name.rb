class FixPosterColumnName < ActiveRecord::Migration
  def change
    rename_column :movies, :poster_url, :original_poster_url
  end
end
