class Tag
  include MongoMapper::Document
  key :name, String

  belongs_to :product
end
