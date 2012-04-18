require 'zlib'

module Hashafras
  class Ring
    DEFAULTS = {:replicas => 20}

    attr_accessor :options

    def initialize(options = {})
      @options = DEFAULTS.merge(options)
    end

    def add_member(name, host)
      options[:replicas].times do |t|
        key = hash("#{name}_#{t}")
        members[key] = host
        member_positions << key
        member_positions.sort!
      end
    end

    def remove_member(name)
      options[:replicas].times do |t|
        key = hash("#{name}_#{t}")
        members.delete(key)
        member_positions.delete(key)
        member_positions.compact!
      end
    end
    
    def members
      @members ||= {}
    end

    def member_positions
      @member_positions ||= []
    end

    def hash(key)
      Zlib.crc32("#{key}")
    end

    def find_host_for_key(key)
      return nil if members.empty?
      return members.first if members.size == 1

      hash_value = hash(key)
      return members[hash_value] if members[hash_value]
      
      return find_nearest_member(hash_value)
    end

    def find_nearest_member(key)
      member = nil
      member_positions.each do |m_position|
        if m_position > key
          member = members[m_position]
          break
        end
      end
      member ||= members.first.last
    end
  end
end
