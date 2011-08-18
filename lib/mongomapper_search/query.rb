module Plucky
  class Query
    def search(query, options={})
      #Fix class search
      if first
        to_merge = first.class.search(query, options)
        find_each(to_merge.criteria.to_hash).to_a
      else
        self
      end
    end
  end
end