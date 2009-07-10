require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../fixtures/foo_builder")

describe HashBuilder do

  context ".define" do

    before(:each) do
      HashBuilder.reset(:foo)
    end
    
    it "should yield a hash builder object" do
      HashBuilder.define(:foo) do |b|
        b.should be_an_instance_of(HashBuilder)
      end 

    end

    it "should set builder object in builders hash" do
      HashBuilder.define(:foo) do |b|
        # no op
      end 

      HashBuilder.builders[:foo].should be_an_instance_of(HashBuilder)
    end

    context "when a hash build key is not passed in" do
      
      it "should raise an error" do
        running { HashBuilder.define }.should raise_error(HashBuilderError, "You need to pass in a hash builder key (e.g., HashBuilder.define(:foo))")
      end

    end

    context "when a hash build key is already being used" do
      
      it "should raise an error" do
        pending
        HashBuilder.define(:foo) do |b|
          # no op
        end 

        running { HashBuilder.define(:foo) }.should raise_error(HashBuilderError, "The hash builder key ':foo' is already being used.")
      end

    end

  end

  context ".build" do

    before(:each) do
      HashBuilder.reset(:foo)
    end

    context "when a hash build key is not passed in" do
      
      it "should raise an error" do
        running { HashBuilder.build }.should raise_error(HashBuilderError)
      end

    end

    it "should return hash from builder instance" do
      # given
      HashBuilder.define(:foo) do |b|

        b.build_hash do
          b[:bar] = "baz"
        end 

      end 

      # expect
      HashBuilder.build(:foo).should == {:bar => "baz"}
    end

    it "should take additional arguments to the hash builder key" do
      # given
      HashBuilder.define(:foo) do |b|
        b.build_hash do |event|
          b[:bar] = event.bar
        end 
      end 

      # expect
      mock_event = mock_model(Referral, :bar => "baz")
      HashBuilder.build(:foo, mock_event).should == {:bar => "baz"}
    end

  end

  context ".build_namespace" do
    
    it "should build hash for namespace only" do
      # given
      HashBuilder.reset(:contact_info)
      HashBuilder.define(:contact_info) do |b|
        b.build_hash :name do
          b[:f_name] = "Dave"
          b[:l_name] = "Brady"
        end 

        b.build_hash(:address) do
          b[:street] = "123 Main St."
        end 
      end 

     # expect
      HashBuilder.build_namespace(:contact_info, :name).should == {:f_name => "Dave", :l_name => "Brady"}
    end

  end

  context ".reset" do
    
    it "should set specified builder to nil" do
      # given
      HashBuilder.reset(:bar)
      HashBuilder.define(:bar) do |bldr|
        bldr.build_hash do
          # no op
        end 
      end

      # when
      HashBuilder.reset(:bar)

      # expect
      HashBuilder.builders[:bar].builder_hash.should == {}
    end

    it "should take multiple keys" do
      # given
      HashBuilder.reset(:foo, :bar)
      HashBuilder.define(:foo) do |bldr|
        bldr.build_hash do
          # no op
        end 
      end

      HashBuilder.define(:bar) do |bldr|
        bldr.build_hash do
          # no op
        end 
      end

      # when
      HashBuilder.reset(:foo, :bar)

      # expect
      [:foo, :bar].each { |key| HashBuilder.builders[key].builder_hash.should == {} }
    end

  end

  context "#hash" do

    it "should return a hash" do
      # given
      HashBuilder.reset(:bar)
      HashBuilder.define(:bar) do |bldr|
        bldr.build_hash do
          # no op
        end 
      end

      # expect
      Hash.should_receive(:new).and_return({})

      # when
      HashBuilder.build(:bar)
    end
  end


  context "#using" do

    it "should use only specified namespace keys for hash building" do
      # given
      HashBuilder.reset(:contact_info)
      HashBuilder.define(:contact_info) do |bldr|
        bldr.build_hash(:name) do
          bldr[:title] = "Dr."
          bldr[:f_name] = "Hawkeye"
          bldr[:l_name] = "Pierce"
        end 

        bldr.build_hash(:address) do
          bldr[:street] = "123 Main St."
          bldr[:city] = "Crabapple Cove"
          bldr[:state] = "ME"
          bldr[:zip] = "04656"
        end 
      end

      # expect
      hash = HashBuilder.build(:contact_info) do |b|
        b.using :name
      end 

      hash.should == { :title => "Dr.", :f_name => "Hawkeye", :l_name => "Pierce"}
    end

    context "if no inclusions are specified" do
      
      it "should include all namespaced keys for hash building" do
        # given
        HashBuilder.reset(:contact_info)
        HashBuilder.define(:contact_info) do |bldr|
          bldr.build_hash(:name) do
            bldr[:title] = "Dr."
            bldr[:f_name] = "Hawkeye"
            bldr[:l_name] = "Pierce"
          end 

          bldr.build_hash(:address) do
            bldr[:street] = "123 Main St."
            bldr[:city] = "Crabapple Cove"
            bldr[:state] = "ME"
            bldr[:zip] = "04656"
          end 
        end

        # expect
        HashBuilder.build(:contact_info).should == { :title => "Dr.", :f_name => "Hawkeye", :l_name => "Pierce",  :street => "123 Main St.", :city => "Crabapple Cove", :state => "ME", :zip => "04656"}
      end

    end
    
  end

  context "#[]=" do

    it "should set hash" do
      # given
      HashBuilder.reset(:bar)
      HashBuilder.define(:bar) do |bldr|
        bldr.build_hash do
          bldr[:baz] = "boo"
        end 
      end

      # expect
      HashBuilder.build(:bar).should == { :baz => "boo" }
    end
  end

  context "#build_hash" do
    
    context "namespacing hash components within builder definition" do

      it "should take take multiple keys" do
        # given
        HashBuilder.reset(:contact_info)
        HashBuilder.define(:contact_info) do |bldr|
          bldr.build_hash(:name) do
            bldr[:title] = "Dr."
            bldr[:f_name] = "Hawkeye"
            bldr[:l_name] = "Pierce"
          end 

          bldr.build_hash(:address) do
            bldr[:street] = "123 Main St."
            bldr[:city] = "Crabapple Cove"
            bldr[:state] = "ME"
            bldr[:zip] = "04656"
          end 
        end

        # expect
        HashBuilder.build(:contact_info).should == { :title => "Dr.", :f_name => "Hawkeye", :l_name => "Pierce",  :street => "123 Main St.", :city => "Crabapple Cove", :state => "ME", :zip => "04656"}
      end
      
    end
  end

  context "merging hashes" do 

    before(:each) do 
      # given
      HashBuilder.reset(:foo, :bar)
      HashBuilder.define(:foo) do |bldr|
        bldr.build_hash do
          bldr.hash[:foo_key] = "hello"
        end 
      end

      HashBuilder.define(:bar) do |bldr|
        bldr.build_hash do
          bldr[:bar_key] = "there"
        end 
      end
    end

    context "Hash#with" do
      
      it "should merge initial hash with hash specified by merge" do
        HashBuilder.build(:foo).with(:bar).should == { :foo_key => "hello", :bar_key => "there" }
      end 
    end

  end 

  context "functional test" do

    it "should actually work" do
      # this calls the builder "foo_builder.rb" in the "spec/fixtures" directory
      HashBuilder.build(:foobar).should == {:first_name => "Dave", :last_name => "Brady"}
    end
    
  end
end 
