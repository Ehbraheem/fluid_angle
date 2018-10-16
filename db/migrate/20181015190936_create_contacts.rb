class CreateContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.number :phone_number
      t.string :email
      t.boolean :star

      t.timestamps
    end
  end
end
