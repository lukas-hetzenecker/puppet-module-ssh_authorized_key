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
    @changed_targets = Set.new

    @target_records = {}
    @resource_hash = {}
  end

  def create
    #puts "!!!! CREATE: RESOURCE IS NOW: " + resource[:comment] + ": " + resource[:ensure].to_s
    update_files
  end

  def destroy
    #puts "!!!! DESTROY: RESOURCE IS NOW: " + resource[:comment] + ": " + resource[:ensure].to_s
    update_files
  end

  def exists?
    #puts "!!!! EXISTS: RESOURCE IS NOW: " + resource[:comment] + ": " + resource[:ensure].to_s

    parse_targets

    @changed_targets.empty? == (resource[:ensure] == :present)
  end

  def update_files
    @changed_targets.each do |f|
      update_file(f)
    end
  end

  def parse_targets
    @resource_hash = resource.to_hash
    @resource_hash[:record_type] = :parsed

    targets = resource[:target]
    targets = [targets] unless targets.is_a? Array

    targets.each do |target|
      parse_target(target)
    end
  end

  def parse_target(target)
    parser = Parser.new(resource)
    parser.class.initvars

    records = parser.class.prefetch_target(target)

    found = false
 
    records.each do |record|
      unless match_record?(record):
        next
      end

      if resource[:ensure] == :present
        if found
          @changed_targets << target
          record[:ensure] = :absent

        elsif parser.class.to_line(record) != parser.class.to_line(@resource_hash)
          @changed_targets << target

          record[:name]    = resource[:name] unless (record[:name] == resource[:name])
          record[:comment] = resource[:comment] unless (record[:comment] == resource[:comment])
          record[:options] = resource[:options] unless (record[:options] == resource[:options])
          record[:ensure]  = resource[:ensure] unless (record[:ensure] == resource[:ensure])
        end

      elsif resource[:ensure] == :absent
        @changed_targets << target
        record[:ensure] = :absent
      end
 
      found = true
    end

    if resource[:ensure] == :present and !found
       @changed_targets << target
       records << @resource_hash
    end

    @target_records[target] = records
    parser.class.clear
  end  

  def match_record?(record)
    record[:name] == resource[:name] or (resource[:uniquecomment] == :true and record[:comment] == resource[:comment])
  end

  def update_file(target)
    records = @target_records[target].reject { |r|
      r[:ensure] == :absent
    }

    Parser.backup_target(target)
    Puppet::Util::FileType.filetype(:flat).new(target).write(Parser.to_file(records))
  end

end
