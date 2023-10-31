# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

ApplicationRecord.transaction do 
    # Unnecessary if using `rails db:seed:replant`
    puts "Destroying tables..."
    Letter.destroy_all
    Listing.destroy_all
    User.destroy_all
  
    puts "Resetting primary keys..."
    # For easy testing, so that after seeding, the first `User` has `id` of 1
    ApplicationRecord.connection.reset_pk_sequence!('users')
    ApplicationRecord.connection.reset_pk_sequence!('listings')
    ApplicationRecord.connection.reset_pk_sequence!('letters')
  
    puts "Creating demo user..."
    User.create!(first_name: "Demo", last_name: "User", email: "DemoUser@gmail.com", industry:"SWE", password: "password")
    puts "Creating demo listing..."
    Listing.create!(company: "Seed Company", job_title: "Job", job_description: "Seed Job", requirements: ["Req 1", "Req 2", "Req 3"], benefits: [], user_id: 1)
    puts "Creating demo letter..."
    Letter.create!(body: "Seeded this body. This would normally be written by ChatGPT. The following is from GPT: I hope this letter finds you in good health and high spirits. It has been quite some time since we last caught up, and I wanted to take a moment to send you my warmest greetings and well wishes.

        Life has been busy on my end, but I often find myself reminiscing about the great times we've shared. From our adventures in college to the countless laughs we've had, those memories are truly cherished.
        
        I hear you've been doing amazing work in your career, and I couldn't be prouder of your achievements. Your dedication and determination have always been an inspiration to me.
        
        If you ever find yourself in my neck of the woods, please do let me know. I would love to catch up and share stories over a cup of coffee.
        
        Wishing you continued success and happiness in all your endeavors. Please give my regards to your family.
        
        Take care, Jane, and here's to our enduring friendship.
        
        Warmest regards,
        
        John", listing_id: 1, user_id: 1)
   
  end