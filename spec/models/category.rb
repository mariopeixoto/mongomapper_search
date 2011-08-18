class Category
  include MongoMapper::Document
  key :name, String

  many :products
end
