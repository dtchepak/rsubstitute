﻿class Call
    def initialize(method, *args, &block)
        @method, @args, @block = method, args, block
    end

    def matches(method, *args, &block)
        @method == method and args_match(args)
    end

    private

    def args_match(args)
        return true if @args == args
        return false if @args.nil? or args.nil?
        return @args <=> args
    end
end

class Object
    def returns(value)
        sub = self.instance_variable_get(:@substitute)
        raise "Not from a substitute" if sub.nil?
        sub.returns(value)
    end
end

class Substitute

    def initialize()
        @calls = []
        @results = []
        @assert_next = false
    end

    def received
        @assert_next = true
        self
    end

    def method_missing(method, *args, &block)
        assert_was_received = @assert_next
        @assert_next = false
        if assert_was_received and not @calls.any? {|x| x.matches(method, args, block)}
            raise "Call #{method} not received with specified args"
        end

        @calls << Call.new(method, args, block)
        matching_result_pair = @results.reverse.find do |x| 
                            x[0].matches(method, args, block)
                        end
        if (matching_result_pair.nil?)
            value_to_return = Object.new
        else
            value_to_return = matching_result_pair[1]
        end

        value_to_return.instance_variable_set(:@substitute, self)
        return value_to_return
    end

    def returns(value)
        @results << [@calls.pop(), value]
    end
end

