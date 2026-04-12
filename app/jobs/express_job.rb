# frozen_string_literal: true

class ExpressJob < ApplicationJob
  queue_as :default
  retry_on Faraday::TooManyRequestsError,
           wait: :exponentially_longer,
           attempts: 8
  BLACKLIST = Set.new(%w[header footer a code template text form link script img
                         iframe icon comment button input head meta style])
  PROMPTS = {     
    basic: "",
    admiration: "\"I pretty much spent my childhood in the cheap seats at Cubs games, snacking on popcorn and cheering on the team with my grandfather. It’s that memory that’s shaped my career—from helping to establish the sports marketing major at my university to leading a college baseball team to an undefeated season as assistant coach—and what led me to apply for this position at the Chicago Cubs.\",
    \"When I was seven, I wanted to be the GEICO gecko when I grew up. I eventually realized that wasn’t an option, but you can imagine my excitement when I came across your events manager position, which would have me working side by side with my favorite company mascot.\",
    \"When I attended SXSW for the first time last month, I didn’t want to leave. So I decided I shouldn’t—and immediately went to check out job openings at the company.\",
    \"If I could make the NYC apartment rental process better for just one person, I would feel like the horrors of my recent search would all be worth it. So a customer service role at [Apartment Search Company], where I could do it every day? I can’t think of anything more fulfilling.\",
    \"[Vacation Rental Company] is synonymous with luxury and escape, known for spaces that inspire. I’ve felt this firsthand every time I’ve stayed at one of your properties—whether I was throwing a bachelorette party or working from home in a new locale—and I would love the chance to contribute to this reputation as your destination manager.\"",

    confident: "\"My last boss once told me that my phone manner could probably defuse an international hostage situation. I’ve always had a knack for communicating with people—the easygoing and the difficult alike—and I’d love to bring that skill to your open office manager position.\",
    \"Among my colleagues, I’m known as the one who can pick up the pieces, no matter what amount of you-know-what hits the fan. Which is why I think there’s no one better to fill this customer service leader position.\",
    \"Last December, I ousted our company’s top salesperson from his spot—and he hasn’t seen it since. Which means, I’m ready for my next big challenge, and the sales manager role at your company is exactly what I’m looking for.\",
    \"After spending three years managing the internal communications for a 2,000-person company, I could plan a quarterly town hall or draft an interoffice memo in my sleep. What do I want to do next? Put that experience to work as a consultant for executives looking to level up their communications strategy.\",
    \"You might be wondering what a 15-year veteran of the accounting world is doing applying to an operations role at a food startup. While I agree the shift is a little strange, I know you’re looking for someone who’s equal parts foodie and financial expert, and I think that means I’m your person.\",
    \"Over the last 10 years, I’ve built my career on one simple principle: Work smarter. I’m the person who looks for inefficient procedures, finds ways to streamline them, and consistently strives to boost the productivity of everyone around me. It’s what’s earned me three promotions in the supply chain department at my current company, and it’s what I know I can do as the new operations analyst for [Company].\"",

    humorous: "\"Have you ever had your mom call five times a day asking for a status update on how your job search is going, and then sound incredulous that you haven’t made more progress since the last phone call? That’s my life right now. But I’m hoping that soon my life will revolve around being your full-time social media manager. The good news is, I bring more to the table than just an overbearing mom. Let me tell you more.\",
    \"I considered submitting my latest credit card statement as proof of just how much I love online shopping, but I thought a safer approach might be writing this cover letter and describing all the reasons I’m the one who can take [E-Commerce Company]’s business to the next level.\",
    \"I never thought that accidentally dropping my iPhone out of a second story window would change my life (it’s a funny story—ask me about it). But thanks to my misfortune, I discovered [Phone Repair Company]—and found my dream job as an expansion associate.\""

  }

  def perform(request_id, resume, listing, listing_type = 'url', additional_prompt = '', tone = :basic)
    request = Request.find(request_id)
    return if request.complete
    additional_prompt = 'Write a cover letter for the job listing that uses the resume as support.' if additional_prompt.empty?

    # generate user bio
    @bio = text_to_user_bio(resume)

    return request.complete!(false, nil, ['Error while generating bio.']) unless @bio

    # generate listing
    begin
      if listing_type == 'url'
        listing_obj = http_to_listing(listing)
      elsif listing_type == 'text'
        listing_obj = text_to_listing(listing)
      end
      @listing = Listing.new(listing_obj)
      @profile = Profile.new(JSON.parse(@bio))
    rescue StandardError => e
      request.complete!(false, nil, [e.to_s])
    end


    # Construct resume from JSON
    resume = JSON.parse(@profile.to_json(except: %i[id title]).gsub("\r", '')    )
    resume['first_name'] = 'ExpressWrite'
    resume['last_name'] = 'User'

    # Define systemp prompt
    system_prompt = "Write cover cover letter as job candidate. It should be at least 3 paragraphs. Ensure the letter starts with \"Dear Hiring Manager\" and signs off as \"ExpressWrite User\". Do not include address, phone number, or email. Do not use the word 'thrilled'. Include details about education and work experience from the resume. Don't use the education or any phrase like \"5+ years of experience\" that is mentioned in the Job-Listing. {Job-Listing: #{JSON.parse(@listing.to_json(except: :id).gsub("\r", ''))}\n
    Resume: #{resume}}."

    if tone.is_a?(String)
      content_prompt = "I want the tone to be my own. An example of my writing is: #{tone}\n Additionally: #{additional_prompt.to_s}"
      tone_type = "custom"
    else
      content_prompt = "I want the tone to be #{tone}. "+ "Example of this tone: #{PROMPTS[tone]}" + " Additionally: #{additional_prompt.to_s}"
      tone_type = tone.to_s
    end

    # generate letter with given tone
    begin
      @message = generate_letter(system_prompt, content_prompt)
      if request.resource_id
        @letter = TempLetter.new(profile: @profile.to_json, listing: @listing.to_json, secure_id: request.resource_id, body: @message, tone: tone_type)
      else
        @letter = TempLetter.new(profile: @profile.to_json, listing: @listing.to_json, body: @message, tone: tone_type)
      end
      
      if @letter.save
        # success
        request.reload
        if request.count == 3
          request.complete!(true, @letter.secure_id, @message)
        else
          request.incremement_count!(@letter.secure_id)
        end
      else
        # failure
        request.complete!(false, nil, @letter.errors.full_messages.to_s)
      end
    rescue StandardError => e
      @message = e.to_s
      request.complete!(false, nil, @message)
    end
    
  end
    




  def text_to_user_bio(text)
    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          { role: 'system',
          content: 'Return JSON with values that summarize this document. Use exactly these keys: {"aboutme": "string", "skills": str[], "education": str[], "projects": str[], "experience": str[]}. Your response must be only valid JSON with a flat shape. "aboutme" should be at least 2 sentences long. If "skills" would be empty, use generic professional skills such as Time Management, Communication, Teamwork, Problem Solving' },
          { role: 'user', content: text }
        ],
      response_format: { type: 'json_object' },
      temperature: 1.4
      # max_tokens: 10000
      }
    )

    begin
      response['choices'][0]['message']['content']
    rescue StandardError
      false
    end
  end






  # Turns text into a job-listing hash
  def text_to_listing(text)
    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    client = OpenAI::Client.new

    response = client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          { role: 'system',
            content: 'Summarize. Respond with only valid JSON with exact keys: {"company": "string", "job_title": "string", "job_description": "string", "requirements": str[], "benefits": str[]}. Ensure there is no trailing comma after the last value.' },
          { role: 'user', content: text }
        ],
        response_format: { type: 'json_object' },
        temperature: 0.9
        # max_tokens: 10000
      }
    )

    begin
      message = response['choices'][0]['message']['content']
      output = JSON.parse(message)
      logger.info('Listing Parsed on First Try')
    rescue JSON::ParserError
      origin = message.dup
      message.insert(-2, "''") # Fills empty benefits value
      message.gsub!("'", '"') # Replace single quotes with double quotes
      begin
        output = JSON.parse(message)
        logger.info('Listing Parsed on Second Try')
      rescue JSON::ParserError
        output = JSON.parse("#{origin[0..-4]}''}") # Removes trailing comma from JSON string
        logger.info('Listing Parsed on Third Try')
      end
    rescue StandardError
      return false
    end
    output
  end

  # turns http response into minimized string ready to send to GPT
  def http_to_listing(response_body)
    raw_doc = Nokogiri::HTML(response_body)
    memo = raw_doc.search('main')
    document = memo.empty? ? raw_doc.search('body')[0] : memo[0]

    BLACKLIST.each { |tag| document.search(tag).remove }
    document.traverse do |node|
      node.element? && node.attributes.each_key { |name| node.remove_attribute(name) }
    end
    document.prepend_child(raw_doc.search('title')[0]) unless raw_doc.search('title').empty?

    trimmed_doc = document.to_s
    trimmed_doc.gsub!(/\n/, "\s\s")
    trimmed_doc.gsub!('  ', '')
    trimmed_doc.gsub!('<div>', '')
    trimmed_doc.gsub!('</div>', '')
    text_to_listing(trimmed_doc)
  end

  def generate_letter(system_prompt, content_prompt)
    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: content_prompt }
        ],
        temperature: 1.2
      }
    )
    return response['choices'][0]['message']['content']
  end
end
