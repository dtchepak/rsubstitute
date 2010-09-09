require_relative '../lib/rsubstitute.rb'
require 'spec'
require 'shoulda'

describe "when method is called on substitute" do
    before do
        @sub = Substitute.new
        @sub.some_method(1)
    end
        
    it "can assert method was received" do
        @sub.received.some_method(1)
    end

    it "throws when a different method was received" do
        lambda {
            @sub.received.different_method(123, 345)
        }.should raise_exception
    end

    it "throws when the same method with different args was received" do
        lambda {
            @sub.received.some_method("a")
        }.should raise_exception
    end
end

describe "when setting a return value for a method" do
    before do
        @value_to_return = Object.new
        @sub = Substitute.new
        @sub.some_method(1).returns(@value_to_return)
    end

    it "returns that value when called" do
        result = @sub.some_method(1)
        result.should == @value_to_return
    end

    it "returns something else when called with different args" do
        result = @sub.some_method(2)
        result.should != @value_to_return
    end

    it "returns a new value when a new value is set for the method" do
        @sub.some_method(1).returns(5)
        result = @sub.some_method(1)
        result.should_not equal @value_to_return
        result.should equal 5
    end

end
