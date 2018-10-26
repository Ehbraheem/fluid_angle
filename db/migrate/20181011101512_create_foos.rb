class CreateFoos < ActiveRecord::Migration[5.2]
  def up
    create_table :foos do |t|
      t.string :name

      t.timestamps
    end
  end

  def down
    drop_table :foos
  end
end
