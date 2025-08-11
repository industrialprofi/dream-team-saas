class CreateRequestLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :request_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :document, null: false, foreign_key: true
      t.text :prompt
      t.text :response
      t.integer :tokens_used

      t.timestamps
    end
  end
end
