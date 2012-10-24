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

    newparam(:name) do
      desc "The SSH key fingerprint. This attribute is currently used as a
      system-wide primary key and therefore has to be unique."

      isnamevar

      validate do |value|
        raise Puppet::Error, "Key fingerprint must not contain whitespace: #{value}" if value =~ /\s/
      end
    end

    newproperty(:type) do
      desc "The encryption type used: ssh-dss or ssh-rsa."

      newvalues :'ssh-dss', :'ssh-rsa', :'ecdsa-sha2-nistp256', :'ecdsa-sha2-nistp384', :'ecdsa-sha2-nistp521'

      aliasvalue(:dsa, :'ssh-dss')
      aliasvalue(:rsa, :'ssh-rsa')
    end

    newparam(:comment) do
      desc "The SSH key comment"
    end

    newproperty(:user, :array_matching => :all) do
      desc "The user account in which the SSH key should be installed.
      The resource will automatically depend on this user."
    end

    newproperty(:target, :array_matching => :all) do
      desc "The absolute filename in which to store the SSH key. This
      property is optional and should only be used in cases where keys
      are stored in a non-standard location (i.e.` not in
      `~user/.ssh/authorized_keys`)."

      defaultto :absent

      def should
        return super if defined?(@should) and @should[0] != :absent
        return nil unless users = resource[:user]

        users = [users] unless users.is_a? Array
        #targets = Array.new(users.length)
        targets = Array.new
        users.each do |user|
#          puts "(type) user is " + user + "\n"
          begin
            targets << File.expand_path("~#{user}/.ssh/authorized_keys")
          rescue
            Puppet.debug "The required user #{user} is not yet present on the system"
            return nil
          end
        end
        return targets
      end

      def insync?(is)
        is == should
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
