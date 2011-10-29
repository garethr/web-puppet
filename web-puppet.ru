require 'rack'
require 'puppet'
require 'json'

class App
  def call env

    Puppet[:config] = "/etc/puppet/puppet.conf"
    Puppet.parse_config

    Puppet[:clientyamldir] = "$yamldir"
    Puppet::Node.indirection.terminus_class = :yaml

    nodes = Puppet::Node.indirection.search("*")

    data = {}
    nodes.each do |n|
      facts = Puppet::Node::Facts.indirection.find(n.name)
      tags = Puppet::Resource::Catalog.indirection.find(n.name).tags
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
end

run App.new
