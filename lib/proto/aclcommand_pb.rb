# Copyright 2020 Self Group Ltd. All Rights Reserved.

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: aclcommand.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_enum "msgproto.ACLCommand" do
    value :LIST, 0
    value :PERMIT, 1
    value :REVOKE, 2
  end
end

module Msgproto
  ACLCommand = Google::Protobuf::DescriptorPool.generated_pool.lookup("msgproto.ACLCommand").enummodule
end
