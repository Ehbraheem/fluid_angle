class CreateContacts < ActiveRecord::Migration[5.2]
  def up
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.bigint :phone_number
      t.string :email
      t.boolean :star

      t.timestamps
    end

    add_index :contacts, :star
  end


  def down
    remove_index :contacts, :star
    drop_table :contacts
  end
end
