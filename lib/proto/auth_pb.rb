# Copyright 2020 Self Group Ltd. All Rights Reserved.

# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: auth.proto

require 'google/protobuf'

require_relative 'msgtype_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "msgproto.Auth" do
    optional :type, :enum, 1, "msgproto.MsgType"
    optional :id, :string, 2
    optional :token, :string, 3
    optional :device, :string, 4
    optional :offset, :int64, 5
  end
end

module Msgproto
  Auth = Google::Protobuf::DescriptorPool.generated_pool.lookup("msgproto.Auth").msgclass
end
