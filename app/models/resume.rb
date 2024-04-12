# frozen_string_literal: true

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
  validates :title, length: { minimum: 3 }

  JSON_COLUMNS = %i[work education links skills personal].freeze
  validates_each JSON_COLUMNS do |record, col, _value|
    !JSON.parse(record.read_attribute(col)).nil?
  rescue StandardError => e
    record.errors.add col, 'is not a valid JSON object.', type: e.class, message: e.full_message
  end

  JSON_COLUMNS.each do |column|
    define_method(column) do
      value = read_attribute(column)
      begin
        JSON.parse(value)
      rescue StandardError
        nil
      end
    end

    define_method("#{column}=") do |val|
      super(JSON.unparse(val))
    end
  end
end
