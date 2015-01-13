##
## Copyright (C) 2015 eNovance SAS <licensing@enovance.com>
##
## Author: Yanis Guenane <yanis.guenane@enovance.com>
##
## Licensed under the Apache License, Version 2.0 (the "License"); you may
## not use this file except in compliance with the License. You may obtain
## a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
## WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
## License for the specific language governing permissions and limitations
## under the License.

Puppet::Type.type(:limit).provide('limit') do
  desc = "Manage a limit entry in /etc/security/limits.conf"

  mk_resource_methods

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def flush
    set_limit
    @property_hash = self.class.get_security_limit(resource[:name])
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end 
    end 
  end 

  def self.parse_limit_line line
    if !line.chomp.start_with? '#' 
      limit = line.split(" ")
    end 
    if limit and limit.size == 4
      limit
    else
      false
    end 
  end

  def self.parse_security_limits_conf
    limits = []
    File.open("/etc/security/limits.conf", "r") do |f| 
      f.each_line do |line|
        if limit = parse_limit_line(line)
          limits.push limit
        end 
      end 
    end 
    limits
  end

  def self.instances
    instances = get_security_limits.collect do |limit|
      new (limit)
    end
  end

  def self.get_security_limit domain
    properties = {}
    limits = parse_security_limits_conf
    limits.each do |limit|
      if limit[0] == domain
        properties = {
          :name     => limit[0],
          :ensure   => :present,
          :domain   => limit[0],
          :type     => limit[1],
          :item     => limit[2],
          :value    => limit[3],
          :provider => :limit
        }
      end
    end
    properties
  end

  def self.get_security_limits
    limits = parse_security_limits_conf
    properties = limits.collect do |limit|
      {
        :name     => limit[0],
        :ensure   => :present,
        :domain   => limit[0],
        :type     => limit[1],
        :item     => limit[2],
        :value    => limit[3],
        :provider => :limit
      }
    end
    properties
  end

  def set_limit
    if resource[:ensure] == :absent
       Puppet.debug "Removing limit for #{self.name}"
       File.open("/etc/security/limits.conf", "w+") do |f| 
         f.each_line do |line|
           limit = parse_limit_line line
           new_content += line if !(@property_hash[:domain] == resource[:domain] and @property_hash[:type] == resource[:type] and @property_hash[:item] == @property_value[:item])
         end 
         f.puts new_content
       end
    elsif resource[:ensure] == :present and @property_hash[:ensure] != :present
       Puppet.debug "Adding limit for #{self.name}"
       File.open('/etc/security/limits.conf', 'a') do |file|
         file.puts "#{resource[:domain]} #{resource[:type]} #{resource[:item]} #{resource[:value]}"
       end
    elsif (@property_hash[:domain] == resource[:domain] and @property_hash[:type] == resource[:type] and @property_hash[:item] == resource[:item]) and @property_hash[:value] != resource[:value]
       Puppet.debug "Updating limit for #{self.name}"
       File.open("/etc/security/limits.conf", "w+") do |f| 
         f.each_line do |line|
           limit = parse_limit_line line
           new_content += line if !(@property_hash[:domain] == resource[:domain] and @property_hash[:type] == resource[:type] and @property_hash[:item] == @property_value[:item])
         end 
         new_content +=  "#{resource[:domain]} #{resource[:type]} #{resource[:item]} #{resource[:value]}"
         f.puts new_content 
       end
    end
  end


end
