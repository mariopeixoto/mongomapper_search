class Product
  include MongoMapper::Document
  include MongoMapper::Search
  key :brand, String
  key :name, String
  key :attrs, Array

  many :tags
  many :subproducts
  belongs_to :category
  
  search_in :brand, :name, :outlet, :attrs, :tags => :name, :category => :name, :subproducts => [:brand, :name]
end
