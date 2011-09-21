# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MongoMapper::Search do
  before(:each) do
    Product.stem_keywords = false
    @product = Product.create :brand => "Apple",
                              :name => "iPhone",
                              :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Mobile"),
                              :subproducts => [Subproduct.new(:brand => "Apple", :name => "Craddle")]
  end

  context "utf-8 characters" do
    before(:each) {
      Product.stem_keywords = false
      @product = Product.create :brand => "Эльбрус",
                                :name => "Процессор",
                                :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                                :category => Category.new(:name => "процессоры"),
                                :subproducts => []
    }

    it "should leave utf8 characters" do
      @product._brand.should == ["Эльбрус"]
      @product._name.should == ["Процессор"]
      @product._tags_name.should == ["amazing", "awesome", "ole"]
      @product._category_name.should == ["процессоры"]
      @product._subproducts_brand.should == []
    end
  end
  
  it "should create search fields right" do
    @product._brand.should == ["apple"]
    @product._name.should == ["iphone"]
    @product._tags_name.should == ["amazing", "awesome", "ole"]
    @product._category_name.should == ["mobile"]
    @product._subproducts_brand.should == ["apple"]
  end
  
  it "should return result for a valid search" do
    Product.search("iphone").size.should == 1
    Product.search("ipad").size.should == 0
    Product.search("apple").size.should == 1
    Product.search("").size.should == 0
    Product.search("", {:allow_empty_search => true}).size.should == 1
  end

  it "should find products by category name" do
    Product.search("mobile").size.should == 1
    Product.search("nokia").size.should == 0
  end

  context "when references are nil" do
    context "when instance is being created" do
      it "should not complain about method missing" do
        lambda { Product.create! }.should_not raise_error
      end
    end

    subject { Product.create :brand => "Apple", :name => "iPhone" }

    its(:_brand) { should == ["apple"] }
    its(:_name) { should == ["iphone"] }
  end

  it "should set the search field for array fields also" do
    @product.attrs = ['lightweight', 'plastic', :red]
    @product.save!
    @product._attrs.should include 'lightweight', 'plastic', 'red'
  end

  it "should inherit search fields and build upon" do
    variant = Variant.create :brand => "Apple",
                              :name => "iPhone",
                              :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Mobile"),
                              :subproducts => [Subproduct.new(:brand => "Apple", :name => "Craddle")],
                              :color => :white
    variant._color.should include 'white'
    variant._name.should include 'iphone'
    Variant.search("Apple white").first.should == variant
  end

  it "should set the search field with stemmed words if stem is enabled" do
    Product.stem_keywords = true
    @product.save!
    @product._brand.should == ["appl"]
    @product._name.should == ["iphon"]
    @product._tags_name.should == ["amaz","awesom", "ol"]
    @product._category_name.should == ["mobil"]
    @product._subproducts_brand.should == ["appl"]
  end

   it "should incorporate numbers as keywords" do
        @product = Product.create :brand => "Ford",
                              :name => "T 1908",
                              :tags => ["Amazing", "First", "Car"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Vehicle")

      @product.save!
      @product._name.should == ["1908"]
   end


  it "should return results in search" do
    Product.search("apple").size.should == 1
  end

  it "should return results in search for dynamic attribute" do
    @product[:outlet] = "online shop"
    @product.save!
    Product.search("online").size.should == 1
  end

  it "should return results in search even searching a accented word" do
    Product.search("Ole").size.should == 1
    Product.search("Olé").size.should == 1
  end

  it "should return results in search even if the case doesn't match" do
    Product.search("oLe").size.should == 1
  end

  it "should return results in search with a partial word" do
    Product.search("iph").size.should == 1
  end

  it "should return results for any matching word with default search" do
    Product.search("apple motorola").size.should == 1
  end

  it "should not return results when all words do not match, if using :match => :all" do
    Product.match = :all
    Product.search("apple motorola").size.should == 0
  end

  it "should return results for any matching word, using :match => :all, passing :match => :any to .search" do
    Product.match = :all
    Product.search("apple motorola", :match => :any).size.should == 1
  end

  it "should not return results when all words do not match, passing :match => :all to .search" do
    Product.search("apple motorola", :match => :all).size.should == 0
  end

  it "should return no results when a blank search is made" do
    Product.search("").size.should == 0
  end

  it "should return results when a blank search is made when :allow_empty_search is true" do
    Product.allow_empty_search = true
    Product.search("").size.should == 1
  end

  it "should search for embedded documents" do
    Product.search("craddle").size.should == 0
  end

  it 'should work in a chainable fashion' do
    @product.category.products.where(:brand => 'Apple').search("", {:allow_empty_search => true}).size.should == 1
    @product.category.products.where(:brand => 'Apple').search('apple').size.should == 1
    @product.category.products.where(:brand => 'Apple').search('troll').size.should == 0
  end

  it 'should return the classes that include the search module' do
    MongoMapper::Search.classes.should == [Product]
  end

  it 'should have a method to index keywords' do
    @product.index_keywords!.should == true
  end

  it 'should have a class method to index all documents keywords' do
    Product.index_keywords!.should_not include(false)
  end

end