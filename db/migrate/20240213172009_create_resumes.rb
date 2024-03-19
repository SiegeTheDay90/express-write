class CreateResumes < ActiveRecord::Migration[7.0]
  def change
    create_table :resumes do |t|
      t.string :title, default: "My Resume"
      t.text :header, default: ""
      t.text :personal, default: "{}"
      t.text :work, default: "[]"
      t.text :education, default: "[]"
      t.text :links, default: "[]"
      t.text :skills, default: "[]"

      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
