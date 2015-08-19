class SchemaElement < ActiveRecord::Base
  belongs_to :instance
  has_many :schema_fields
end
