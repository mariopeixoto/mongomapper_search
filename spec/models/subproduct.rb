class Subproduct
  include MongoMapper::EmbeddedDocument

  key :brand, String
  key :name, String

end
