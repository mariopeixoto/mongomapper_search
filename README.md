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

      search_in :brand, :name, {:tags => :name} => 1, {:category => :name} => 2
    end

    class Tag
      include MongoMapper::Document
      key :name, String

      belongs_to :product
    end

    class Category
      include MongoMapper::Document
      key :name, String

      many :products
    end

Syntax:

    search_in :brand, :name => 3, {:tags => :name} => 1

The search will be done using fields named as the symbols passed.
You can pass a boost parameter to smooth your search like in:

	:name => 3 #It means that keywords found on name is 3 times more important than keywords found on :brand

The default boost is 1.
For while, complex attributes like {:tags => :name} must be declared with a boost value.

Now you can run search, which will look in the search field and return all matching results:

    Product.search("apple iphone").size
    => 1

Note that the search is case insensitive, and accept partial searching too:

    Product.search("ipho").size
    => 1
    
You can use search in a chainable way:

    Product.where(:brand => "Apple").search('iphone')


Options
-------

match:
  _:any_ - match any occurrence
  _:all_ - match all ocurrences
  Default is _:any_.

    search_in :brand, :name, { :tags => :name } => 1, { :match => :any }

    Product.search("apple motorola").size
    => 1

    search_in :brand, :name, { :tags => :name } => 1, { :match => :all }

    Product.search("apple motorola").size
    => 0

allow_empty_search:
  _true_ - match any occurrence
  _false_ - match all ocurrences
  Default is _false_.

    search_in :brand, :name, { :tags => :name } => 1, { :allow_empty_search => true }

    Product.search("").size
    => 1
    
RoadMap
----

- Create a ignore list so the search can ignore some words
