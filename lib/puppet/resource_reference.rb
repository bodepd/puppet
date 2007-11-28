#
#  Created by Luke Kanies on 2007-11-28.
#  Copyright (c) 2007. All rights reserved.

require 'puppet'

# A simple class to canonize how we refer to and retrieve
# resources.
class Puppet::ResourceReference
    attr_reader :type
    attr_accessor :title, :configuration

    def initialize(type, title)
        @title = title
        self.type = type
        
        @builtin_type = nil
    end

    # Find our resource.
    def resolve
        if configuration
            return configuration.resource(to_s)
        end
        # If it's builtin, then just ask for it directly from the type.
        if t = builtin_type
            t[@title]
        else # Else, look for a component with the full reference as the name.
            Puppet::Type::Component[to_s]
        end
    end

    # Canonize the type so we know it's always consistent.
    def type=(value)
        @type = value.to_s.split("::").collect { |s| s.capitalize }.join("::")
    end

    # Convert to the standard way of referring to resources.
    def to_s
        "%s[%s]" % [@type, @title]
    end

    private

    def builtin_type?
        builtin_type ? true : false
    end

    def builtin_type
        if @builtin_type.nil?
            if @type =~ /::/
                @builtin_type = false
            elsif klass = Puppet::Type.type(@type.to_s.downcase)
                @builtin_type = klass
            else
                @builtin_type = false
            end
        end
        @builtin_type
    end
end
