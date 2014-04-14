#!/usr/bin/env ruby

require_relative "alfred"

class ProxySwitcher

  class Config

    attr :services

    CONFIG_FILE = File.expand_path '~/.proxyswitcher.rc'

    def initialize
      if test ?e, CONFIG_FILE
        @services = IO.readlines(CONFIG_FILE).map(&:chomp)
      end
    end
  end

  LIST_SERVICES_CMD = "networksetup -listallnetworkservices | sed -n '2,$p'"

  def initialize
    @services = Config.new.services || `#{LIST_SERVICES_CMD}`.lines.map(&:chomp)
  end

  def search(query)
    items = ItemList.new
    @services.grep(/#{query}/i).each do |name| 
      items.concat NetworkService.new(name).proxy_options
    end
    items
  end

  class NetworkService

    attr :proxy_options, :name

    def initialize(name='Wi-Fi')
      @name = name
      @proxy_options = []
      @proxy_options << ProxyAutoDiscovery.new(self)
      @proxy_options << AutoProxy.new(self)
      ['Web Proxy', 'Secure Web Proxy', 'FTP Proxy',
        'Socks Firewall Proxy', 'Streaming Proxy', 'Gopher Proxy'].each do |proxy_name|
          @proxy_options << ProxyOption.new(self, proxy_name)
      end      
    end
  end

  class ProxyOption < Item

    attr :humane_name

    GET_INFO_CMD = "networksetup -get%s '%s'"
    SET_STATE_CMD = "networksetup -set%sstate '%s' %s"

    def initialize(service, name)
      super()
      @service = service
      @human_name = name
      @name = name.downcase.gsub(/ /, "")
      self.fetch_info
      @attributes[:uid] = @name    
      @subtitle = @service.name
      @icon[:text] = "%s.png" % @status
    end

    def fetch_info
      IO.popen GET_INFO_CMD % [@name, @service.name] do |io|
        io.each do |line|
          line.chomp!
          if line =~ /^Enabled: (Yes|No)/
            if $1 == 'yes'
              @status = 'On'
              @reversed_status = 'off'
            else
              @status = 'Off'
              @reversed_status = 'on'
            end
          elsif line.start_with? 'Server:'
            @server = line
          elsif line.start_with? 'Port:'            
            @port = line
          end
        end
      end
      @attributes[:arg] = SET_STATE_CMD % [@name, @service.name, @reversed_status]
      @title = "%s: %s, %s, %s" % [@human_name, @status, @server, @port]  
    end

  end

  class ProxyAutoDiscovery < ProxyOption

    SET_STATE_CMD = "networksetup -setproxyautodiscovery '%s' %s"

    def initialize(service)
      super(service, 'Proxy Auto Discovery')
    end

    def fetch_info
      IO.popen ProxyOption::GET_INFO_CMD % [@name, @service.name] do |io|
        io.each do |line|
          line.chomp!
          if line =~ /: (On|Off)/
            if $1 == 'On'
              @status = 'On'
              @reversed_status = 'off'
            else
              @status = 'Off'
              @reversed_status = 'on'
            end
          end
        end
      end
      @attributes[:arg] = SET_STATE_CMD % [@service.name, @reversed_status]
      @title = "%s: %s" % [@human_name, @status]  
    end
  end

  class AutoProxy < ProxyOption

    GET_INFO_CMD = "networksetup -getautoproxyurl '%s'"

    def initialize(service)
      super(service, 'Auto Proxy')
    end

    def fetch_info
      IO.popen GET_INFO_CMD % @service.name do |io|
        io.each do |line|
          line.chomp!
          if line =~ /^Enabled: (Yes|No)/
            if $1 == 'Yes'
              @status = 'On'
              @reversed_status = 'off'
            else
              @status = 'Off'
              @reversed_status = 'on'
            end
          elsif line.start_with? 'URL:'
            @url = line
          end
        end
      end
      @attributes[:arg] = ProxyOption::SET_STATE_CMD % [@name, @service.name, @reversed_status]
      @title = "%s: %s, %s" % [@human_name, @status, @url]
    end
  end
end

if $0 == __FILE__
  puts ProxySwitcher.new.search(ARGV[0] && ARGV[0].strip).to_xml
end
