require "web-puppet/version"
require 'rack'
require 'puppet'
require 'json'
require 'parseconfig'

module  WebPuppet
  class App

    def initialize(filters=[])
      @filters = filters
    end

    def call env
      Puppet[:config] = "/etc/puppet/puppet.conf"
      Puppet.parse_config

      Puppet[:clientyamldir] = Puppet[:yamldir]
      Puppet::Node.indirection.terminus_class = :yaml

      nodes = Puppet::Node.indirection.search("*")

      data = {}
      nodes.each do |n|
        facts = Puppet::Node::Facts.indirection.find(n.name)
        tags = Puppet::Resource::Catalog.indirection.find(n.name).tags
        @filters.each do |filter|
          facts.values.delete(filter.strip)
        end

        data[n.name] = {
          :facts => facts.values,
          :tags => tags
        }
      end

      response = Rack::Response.new
      response.header['Content-Type'] = 'application/json'
      response.write JSON.pretty_generate(data)
      response.finish
    end

    def add_auth(conf)
      application = Rack::Auth::Basic.new(self) do |username, password|
        stored_username = conf.get_value('username')
        username_check = stored_username ? stored_username == username : true
        password_check = conf.get_value('password') == password
        username_check && password_check
      end
      application.realm = 'Web Puppet'
      application
    end

    def self.run!(options)

      conf = options[:config] ? ParseConfig.new(options[:config]) : false

      if conf && conf.get_value('filters')
        application = self.new(conf.get_value('filters').split(','))
      else
        application = self.new
      end

      daemonize = options[:daemonize]
      port = options[:port]

      if conf
        application = application.add_auth(conf) if conf.get_value('password')
        daemonize = conf.get_value('daemonize') ? conf.get_value('daemonize') == "true" : daemonize
        port = conf.get_value('port') ? conf.get_value('port') : port
      end

      Rack::Server.new(:app => application, :Port => port, :daemonize => daemonize).start

    end
  end
end
