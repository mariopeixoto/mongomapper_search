class Product
  include MongoMapper::Document
  include MongoMapper::Search
  key :brand, String
  key :name, String
  key :attrs, Array

  many :tags
  many :subproducts
  belongs_to :category
  
  search_in :brand, :attrs, :outlet, :name => 3 ,  {:tags => :name} => 1, {:category => :name} => 1, {:subproducts => :brand} => 1
end
