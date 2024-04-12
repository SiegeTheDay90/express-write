# == Schema Information
#
# Table name: resumes
#
#  id         :bigint           not null, primary key
#  title      :string           default("My Resume")
#  header     :text             default("")
#  personal   :text             default("{}")
#  work       :text             default("[]")
#  education  :text             default("[]")
#  links      :text             default("[]")
#  skills     :text             default("[]")
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Resume < ApplicationRecord
    validates :title, length: {minimum: 3}
    
    JSON_COLUMNS = [:work, :education, :links, :skills, :personal]
    validates_each JSON_COLUMNS do |record, col, value|
        begin
            !!JSON.parse(record.read_attribute(col))
        rescue => e
            record.errors.add col, "is not a valid JSON object.", type: e.class, message: e.full_message
        end
    end


    JSON_COLUMNS.each do |column|
        define_method(column) do 
            value = read_attribute(column)
            begin
                return JSON.parse(value)
            rescue
                return nil
            end
        end

        define_method(column.to_s+"=") do |val|
            super(JSON.unparse(val))
        end
        
    end
end

