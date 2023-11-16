class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.boolean :complete, default: false
      t.boolean :ok
      t.string :messages, default: ""
      t.string :resource_type, null: false
      t.bigint :resource_id
      t.index [:resource_type, :resource_id]

      t.timestamps
    end
  end
end
