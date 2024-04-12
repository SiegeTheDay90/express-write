# == Schema Information
#
# Table name: bug_reports
#
#  id                :bigint           not null, primary key
#  body              :text             not null
#  email             :text
#  replied           :boolean          default(FALSE)
#  requires_response :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  name              :string
#  user_agent        :text
#
class BugReport < ApplicationRecord
    validates :body, length: {minimum: 25}
    
    
    # JSON_COLUMNS = [:user]
    # validates_each JSON_COLUMNS do |record, col, value|
    #     begin
    #         !!JSON.parse(record.read_attribute(col))
    #     rescue => e
    #         record.errors.add col, "is not a valid JSON object.", type: e.class, message: e.full_message
    #     end
    # end

    # JSON_COLUMNS.each do |column|
    #     define_method(column) do 
    #         value = read_attribute(column)
    #         begin
    #             return JSON.parse(value)
    #         rescue
    #             return nil
    #         end
    #     end

    #     define_method(column.to_s+"=") do |val|
    #         super(JSON.unparse(val))
    #     end
        
    # end
end
