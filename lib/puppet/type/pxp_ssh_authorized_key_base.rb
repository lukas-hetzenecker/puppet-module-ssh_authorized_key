# SSH authorized key management for puppet
#
# Copyright (C) 2012 Wunderman PXP GmbH
# Lukas Hetzenecker <lukas.hetzenecker@wunderman.com>
# 
# The bigger part of this file was copied from Puppet:
# Copyright (C) 2005-2012 Puppet Labs Inc

module Puppet
  newtype(:pxp_ssh_authorized_key_base) do
    @doc = "Manages SSH authorized keys. Currently only type 2 keys are
    supported.

    **Autorequires:** If Puppet is managing the user account in which this
    SSH key should be installed, the `ssh_authorized_key` resource will autorequire
    that user."

    ensurable

    def eval_generate
       users = @original_parameters[:user]
       return [] unless users.is_a? Array
       provider.skip
 
       res = []
       
       users.each do |user|
          options = @original_parameters.reject { |param, value| value.nil? }
          
          options[:name] = @title + " (" + user + ")"
          options[:user] = user
          options[:target] = File.expand_path("~#{user}/.ssh/authorized_keys")
          res << self.class.new(options)
       end
       res
    end

    newparam(:name) do
      desc "The puppet visible string for this resource, does not get stored in the authorized_key file"

      isnamevar
   end

    newparam(:type) do
      desc "The encryption type used: ssh-dss or ssh-rsa."

      newvalues :'ssh-dss', :'ssh-rsa', :'ecdsa-sha2-nistp256', :'ecdsa-sha2-nistp384', :'ecdsa-sha2-nistp521'

      aliasvalue(:dsa, :'ssh-dss')
      aliasvalue(:rsa, :'ssh-rsa')
    end

    newparam(:fingerprint) do
      desc "The SSH key fingerprint"

      validate do |value|
        raise Puppet::Error, "Key fingerprint must not contain whitespace: #{value}" if value =~ /\s/
      end
    end

    newparam(:comment) do
      desc "The SSH key comment"
    end

    newproperty(:user) do
      desc "The user account in which the SSH key should be installed.
      The resource will automatically depend on this user."

      def insync?(is)
        provider.exists?
      end
    end

    newproperty(:target) do
      desc "The absolute filename in which to store the SSH key. This
      property is optional and should only be used in cases where keys
      are stored in a non-standard location (i.e.` not in
      `~user/.ssh/authorized_keys`)."

      defaultto :absent

      def should
        return super if defined?(@should) and @should[0] != :absent
        return nil unless user = resource[:user]

        File.expand_path("~#{user}/.ssh/authorized_keys")
      end

      def insync?(is)
        true
      end
    end

    newproperty(:uniquecomment, :boolean => false) do
      desc "If uniquecomment is set to true (default: false), the SSH key and the fingerprint need to be unique.
If there is already a key with the same comment, but a different fingerprint, in the authorized_key file the fingerprint will be changed.

A possible use case for this is the change of the key for a user. The old one doesn't need to be set absent, because the comment stays the same."

      defaultto false
      newvalues(:true, :false)

      #munge do |value|
      #  @resource.munge_boolean(value)
      #end

      def insync?(is)
        true
      end

    end


    newproperty(:options, :array_matching => :all) do
      desc "Key options, see sshd(8) for possible values. Multiple values
        should be specified as an array."

      defaultto do :absent end

      def is_to_s(value)
        if value == :absent or value.include?(:absent)
          super
        else
          value.join(",")
        end
      end

      def should_to_s(value)
        if value == :absent or value.include?(:absent)
          super
        else
          value.join(",")
        end
      end

      validate do |value|
        unless value == :absent or value =~ /^[-a-z0-9A-Z_]+(?:=\".*?\")?$/
          raise Puppet::Error, "Option #{value} is not valid. A single option must either be of the form 'option' or 'option=\"value\". Multiple options must be provided as an array"
        end
      end
    end

    autorequire(:user) do
      should(:user) if should(:user)
    end

    validate do
      # Go ahead if target attribute is defined
      return if @parameters[:target].shouldorig[0] != :absent

      # Go ahead if user attribute is defined
      return if @parameters.include?(:user)

      # If neither target nor user is defined, this is an error
      raise Puppet::Error, "Attribute 'user' or 'target' is mandatory"
    end

  end
end
