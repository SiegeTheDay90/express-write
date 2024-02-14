# == Schema Information
#
# Table name: resumes
#
#  id         :bigint           not null, primary key
#  title      :string
#  header     :text             default("")
#  experience :text             default("[]")
#  education  :text             default("[]")
#  links      :text             default("[]")
#  skills     :text             default("[]")
#  user_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Resume < ApplicationRecord
    validates :title, length: {minimum: 3}
    validates_each :experience, :education, :links, :skills do |record, col, value|
        begin
            !!JSON.parse(record.read_attribute(col))
        rescue => e
            record.errors.add col, "is not a valid JSON object.", type: e.class, message: e.full_message
        end
    end

    JSON_COLUMNS = [:experience, :education, :links, :skills]

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

