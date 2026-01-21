# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# ApplicationRecord.transaction do
#   # Unnecessary if using `rails db:seed:replant`
#   puts 'Destroying tables...'
#   Request.destroy_all
#   Profile.destroy_all
#   Letter.destroy_all
#   Listing.destroy_all
#   User.destroy_all

#   puts 'Resetting primary keys...'
#   # For easy testing, so that after seeding, the first `User` has `id` of 1
#   ApplicationRecord.connection.reset_pk_sequence!('users')
#   ApplicationRecord.connection.reset_pk_sequence!('listings')
#   ApplicationRecord.connection.reset_pk_sequence!('letters')
#   ApplicationRecord.connection.reset_pk_sequence!('profiles')
#   ApplicationRecord.connection.reset_pk_sequence!('requests')
#   puts
#   puts 'Creating demo user...'
#   User.create!(first_name: 'Demo', last_name: 'User', email: 'demo@user.io', password: 'password')
#   puts 'Creating demo profiles...'
#   first_profile = Profile.create!(
#     title: 'Frontend',
#     industry: 'Web Development',
#     skills: ['Next.js', 'CSS', 'Rails'],
#     user_id: 1
#   )
#   first_profile.set_active
#   Profile.create!(
#     title: 'Backend',
#     industry: 'Data Analysis',
#     skills: ['Node.js', 'Express.js', 'MySQL'],
#     user_id: 1
#   )
#   puts 'Creating demo listings...'
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   Listing.create!(company: 'Seed Company', job_title: 'Job', job_description: 'Seed Job',
#                   requirements: ['Req 1', 'Req 2', 'Req 3'], benefits: [], user_id: 1)
#   puts 'Creating demo letter...'
#   Letter.create!(body: "Seeded this body. This would normally be written by ChatGPT. The following is from GPT: I hope this letter finds you in good health and high spirits. It has been quite some time since we last caught up, and I wanted to take a moment to send you my warmest greetings and well wishes.

#         Life has been busy on my end, but I often find myself reminiscing about the great times we've shared. From our adventures in college to the countless laughs we've had, those memories are truly cherished.

#         I hear you've been doing amazing work in your career, and I couldn't be prouder of your achievements. Your dedication and determination have always been an inspiration to me.

#         If you ever find yourself in my neck of the woods, please do let me know. I would love to catch up and share stories over a cup of coffee.

#         Wishing you continued success and happiness in all your endeavors. Please give my regards to your family.

#         Take care, Jane, and here's to our enduring friendship.

#         Warmest regards,

#         John", listing_id: 1, user_id: 1)
#   puts
# end

# db/seeds.rb

sites = [
  # 🎓 Education & Nonprofit Jobs
  { name: "SchoolSpring", url: "https://www.schoolspring.com", description: "K-12 education", slug: SecureRandom.urlsafe_base64, category: "Education" },
  { name: "HigherEdJobs", url: "https://higheredjobs.com", description: "Colleges & universities", slug: SecureRandom.urlsafe_base64, category: "Education" },
  { name: "OlasJobs", url: "https://olasjobs.org/", description: "Jobs in school districts for K-12 education", slug: SecureRandom.urlsafe_base64, category: "Education" },
  { name: "EdJoin", url: "https://www.edjoin.org", description: "Public school systems", slug: SecureRandom.urlsafe_base64, category: "Education" },
  { name: "Idealist", url: "https://www.idealist.org", description: "Nonprofits & social impact jobs", slug: SecureRandom.urlsafe_base64, category: "Education" },
  { name: "Teach NYC", url: "https://www.teachnyc.net", description: "The official portal for NYC public school teachers", slug: SecureRandom.urlsafe_base64, category: "Education" },

  # 💻 Tech Jobs
  { name: "Welcome to the Jungle", url: "https://us.welcometothejungle.com/", description: "Tech-focused job listings (formerly Otta)", slug: SecureRandom.urlsafe_base64, category: "Tech" },
  { name: "GoRails Jobs", url: "https://jobs.gorails.com/", description: "Ruby-focused software jobs", slug: SecureRandom.urlsafe_base64, category: "Tech" },
  { name: "Wellfound", url: "https://wellfound.com", description: "Startups & tech roles", slug: SecureRandom.urlsafe_base64, category: "Tech" },
  { name: "Dice", url: "https://www.dice.com", description: "IT, engineering, cybersecurity", slug: SecureRandom.urlsafe_base64, category: "Tech" },
  { name: "Built In NYC", url: "https://www.builtinnyc.com/", description: "NYC-based tech & startup jobs", slug: SecureRandom.urlsafe_base64, category: "Tech" },

  # 🌐 Remote Jobs
  { name: "FlexJobs", url: "https://www.flexjobs.com", description: "Curated, scam-free remote listings", slug: SecureRandom.urlsafe_base64, category: "Remote" },
  { name: "We Work Remotely", url: "https://weworkremotely.com", description: "Remote job listings", slug: SecureRandom.urlsafe_base64, category: "Remote" },
  { name: "Remote.co", url: "https://remote.co", description: "Remote jobs and resources", slug: SecureRandom.urlsafe_base64, category: "Remote" },
  { name: "Remote OK", url: "https://remoteok.io", description: "Remote job board", slug: SecureRandom.urlsafe_base64, category: "Remote" },
  { name: "Working Nomads", url: "https://workingnomads.co", description: "Curated remote jobs", slug: SecureRandom.urlsafe_base64, category: "Remote" },
  { name: "Jobspresso", url: "https://jobspresso.co", description: "Remote jobs in tech, marketing, and more", slug: SecureRandom.urlsafe_base64, category: "Remote" },

  # 🍽️ Culinary & Hospitality
  { name: "Culinary Agents", url: "https://culinaryagents.com", description: "Restaurants, chefs, FOH/BOH", slug: SecureRandom.urlsafe_base64, category: "Culinary" },
  { name: "Poached Jobs", url: "https://poachedjobs.com", description: "Restaurant & hospitality work", slug: SecureRandom.urlsafe_base64, category: "Culinary" },
  { name: "Good Food Jobs", url: "https://goodfoodjobs.com", description: "Food systems & sustainability roles", slug: SecureRandom.urlsafe_base64, category: "Culinary" },
  { name: "Hospitality Online", url: "https://hospitalityonline.com", description: "Hotels & resorts", slug: SecureRandom.urlsafe_base64, category: "Culinary" },
  { name: "HCareers", url: "https://hcareers.com", description: "Hospitality management roles", slug: SecureRandom.urlsafe_base64, category: "Culinary" },

  # 🎨 Creative
  { name: "Behance Job List", url: "https://www.behance.net/joblist", description: "Creative career opportunities", slug: SecureRandom.urlsafe_base64, category: "Creative" },
  { name: "Dribbble Jobs", url: "https://dribbble.com/jobs", description: "Design, UI/UX roles", slug: SecureRandom.urlsafe_base64, category: "Creative" },
  { name: "Mediabistro", url: "https://mediabistro.com", description: "Media, writing, publishing", slug: SecureRandom.urlsafe_base64, category: "Creative" },
  { name: "Working Not Working", url: "https://workingnotworking.com", description: "Freelance creatives", slug: SecureRandom.urlsafe_base64, category: "Creative" },
  { name: "Creative Circle", url: "https://creativecircle.com", description: "Marketing & creative staffing", slug: SecureRandom.urlsafe_base64, category: "Creative" },

  # 🏛️ Government
  { name: "USAJobs", url: "https://www.usajobs.gov", description: "Federal government jobs", slug: SecureRandom.urlsafe_base64, category: "Government" },
  { name: "GovernmentJobs.com", url: "https://www.governmentjobs.com", description: "State & local government roles", slug: SecureRandom.urlsafe_base64, category: "Government" },
  { name: "NY State / City Jobs", url: "https://www.ny.gov/services/jobs", description: "New York public sector jobs", slug: SecureRandom.urlsafe_base64, category: "Government" },
  { name: "Public Service Careers", url: "https://publicservicecareers.org", description: "Public sector roles", slug: SecureRandom.urlsafe_base64, category: "Government" },

  # 💼 Entry-Level
  { name: "WayUp", url: "https://www.wayup.com", description: "Internships & entry-level jobs", slug: SecureRandom.urlsafe_base64, category: "Entry-Level" },
  { name: "Handshake", url: "https://joinhandshake.com", description: "College students & recent grads", slug: SecureRandom.urlsafe_base64, category: "Entry-Level" },
  { name: "Parker Dewey", url: "https://www.parkerdewey.com", description: "Micro-internships", slug: SecureRandom.urlsafe_base64, category: "Entry-Level" },
  { name: "RippleMatch", url: "https://www.ripplematch.com", description: "Entry-level recruiting", slug: SecureRandom.urlsafe_base64, category: "Entry-Level" },

  # 🛠️ Trades
  { name: "iHireConstruction", url: "https://www.ihireconstruction.com", description: "Construction & skilled trades", slug: SecureRandom.urlsafe_base64, category: "Trades" },
  { name: "TradeHounds", url: "https://tradehounds.com", description: "Skilled trades networking & jobs", slug: SecureRandom.urlsafe_base64, category: "Trades" },
  { name: "ConstructionJobs.com", url: "https://www.constructionjobs.com", description: "Construction industry roles", slug: SecureRandom.urlsafe_base64, category: "Trades" },
  { name: "BlueRecruit", url: "https://bluerecruit.com", description: "Skilled trades & labor jobs", slug: SecureRandom.urlsafe_base64, category: "Trades" },

  # 🔎 General
  { name: "LinkedIn Jobs", url: "https://www.linkedin.com", description: "Networking + job listings", slug: SecureRandom.urlsafe_base64, category: "General" },
  { name: "Indeed", url: "https://www.indeed.com", description: "Large job aggregator", slug: SecureRandom.urlsafe_base64, category: "General" },
  { name: "Glassdoor", url: "https://www.glassdoor.com", description: "Jobs, salaries, company reviews", slug: SecureRandom.urlsafe_base64, category: "General" },
  { name: "Monster", url: "https://www.monster.com", description: "Established job search platform", slug: SecureRandom.urlsafe_base64, category: "General" }
]

sites.each do |site|
  Site.find_or_create_by!(url: site[:url]) do |s|
    s.name = site[:name]
    s.description = site[:description]
    s.slug = site[:slug]
    s.category = site[:category]
  end
end