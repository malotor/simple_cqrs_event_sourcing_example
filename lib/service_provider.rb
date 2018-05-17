# Based on https://github.com/sirsean/dependo
module ServiceProvider
    class Container
        @@services = {}

        def self.[]=(key, value)
            @@services[key] = value
        end

        def self.[](key)
            @@services[key]
        end

        def self.has_key?(key)
            @@services.has_key?(key)
        end

        def self.clear
            @@services.clear
        end
    end

    module ContainerAware

        def method_missing(key)
            if ServiceProvider::Container.has_key?(key)
                ServiceProvider::Container[key]
            else
                raise ServiceNotExistsError, "undefined service '#{key.to_s}' for #{self.to_s}"
            end
        end
        def respond_to?(key, include_private=false)
            if ServiceProvider::Container.has_key?(key)
                true
            else
                super(key, include_private)
            end
        end

    end

    class ServiceNotExistsError < StandardError; end

end
