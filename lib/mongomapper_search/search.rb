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
        self.search_fields      = (self.search_fields || []).concat args
        
        key :_keywords, Array
        ensure_index :_keywords, :background => true
        
        before_save :set_keywords
      end
      
      def search(query, options={})
        return all if query.blank? && allow_empty_search
        
        keywords = Util.normalize_keywords(query, stem_keywords)
        
        regexed_keywords = []
                        
        keywords.each do |keyword|
          regexed_keywords.concat([/#{keyword}/])
        end
         
        search_match = options[:match]||self.match
        
        if search_match == :all 
          where(:_keywords => { "$all" => regexed_keywords })
        elsif search_match == :any
          where(:_keywords => regexed_keywords )
        end
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
        update_attribute(:_keywords, set_keywords)
      end
    end
    
    private
    def set_keywords
      self._keywords = self.search_fields.map do |field|
        Util.keywords(self, field, stem_keywords)
      end.flatten.reject{|k| k.nil? || k.empty?}.uniq.sort
    end
    
  end
end