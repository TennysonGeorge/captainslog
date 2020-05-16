class CreateCredentialOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :credential_options do |t|
      t.references :credential, :null => false, :foreign_key => true
      t.string :label
      t.text :value

      t.timestamps
    end
  end
end
