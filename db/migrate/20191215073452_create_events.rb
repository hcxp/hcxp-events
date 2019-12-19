class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :title
      t.string :mentions
      t.string :authors
      t.string :city
      t.string :country
      t.datetime :beginning_at
      t.bigint :facebook_id
      t.string :state
      t.references :user

      t.timestamps
    end
    add_index :events, :facebook_id, unique: true
  end
end
