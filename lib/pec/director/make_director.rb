module Pec
  class Director
    class MakeDirector
      def execute!(host)
        Pec::Resource.set_tenant(host.tenant)
        make(host)
      end

      def do_it?(host)
        true
      end

      def make(host)
        if Pec::Compute::Server.exists?(host.name)
          puts "skip create server! name:#{host.name} is exists!"
          return true
        end

        ports      = Pec::Director::Helper.ports_assign(host)
        flavor_ref = Pec::Compute::Flavor.get_ref(host.flavor)
        image_ref  = Pec::Compute::Image.get_ref(host.image)
        options    = { "user_data" => Pec::Configure::UserData.make(host, ports) }

        options.merge!(Pec::Director::Helper.get_nics(ports))

        Pec::Compute::Server.create(host.name, image_ref, flavor_ref, options)
      end

      def err_message(e, host)
          puts e
          puts "can't create server:#{host.name}" if host
      end
    end
  end
end
