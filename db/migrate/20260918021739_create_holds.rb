# frozen_string_literal: true

class CreateHolds < ActiveRecord::Migration[8.1]
  def change
    create_table :holds do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :expires_at, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end

    add_index :holds, :expires_at

    add_check_constraint(
      :holds,
      "status IN ('active', 'expired', 'converted', 'cancelled')",
      name: "holds_status_check"
    )
  end
end