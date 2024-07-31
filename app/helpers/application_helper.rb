# frozen_string_literal: true

module ApplicationHelper
    require 'docx'

    def pdf_to_text(pdf)
      debugger
      PDF::Reader.open(pdf) do |reader|
        logger.info "Converting : #{pdf}"
        pageno = 0
        pages = reader.pages.map do |page|
          pageno += 1
          begin
            print "Converting Page #{pageno}/#{reader.page_count}\r"
            page.text
          rescue StandardError
            logger.info "Page #{pageno}/#{reader.page_count} Failed to convert"
            ''
          end
        end
  
        return pages.join("\n\n")
      end
    end
  
    def docx_to_text(docx)
      doc = Docx::Document.open(docx)
      txt = ''
  
      doc.paragraphs.each_with_index do |p, i|
        txt += i.zero? ? '' : "\n"
        txt += p.to_s if p
      end
  
      txt
    end
end
