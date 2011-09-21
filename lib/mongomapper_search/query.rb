module Plucky
  class Query
    def search(query, options={})
      #Fix class search
      if first
        first.class.search(query, options, self.criteria.source)
      else
        self
      end
    end
  end
end