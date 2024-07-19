# frozen_string_literal: true

class GenerateResumeJob < ApplicationJob
  ACTION_VERBS_PAST = Set.new(["administered", "arranged", "chaired", "coordinated", "directed", "executed", "delegated", "headed", "managed", "operated", "orchestrated", "organized", "oversaw", "planned", "produced", "programmed", "spearheaded", "built", "charted", "created", "designed", "developed", "devised", "founded", "engineered", "established", "formalized", "formed", "formulated", "implemented", "incorporated", "initiated", "instituted", "introduced", "launched", "pioneered", "proposed", "accelerated", "achieved", "advanced", "amplified", "boosted", "capitalized", "conserved", "consolidated", "decreased", "deducted", "delivered", "enhanced", "expanded", "expedited", "furthered", "gained", "generated", "improved", "increased", "lifted", "maximized", "outpaced", "reconciled", "reduced", "saved", "stimulated", "sustained", "yielded", "centralized", "clarified", "converted", "customized", "digitized", "integrated", "merged", "modernized", "modified", "overhauled", "redesigned", "refined", "refocused", "rehabilitated", "remodeled", "reorganized", "replaced", "restructured", "revamped", "revitalized", "simplified", "standardized", "streamlined", "strengthened", "transformed", "updated", "upgraded", "aligned", "cultivated", "directed", "enabled", "facilitated", "fostered", "guided", "hired", "mentored", "mobilized", "motivated", "recruited", "shaped", "supervised", "taught", "trained", "unified", "united", "acquired", "closed", "forged", "navigated", "negotiated", "partnered", "pitched", "secured", "signed", "sourced", "upsold", "advised", "advocated", "coached", "consulted", "educated", "fielded", "informed", "recommended", "resolved", "analyzed", "assembled", "assessed", "audited", "calculated", "compiled", "discovered", "differentiated", "evaluated", "examined", "explored", "forecasted", "identified", "interpreted", "interviewed", "investigated", "mapped", "measured", "modeled", "projected", "qualified", "quantified", "reported", "surveyed", "tested", "tracked", "visualized", "authored", "briefed", "campaigned", "coauthored", "composed", "conveyed", "convinced", "corresponded", "counseled", "critiqued", "defined", "documented", "drafted", "edited", "illustrated", "lobbied", "outlined", "persuaded", "presented", "promoted", "publicized", "reviewed", "wrote", "adjudicated", "authorized", "blocked", "dispatched", "enforced", "ensured", "inspected", "itemized", "monitored", "screened", "scrutinized", "verified", "attained", "completed", "demonstrated", "finished", "earned", "exceeded", "outperformed", "overcame", "reached", "showcased", "succeeded", "surpassed", "targeted", "won"])

  ACTION_VERBS_PRESENT = Set.new(["administer", "arrange", "chair", "coordinate", "direct", "execute", "delegate", "head", "manage", "operate", "orchestrate", "organize", "oversee", "plan", "produce", "program", "spearhead", "build", "chart", "create", "design", "develop", "devise", "found", "engineer", "establish", "formalize", "form", "formulate", "implement", "incorporate", "initiate", "institute", "introduce", "launch", "pioneer", "propose", "accelerate", "achieve", "advance", "amplify", "boost", "capitalize", "conserve", "consolidate", "decrease", "deduct", "deliver", "enhance", "expand", "expedite", "further", "gain", "generate", "improve", "increase", "lift", "maximize", "outpace", "reconcile", "reduce", "save", "stimulate", "sustain", "yield", "centralize", "clarify", "convert", "customize", "digitize", "integrate", "merge", "modernize", "modify", "overhaul", "redesign", "refine", "refocus", "rehabilitate", "remodel", "reorganize", "replace", "restructure", "revamp", "revitalize", "simplify", "standardize", "streamline", "strengthen", "transform", "update", "upgrade", "align", "cultivate", "direct", "enable", "facilitate", "foster", "guide", "hire", "mentor", "mobilize", "motivate", "recruit", "shape", "supervise", "teach", "train", "unify", "unite", "acquire", "close", "forge", "navigate", "negotiate", "partner", "pitch", "secure", "sign", "source", "upsell", "advise", "advocate", "coach", "consult", "educate", "field", "inform", "recommend", "resolve", "analyze", "assemble", "assess", "audit", "calculate", "compile", "discover", "differentiate", "evaluate", "examine", "explore", "forecast", "identify", "interpret", "interview", "investigate", "map", "measure", "model", "project", "qualify", "quantify", "report", "survey", "test", "track", "visualize", "author", "brief", "campaign", "coauthor", "compose", "convey", "convince", "correspond", "counsel", "critique", "define", "document", "draft", "edit", "illustrate", "lobby", "outline", "persuade", "present", "promote", "publicize", "review", "write", "adjudicate", "authorize", "block", "dispatch", "enforce", "ensure", "inspect", "itemize", "monitor", "screen", "scrutinize", "verify", "attain", "complete", "demonstrate", "finish", "earn", "exceed", "outperform", "overcome", "reach", "showcase", "succeed", "surpass", "target", "win"])

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
      

      result = {}                                                                      # Every truthy field represents an issue
      if bullet.gsub(" ", "").length > 150
        result["Exceeds_150_characters"] = true    # Length greater than 150
      end
      if bullet.downcase.split(" ").none?{|word| ACTION_VERBS_PAST.include?(word) || ACTION_VERBS_PRESENT.include?(word) }
        result["Missing_an_approved_action_verb"] = true
      end
      result["errors"] = grammatical_errors["errors"]                                  # Array of identified gramatical errors
      result["suggestion"] = grammatical_errors["suggestion"]                          # Suggestion, if any
                                                                            
      result["meta"] = {}                                                               # Meta fields to be used on frontend
      result["meta"]["id"] = SecureRandom.alphanumeric
      result["meta"]["total"] = result["errors"].length + result.keys.length-3
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
            }. If 'skills' array would be empty, use two generic professional skills such as Time Management, Communication, Teamwork, or Problem Solving" 
          },
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
      resume["work"].each do |item|
        item["totalIssues"] ||= 0
        item["bullets"].map! do |bullet|                        # Map bullet strings to objects containing text and a rating
          obj = {"text" => bullet, "rating" => gptEval(bullet)}
          resume["totalIssues"] += obj["rating"]["meta"]["total"]
          item["totalIssues"] += obj["rating"]["meta"]["total"]
          obj
        end
      end

      resume["education"].each do |item|
        item["totalIssues"] ||= 0
        item["bullets"].map! do |bullet|                        # Map bullet strings to objects containing text and a rating
          obj = {"text" => bullet, "rating" => nil}
          obj
        end
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
