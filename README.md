MongoMapper Search
============

MongoMapper Search is a simple full text search implementation for MongoMapper ODM based on mongoid_search (https://github.com/mauriciozaffari/mongoid_search).

Installation
--------

In your Gemfile:

    gem 'mongomapper_search'

Then:

    bundle install

Examples
--------

    class Product
      include MongoMapper::Document
      include MongoMapper::Search
      key :brand, String
      key :name, String

      many :tags
      belongs_to :category

      search_in :brand, :name, :tags => :name, :category => :name
    end

    class Tag
      include MongoMapper::Document
      key :name, Stirng

      belongs_to :product
    end

    class Category
      include MongoMapper::Document
      key :name, String

      many :products
    end

Now when you save a product, you get a _keywords field automatically:

    p = Product.new :brand => "Apple", :name => "iPhone"
    p.tags << Tag.new(:name => "Amazing")
    p.tags << Tag.new(:name => "Awesome")
    p.tags << Tag.new(:name => "Superb")
    p.save
    => true
    p._keywords

Now you can run search, which will look in the _keywords field and return all matching results:

    Product.search("apple iphone").size
    => 1

Note that the search is case insensitive, and accept partial searching too:

    Product.search("ipho").size
    => 1
    
You can use search in a chainable way:

    Product.where(:brand => "Apple").search('iphone').sort(:price.asc)


Options
-------

match:
  _:any_ - match any occurrence
  _:all_ - match all ocurrences
  Default is _:any_.

    search_in :brand, :name, { :tags => :name }, { :match => :any }

    Product.search("apple motorola").size
    => 1

    search_in :brand, :name, { :tags => :name }, { :match => :all }

    Product.search("apple motorola").size
    => 0

allow_empty_search:
  _true_ - match any occurrence
  _false_ - match all ocurrences
  Default is _false_.

    search_in :brand, :name, { :tags => :name }, { :allow_empty_search => true }

    Product.search("").size
    => 1
    
RoadMap
----

- Create a ignore list so the search can ignore some words
