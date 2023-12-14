module UsersHelper
    require 'docx'

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

    def docx_to_text(docx)
        doc = Docx::Document.open(docx)
        txt = ""

        doc.paragraphs.each_with_index do |p, i|
            txt += i == 0 ? "" : "\n"
            txt += p.to_s
        end

        return txt
    end

end