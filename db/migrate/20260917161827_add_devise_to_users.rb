# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # This migration was already applied before Devise was removed.
    # The Devise columns are removed by a later migration.
  end
end