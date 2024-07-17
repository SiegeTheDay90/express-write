# frozen_string_literal: true

class GenerateResumeJob < ApplicationJob
  ACTION_VERBS = [
    "Administered", "Arranged", "Chaired", "Coordinated", "Directed", "Executed", "Delegated", "Headed", "Managed", "Operated", "Orchestrated", "Organized", "Oversaw", "Planned", "Produced", "Programmed", "Spearheaded",
    "Built", "Charted", "Created", "Designed", "Developed", "Devised", "Founded", "Engineered", "Established", "Formalized", "Formed", "Formulated", "Implemented", "Incorporated", "Initiated", "Instituted", "Introduced", "Launched", "Pioneered", "Proposed",
    "Accelerated", "Achieved", "Advanced", "Amplified", "Boosted", "Capitalized", "Conserved", "Consolidated", "Decreased", "Deducted", "Delivered", "Enhanced", "Expanded", "Expedited", "Furthered", "Gained", "Generated", "Improved", "Increased", "Lifted", "Maximized", "Outpaced", "Reconciled", "Reduced", "Saved", "Stimulated", "Sustained", "Yielded",
    "Centralized", "Clarified", "Converted", "Customized", "Digitized", "Integrated", "Merged", "Modernized", "Modified", "Overhauled", "Redesigned", "Refined", "Refocused", "Rehabilitated", "Remodeled", "Reorganized", "Replaced", "Restructured", "Revamped", "Revitalized", "Simplified", "Standardized", "Streamlined", "Strengthened", "Transformed", "Updated", "Upgraded",
    "Aligned", "Cultivated", "Directed", "Enabled", "Facilitated", "Fostered", "Guided", "Hired", "Mentored", "Mobilized", "Motivated", "Recruited", "Shaped", "Supervised", "Taught", "Trained", "Unified", "United",
    "Acquired", "Closed", "Forged", "Navigated", "Negotiated", "Partnered", "Pitched", "Secured", "Signed", "Sourced", "Upsold",
    "Advised", "Advocated", "Coached", "Consulted", "Educated", "Fielded", "Informed", "Recommended", "Resolved",
    "Analyzed", "Assembled", "Assessed", "Audited", "Calculated", "Compiled", "Discovered", "Evaluated", "Examined", "Explored", "Forecasted", "Identified", "Interpreted", "Interviewed", "Investigated", "Mapped", "Measured", "Modeled", "Projected", "Qualified", "Quantified", "Reported", "Surveyed", "Tested", "Tracked", "Visualized",
    "Authored", "Briefed", "Campaigned", "Coauthored", "Composed", "Conveyed", "Convinced", "Corresponded", "Counseled", "Critiqued", "Defined", "Documented", "Drafted", "Edited", "Illustrated", "Lobbied", "Outlined", "Persuaded", "Presented", "Promoted", "Publicized", "Reviewed", "Wrote",
    "Adjudicated", "Authorized", "Blocked", "Dispatched", "Enforced", "Ensured", "Inspected", "Itemized", "Monitored", "Screened", "Scrutinized", "Verified",
    "Attained", "Completed", "Demonstrated", "Finished", "Earned", "Exceeded", "Outperformed", "Overcame", "Reached", "Showcased", "Succeeded", "Surpassed", "Targeted", "Won"
  ]

  queue_as :default

  def perform(request, text)
    resume = text_to_resume(text)

    if !resume
      request.complete!(false, nil, ['Generator returned nil.'])
    elsif resume.include?("-@-ErrorString-@-")
      request.complete!(false, nil, resume.gsub("-@-ErrorString-@-", ""))
    else
      request.complete!(true, nil, resume)
    end
  end

  def gptEval(bullet)
    begin 
      OpenAI.configure do |config|
        config.access_token = ENV['OPENAI']
      end
      client = OpenAI::Client.new
      
      response = client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [
            { 
              role: 'system', 
              content: "You are a helpful resume-writing assistant, giving feedback bullet points. Only respond in JSON with the format: {errors: [\"Error1\", \"Error2\", \"Error3\"], suggestion: \"Improved version of bullet point\"}"
            },
            { 
              role: 'user', 
              content: bullet
            }
          ],
          response_format: { type: 'json_object' },
          temperature: 1.3,
          max_tokens: 4096
        }
      )

      grammatical_errors = JSON.parse(response['choices'][0]['message']['content'])
      

      result = {}

                                                                            # Every truthy field represents an issue
      result["Exceeds_150_characters"] = bullet.gsub(" ", "").length > 150 ? 1 : 0           # Length greater than 150
      result["errors"] = grammatical_errors["errors"]                        # Array of identified gramatical errors
      result["suggestion"] = grammatical_errors["suggestion"]                # Suggestion, if any

                                                                            # Meta fields to be used on frontend
      result["meta"] = {}
      result["meta"]["id"] = SecureRandom.alphanumeric
      result["meta"]["total"] = result["errors"].length + result["length"]
      result["meta"]["dismissed"] = false
      
      return result
    rescue
      return nil
    end

  end

  def text_to_resume(text)
    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system',
            content: "Covert input to JSON with values that summarize this document. Use exactly this shape, keys, and data types: {
              personal: {
                  firstName: '',
                  lastName: '',
                  profession: '',
                  phoneNumber: '',
                  email: '',
                  website: ''
              },
              work: [{
                  companyName: '',
                  jobTitle: '',
                  city: '',
                  location: '',
                  from: '',
                  to: '',
                  bullets: [\"Bullet 1\", \"Bullet 2\", \"Bullet 3\"],
                  current: boolean
                }],
              education: [{
                  institutionName: '',
                  fieldOfStudy: '',
                  degreeType: '',
                  city: '',
                  location: '',
                  to: '',
                  bullets: [\"Bullet 1\", \"Bullet 2\", \"Bullet 3\"],
                  current: boolean
                }],
              skills: [\"Skill 1\", \"Skill 2\", \"Skill 3\"],
          }. If 'skills' array would be empty, use two generic professional skills such as Time Management, Communication, Teamwork, or Problem Solving" },
          { role: 'user', content: text }
        ],
        response_format: { type: 'json_object' },
        temperature: 1.3,
        max_tokens: 4096
      }
    )

    begin 
      resume = JSON.parse(response['choices'][0]['message']['content'])
      resume["totalIssues"] ||= 0
      resume["work"].each do |work|
        work["totalIssues"] ||= 0
        work["bullets"].map!{|bullet|                        # Map text bullets to objects containing text and a rating
         obj = {text: bullet, rating: gptEval(bullet)}
         resume["totalIssues"] += obj[:rating]["meta"]["total"]
         work["totalIssues"] += obj[:rating]["meta"]["total"]
         return obj
        } 
      end
      return JSON.unparse(resume)
    rescue JSON::ParserError
      BugReport.create!(
        body: "Invalid JSON: #{response['choices'][0]['message']['content']}",
        user_agent: "GenerateResumeJob"
      )
      return "-@-ErrorString-@-Invalid JSON: #{response['choices'][0]['message']['content']}"
    rescue StandardError => e
      BugReport.create!(
        body: "ERROR: #{e.to_s}}",
        user_agent: "GenerateResumeJob"
      )
      return "-@-ErrorString-@-"+e.to_s
    end
  end
end
