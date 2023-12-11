class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :title, null: false
      t.string :industry, default: ""
      t.text :aboutme, default: ""
      t.text :skills, array: true, default: []
      t.text :education, array: true, default: []
      t.text :experience, array: true, default: []
      t.string :projects, array: true, default: []
      t.references :user
      t.timestamps
    end

    add_column :users, :active_profile, :integer

    User.all.each do |user|
      profile = Profile.create!(
        title: user.industry&.empty? ? "My First Profile" : user.industry || "My First Profile",
        skills: user.skills,
        education: user.education,
        experience: user.experience,
        industry: user.industry,
        user_id: user.id,
        projects: user.projects,
        aboutme: user.aboutme
      )
      user.update!(active_profile: profile.id)
    end
    
  end
end
