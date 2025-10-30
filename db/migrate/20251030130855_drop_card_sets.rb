class DropCardSets < ActiveRecord::Migration[7.2]
  def change
    drop_table :card_sets, if_exists: true
  end
end
