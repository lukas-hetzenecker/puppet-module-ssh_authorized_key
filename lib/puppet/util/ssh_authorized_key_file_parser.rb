# SSH authorized key management for puppet
#
# Copyright (C) 2012 Wunderman PXP GmbH
# Lukas Hetzenecker <lukas.hetzenecker@wunderman.com>
# 
# The bigger part of this file was copied from Puppet:
# Copyright (C) 2005-2012 Puppet Labs Inc

require 'puppet'
#require 'puppet/util'
#require 'puppet/util/fileparsing'
require 'puppet/provider/parsedfile'

class Parser < Puppet::Provider::ParsedFile 
   text_line :comment, :match => /^\s*#/
   text_line :blank, :match => /^\s*$/
    
   record_line :parsed,
     :fields   => %w{options type name comment},
     :optional => %w{options},
     :rts => /^\s+/,
     :match    => /^(?:(.+) )?(ssh-dss|ssh-rsa|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ([^ ]+) ?(.*)$/,
     :post_parse => proc { |h|
       h[:comment] = "" if h[:comment] == :absent
       h[:options] ||= [:absent]
       h[:options] = Parser.parse_options(h[:options]) if h[:options].is_a? String
     },
     :pre_gen => proc { |h|
       h[:options] = [] if h[:options].include?(:absent)
       h[:options] = h[:options].join(',')
    }

   record_line :key_v1,
     :fields   => %w{options bits exponent modulus name},
     :optional => %w{options},
     :rts      => /^\s+/,
     :match    => /^(?:(.+) )?(\d+) (\d+) (\d+)(?: (.+))?$/

# Should we skip the record?  Basically, we skip text records.
# This is only here so subclasses can override it.
  def self.skip_record?(record)
     puts "skip record?"
     puts record[:record_type]
     record_type(record[:record_type]).text?
  end

  # parse sshv2 option strings, wich is a comma separated list of
  # either key="values" elements or bare-word elements
  def self.parse_options(options)
    result = []
    scanner = StringScanner.new(options)
    while !scanner.eos?
      scanner.skip(/[ \t]*/)
      # scan a long option
      if out = scanner.scan(/[-a-z0-9A-Z_]+=\".*?\"/) or out = scanner.scan(/[-a-z0-9A-Z_]+/)
        result << out
      else
        # found an unscannable token, let's abort
        break
      end
      # eat a comma
      scanner.skip(/[ \t]*,[ \t]*/)
    end
    result
  end

end

