module MongoMapper
  module Search
    extend ActiveSupport::Concern
    
    included do
      cattr_accessor :search_fields, :allow_empty_search, :stem_keywords, :match
    end

    def self.included(base)
      @classes ||= []
      @classes << base
    end

    def self.classes
      @classes
    end
    
    module ClassMethods
      
      def search_in(*args)
        options = args.last.is_a?(Hash) && [:allow_empty_search, :stem_keywords].include?(args.last.keys.first) ? args.pop : {}
        self.match              = [:any, :all].include?(options[:match]) ? options[:match] : :any
        self.allow_empty_search = [true, false].include?(options[:allow_empty_search]) ? options[:allow_empty_search] : false
        self.stem_keywords      = [true, false].include?(options[:stem_keywords]) ? options[:allow_empty_search] : false
        self.search_fields      = self.search_fields || {}
        
        args.each do |arg|
          if arg.class == Hash
            arg.each do |key, value|
              if key.class == Hash
                key.each do |sub_key, sub_value|
                  field = "_#{sub_key}_#{sub_value}".to_sym
                  key field, Array
                  ensure_index field, :background => true
                  self.search_fields[key] = value
                end
              else
                field = "_#{key}".to_sym
                key field, Array
                ensure_index field, :background => true
                self.search_fields[key] = value
              end
            end
          else
              field = "_#{arg}".to_sym
              key field, Array
              ensure_index field, :background => true
              self.search_fields[arg] = 1
          end
        end
              
        before_save :set_keywords
      end
      
      def search_a_field(search_match, field, regexed_keywords, results, boost, terms, total, criteria)
        if search_match == :all
          field_results = where(criteria).where(field => { "$all" => regexed_keywords })
        elsif search_match == :any
          field_results = where(criteria).where(field => regexed_keywords )
        end
        field_results.each do |field_result|
          result = RankedDocument.new(field_result)
          rank = 0
          terms.each do |term|
            rank += boost * tf_idf(field, term, result.document[field], total)
          end

          if !results.include?(result)
            result.rank = rank
            results << result
          else
            i = results.index result
            results[i].rank += rank
          end
        end
      end

      def tf_idf(field, term, terms, total)
        tf(term, terms) * idf(field, term, total)
      end

      def tf(term, terms)
        terms.count(term)
      end

      def idf(field, term, total)
        df = where(field => /#{term}/ ).count
        if df != 0
          Math.log(total/df)
        else
          0
        end
      end
      
      def search(query, options={}, criteria = {})
        return all(criteria) if query.blank? && (options[:allow_empty_search] || allow_empty_search)
        
        keywords = Util.normalize_keywords(query, stem_keywords)

        unique_keywords = keywords.uniq
        
        regexed_keywords = []
                        
        unique_keywords.each do |keyword|
          regexed_keywords.concat([/#{keyword}/])
        end
         
        search_match = options[:match]||self.match

        total = all.count

        results = []
        self.search_fields.each do |key, value|
          if key.class == Hash
            key.each do |sub_key, sub_value|
              field = "_#{sub_key}_#{sub_value}".to_sym
              search_a_field search_match, field, regexed_keywords, results, value, unique_keywords, total, criteria
            end
          else
            field = "_#{key}".to_sym
            search_a_field search_match, field, regexed_keywords, results, value, unique_keywords, total, criteria
          end
        end

        results.sort { |a,b| b.rank <=> a.rank }
        documents = []
        results.each do |result|
          documents << result.document
        end

        documents
      end
      
      # Goes through all documents in the class that includes Mongoid::Search
      # and indexes the keywords.
      def index_keywords!
        all.each { |d| d.index_keywords! }
      end
      
    end
    
    module InstanceMethods #:nodoc:
      # Indexes the document keywords
      def index_keywords!
        self.search_fields.each do |key, value|
          if key.class == Hash
            key.each do |sub_key, sub_value|
              set_search_field key
            end
          else
            set_search_field key
          end
        end
        save
        true
      end
    end
    
    private
    def get_keywords(key)
      Util.keywords(self, key, stem_keywords)
                .flatten.reject{|k| k.nil? || k.empty?}
    end
    
    def set_search_field(key)
      if key.class == Hash
        key.each do |sub_key, sub_value|
          keywords = get_keywords(key)
          instance_variable_set "@_#{sub_key}_#{sub_value}".to_sym, keywords
        end
      else
        keywords = get_keywords(key)
        instance_variable_set "@_#{key}".to_sym, keywords
      end
      
    end
    
    def set_keywords
      self.search_fields.each do |key, value|
        if key.class == Hash
          key.each do |sub_key, sub_value|
            set_search_field key
          end
        else
          set_search_field key
        end
      end
    end
    
  end
end