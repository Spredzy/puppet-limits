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

Puppet::Type.newtype(:limit) do
  @doc = "Manage a limit entry in /etc/security/limits.conf"

  ensurable do
    defaultto :present

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name) do
    desc "The domain name of the entry"
  end

  newproperty(:domain) do
    desc "The domain name of the entry"
  end

  newproperty(:type) do
    desc "The type of the entry"
    newvalues(:hard, :soft, '-')
  end

  newproperty(:item) do
    desc "The item the entry will impact"
    newvalues( :core,:data,:fsize,:memlock,:nofile,:rss,:stack,:cpu,:nproc,:as,:maxlogins,:maxsyslogins,:priority,:locks,:sigpending,:msgqueue,:nice,:rtprio)
  end

  newproperty(:value) do
    desc "The value for the entry"
    newvalues(/^\d+$/)
    munge do |value|
      Integer(value)
    end 
  end

end
