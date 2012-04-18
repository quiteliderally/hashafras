require 'bundler'
Bundler.require
require 'benchmark'
describe Hashafras::Ring do
  context "has only one member" do
    let(:ring){
      Hashafras::Ring.new.tap do |o|
        o.add_member("s1", "s1:80")
      end
    }
    it "should always return the same member" do
      ring.find_host_for_key("foo").should == "s1:80"
      ring.find_host_for_key("bar").should == "s1:80"
      ring.find_host_for_key("baz").should == "s1:80"
    end
  end

  context "has many members" do
    def members
      @members ||= 10.times.inject([]) {|memo,obj| memo.push(:name => "s#{obj}", :host => "s#{obj}:80") }
    end

    def iterations
      1000
    end
    let(:ring){
      Hashafras::Ring.new.tap do |o|
        members.each do |s|
          o.add_member(s[:name], s[:host])
        end
      end
    }
    it "should evenly distribute keys" do
      results = {}
      iterations.times do |key|
        host = ring.find_host_for_key(key)
        results[host] ||= 0
        results[host] += 1
      end
      members.count.should == results.keys.count
      max = results.max.last.to_f
      min = results.min.last.to_f

      (min / max).should > 0.8
    end

    context "when topology changes" do
      def results 
        results = {}
        iterations.times do |key|
          host = ring.find_host_for_key(key)
          results[key] = host
        end
        results
      end

      def result_diff(result1, result2)
        result1.reject {|k,v| result2[k] == v}
      end

      it "should be minimally disruptive to the keyspace when nodes are added" do
        original_results = results
        ring.add_member("new_host", "new_host:80")
        updated_results = results

        diff = result_diff(original_results, updated_results)
        diff.count.should <= (iterations / (members.count))
      end

      it "should be minimally disruptive to the keyspace when nodes are removed" do
        original_results = results
        ring.remove_member("new_host")
        updated_results = results

        diff = result_diff(original_results, updated_results)
        diff.count.should <= (iterations / (members.count))
      end
    end
  end
end
