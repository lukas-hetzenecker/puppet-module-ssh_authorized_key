# SSH authorized key management for puppet
#
# Copyright (C) 2012 Wunderman PXP GmbH
# Lukas Hetzenecker <lukas.hetzenecker@wunderman.com>

require 'set'

require 'puppet'
require 'puppet/type'
require 'puppet/provider'
require 'puppet/provider/parsedfile'
require 'puppet/util/filetype'
require 'puppet/util/fileparsing'

require File.expand_path('../../../util/ssh_authorized_key_file_parser.rb', __FILE__)

Puppet::Type.type(:pxp_ssh_authorized_key_base).provide :base, :parent => Puppet::Provider do
  extend Puppet::Util::FileParsing

  Parser.default_target = ''

  def initialize(record)
    super

    self.class.mk_resource_methods
    initvars
  end

  def initvars
    @changed = false
    @skip = false

    @target_records = []
    @resource_hash = {}
  end

  def create
    return if skip?
    update_file
  end

  def destroy
    return if skip?
    update_file
  end

  def exists?
    return (resource[:ensure] == :present) if skip?

    parse
    @changed != (resource[:ensure] == :present)
  end

  def skip
    @skip = true
  end

  def skip?
    @skip
  end

  def parse
    @resource_hash = resource.to_hash
    @resource_hash[:record_type] = :parsed

    target = resource[:target]
    return unless target.is_a? String

    parser = Parser.new(resource)
    parser.class.initvars

    records = parser.class.prefetch_target(target)

    found = false
 
    records.each do |record|
      record[:target] = resource[:target]
      unless match_record?(record):
        @target_records << record
        next
      end

      if resource[:ensure] == :present
        if found
          @changed = true
          record[:ensure] = :absent

        elsif parser.class.to_line(record) != parser.class.to_line(@resource_hash)
          #puts "CHANGED: record: " + parser.class.to_line(record)
          #puts "CHANGED: resour: " + parser.class.to_line(@resource_hash)

          @changed = true

          @property_hash[:type] = record[:type] = resource[:type]
          @property_hash[:fingerprint] = record[:fingerprint] = resource[:fingerprint]
          @property_hash[:comment] = record[:comment] = resource[:comment]
          @property_hash[:options] = record[:options] = resource[:options]
          @property_hash[:ensure] = record[:ensure] = resource[:ensure]
        end

      elsif resource[:ensure] == :absent
        #puts "CHANGED: line shouldn't be here"
        @changed = true
        @property_hash[:ensure] = record[:ensure] = :absent
      end

      @target_records << record
      found = true
    end

    if resource[:ensure] == :present and !found
       #puts "CHANGED: key not found"
       @changed = true
       @target_records << @resource_hash
    end

    parser.class.clear
  end  

  def match_record?(record)
    record[:fingerprint] == resource[:fingerprint] or (resource[:uniquecomment] == :true and record[:comment] == resource[:comment])
  end

  def update_file
    target = resource[:target]

    records = @target_records.reject { |r|
      r[:ensure] == :absent
    }

    Parser.backup_target(target)
    Puppet::Util::FileType.filetype(:flat).new(target).write(Parser.to_file(records))
  end

end
