# frozen_string_literal: true

class ExpressJob < ApplicationJob
  queue_as :default
  BLACKLIST = Set.new(%w[header footer a code template text form link script img
                         iframe icon comment button input head meta style])

  def perform(request, bio_payload, listing_payload, listing_type = 'url', user_prompt = '', tone=:passion)

    user_prompt = 'Write a cover letter for the job listing that uses the resume as support.' if user_prompt.empty?

    # generate user bio
    @bio = text_to_user_bio(bio_payload)

    return request.complete!(false, nil, ['Error while generating bio.']) unless @bio

    # generate listing
    begin
      if listing_type == 'url'
        listing_obj = http_to_listing(listing_payload)
      elsif listing_type == 'text'
        listing_obj = text_to_listing(listing_payload)
      end
      @listing = Listing.new(listing_obj)
      @profile = Profile.new(JSON.parse(@bio))
    rescue StandardError => e
      request.complete!(false, nil, [e.to_s])
    end

    # generate letter

    openers = {
      vanilla: "",
      passionate: "\"If truly loving data is wrong, I don’t want to be right. It seems like the rest of the folks at [Analytics Company] feel the same way—and that’s just one of the reasons why I think I’d be the perfect next hire for your sales team.\",
      \"I’ve been giving my friends and family free style advice since I was 10, and recently decided it’s time I get paid for it. That’s why I couldn’t believe it when I found an open personal stylist position at [Company].\",
      \"I am constantly checking my LinkedIn, Facebook, Twitter, and Instagram feeds—and not because of FOMO. Because I’m someone who wholeheartedly believes in the power of sharing ideas in online communal spaces, and I’m positive that I can help spark meaningful conversations as your next social media assistant.\"",

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

    }[tone.to_sym]

    OpenAI.configure do |config|
      config.access_token = ENV['OPENAI']
    end
    resume = JSON.parse(
      @profile.to_json(except: %i[id title]).gsub("\r", '')
    )
    resume['first_name'] = 'WriteWise'
    resume['last_name'] = 'User'
      
    system_prompt = "Write cover 2-3 paragraph cover letter as job candidate. Make sure to include a greeting and closing signature. Do not include address, phone number, or email. Do not use the word 'thrilled'. Include details about education and work experience from the resume. Don't use the education or any phrase like \"5+ years of experience\" that is mentioned in the Job-Listing. {Job-Listing: #{JSON.parse(@listing.to_json(except: :id).gsub("\r", ''))}\n
    Resume: #{resume}}.
    "
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: system_prompt },
          { role: 'user', content: user_prompt.to_s + "I want the tone to be #{tone}. "+ "Examples of strong openers include: #{openers}" }
        ],
        temperature: 1.3
      }
    )

    
    response = client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system', content: 'Rewrite the input at a 12th grade level' },
          { role: 'user', content: response['choices'][0]['message']['content'] }
        ],
        temperature: 1.3
      }
    ) unless !response['choices'][0]['message']['content']
      
    begin
      @message = response['choices'][0]['message']['content']
      @letter = TempLetter.new(profile: @profile.to_json, listing: @listing.to_json, body: @message)
      
      if @letter.save
        # success
        request.complete!(true, @letter.secure_id, @message)
      else
        # failure
        request.complete!(false, nil, @letter.errors.full_messages.to_s)
      end
    rescue StandardError
        @message = response.to_json
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
          model: 'gpt-3.5-turbo',
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
        model: 'gpt-3.5-turbo',
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
end
