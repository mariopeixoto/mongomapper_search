class RankedDocument
  attr_accessor :document, :rank
  
  def initialize(document)
    self.document = document
  end

  def ==(other_ranked_doc)
    self.document == other_ranked_doc.document
 end
end