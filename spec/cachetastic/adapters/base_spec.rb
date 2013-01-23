require 'spec_helper'

describe Cachetastic::Adapters do

  describe 'build' do
    
    it 'should build and a return an Adapter for a Class' do
      adp = Cachetastic::Adapters.build(CarCache)
      adp.should_not be_nil
      adp.should be_kind_of(Cachetastic::Adapters::LocalMemory)
      adp.klass.should be(CarCache)
      configatron.temp do
        configatron.cachetastic.car_cache.adapter = Cachetastic::Adapters::Memcached
        adp = Cachetastic::Adapters.build(CarCache)
        adp.should_not be_nil
        adp.should be_kind_of(Cachetastic::Adapters::Memcached)
        adp.klass.should be(CarCache)
      end
    end
    
  end
  
  describe 'Base' do
    
    describe 'transform_key' do
      
      it 'should pass the key right through' do
        adapter = Cachetastic::Adapters::Base.new(CarCache)
        adapter.transform_key('$*...123()%~q').should == '$*...123()%~q'
      end
      
    end
    
    describe 'marshal' do
      
      it 'should return the object untouched when set to :none' do
        configatron.temp do
          configatron.cachetastic.defaults.marshal_method = :none
          adapter = Cachetastic::Adapters::Base.new(CarCache)
          adapter.marshal('foo').should == 'foo'
        end
      end
      
      it 'should return the object as yaml when set to :yaml' do
        configatron.temp do
          configatron.cachetastic.defaults.marshal_method = :yaml
          adapter = Cachetastic::Adapters::Base.new(CarCache)
          adapter.marshal('foo').should == YAML.dump('foo')
        end
      end
      
      it 'should return the object as a ruby serialized object when set to :ruby' do
        configatron.temp do
          configatron.cachetastic.defaults.marshal_method = :ruby
          adapter = Cachetastic::Adapters::Base.new(CarCache)
          adapter.marshal('foo').should == Marshal.dump('foo')
        end
      end
      
    end
    
    describe 'unmarshal' do
      
      it 'should return the object untouched when set to :none' do
        configatron.temp do
          configatron.cachetastic.defaults.marshal_method = :none
          adapter = Cachetastic::Adapters::Base.new(CarCache)
          adapter.unmarshal('foo').should == 'foo'
        end
      end
      
      it 'should return the yaml as the object when set to :yaml' do
        configatron.temp do
          configatron.cachetastic.defaults.marshal_method = :yaml
          adapter = Cachetastic::Adapters::Base.new(CarCache)
          adapter.unmarshal(YAML.dump('foo')).should == 'foo'
        end
      end
      
      it 'should return the ruby serialized object as the original object when set to :ruby' do
        configatron.temp do
          configatron.cachetastic.defaults.marshal_method = :ruby
          adapter = Cachetastic::Adapters::Base.new(CarCache)
          adapter.unmarshal(Marshal.dump('foo')).should == 'foo'
        end
      end
      
    end
    
  end
  
  ['LocalMemory', 'File', 'Memcached', 'Redis', 'Dalli', 'Mongoid'].each do |adapter|
    
    describe "#{adapter} (Common)" do

      before(:each) do
        configatron.cachetastic.defaults.adapter = "Cachetastic::Adapters::#{adapter}".constantize
        CarCache.clear_adapter!
        CarCache.expire_all
        CarCache.set(:vw, 'Rabbit')
      end

      after(:each) do
        CarCache.expire_all
        configatron.cachetastic.defaults.adapter = Cachetastic::Adapters::LocalMemory
      end

      describe 'get' do

        it 'should get an object from the cache' do
          CarCache.get(:vw).should == 'Rabbit'
        end

        it 'should return nil if the object is not in the cache' do
          CarCache.get(:audi).should be_nil
        end

        it 'should run a block if the object is nil' do
          lambda {
            CarCache.get(:audi) do
              raise Cachetastic::BlockError.new
            end
          }.should raise_error(Cachetastic::BlockError)
        end

        it 'should run a block if the object is empty' do
          lambda {
            CarCache.set(:audi, [])
            CarCache.get(:audi) do
              raise Cachetastic::BlockError.new
            end
          }.should raise_error(Cachetastic::BlockError)
        end

        it 'should run a block if the object is blank' do
          lambda {
            CarCache.set(:audi, '')
            CarCache.get(:audi) do
              raise Cachetastic::BlockError.new
            end
          }.should raise_error(Cachetastic::BlockError)
        end

      end

      describe 'set' do

        it 'should set an object into the cache' do
          CarCache.get(:bmw).should be_nil
          CarCache.set(:bmw, 'Beamer!')
          CarCache.get(:bmw).should_not be_nil
        end
        
        unless ["Memcached", "Redis", "Dalli"].include?(adapter)
          it 'should set an object into the cache with an expiry' do
            CarCache.get(:bmw).should be_nil
            CarCache.set(:bmw, 'Beamer!', 1)
            CarCache.get(:bmw).should_not be_nil
            Timecop.travel(1.hour.from_now)
            CarCache.get(:bmw).should be_nil
          end
        end

      end

      describe 'delete' do

        it 'should delete an object from the cache' do
          CarCache.get(:bmw).should be_nil
          CarCache.set(:bmw, 'Beamer!')
          CarCache.get(:bmw).should_not be_nil
          CarCache.delete(:bmw)
          CarCache.get(:bmw).should be_nil
        end

      end

      describe 'expire_all' do

        it 'should expire all objects in the cache' do
          CarCache.get(:vw).should == 'Rabbit'
          CarCache.expire_all
          CarCache.get(:vw).should be_nil
        end

      end
      
      describe 'retry' do
        
        it 'should retry if there is an exception' do
          CarCache.instance.should_receive(:clear_adapter!).twice
          lambda {
            CarCache.get(:audi) do
              raise Cachetastic::BlockError.new
            end
          }.should raise_error(Cachetastic::BlockError)
        end
        
      end

    end
    
    
  end
  
end
