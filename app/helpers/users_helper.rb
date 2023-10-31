module UsersHelper
    def pdf_to_bio(pdf) # changes pdf to text and text to user bio
        def pdf_to_text(pdf)
            PDF::Reader.open(pdf) do |reader|
    
                logger.info "Converting : #{pdf}"
                pageno = 0
                txt = reader.pages.map do |page| 
    
                    pageno += 1
                    begin
                        print "Converting Page #{pageno}/#{reader.page_count}\r"
                        page.text 
                    rescue
                        logger.info "Page #{pageno}/#{reader.page_count} Failed to convert"
                        ''
                    end
    
                end
                return txt
            end
        end
    
        def text_to_user_bio(text) #
    
            OpenAI.configure do |config|
                config.access_token = ENV["OPENAI"]
            end
            client = OpenAI::Client.new
            
            response = client.chat(
                parameters: {
                    model: "gpt-3.5-turbo-16k",
                    messages: [
                        {role: "system", content:"Return JSON with values that summarize this document. Use exactly these keys: {'aboutme': 'string', 'skills': str[], 'education': str[], 'projects': str[], 'experience': str[]}. Your response must be only valid JSON."},
                        {role: "user", content: text[0]}
                    ],
                    top_p: 0.1
                }
            )
            message = response["choices"][0]["message"]["content"]
            begin
                return JSON.parse(message)
            rescue
                return false
            end
        end
        return text_to_user_bio(pdf_to_text(pdf))
    end
end
