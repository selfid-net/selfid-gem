# frozen_string_literal: true

require_relative 'base'
require_relative '../ntptime'

module Selfid
  module Messages
    class IdentityInfoReq < Base
      MSG_TYPE = "identity_info_req"

      attr_accessor :facts

      def populate(selfid, facts, opts)
        @id = SecureRandom.uuid
        @from = @client.jwt.id
        @to = selfid
        @facts = facts

        @id = opts[:cid] if opts.include?(:cid)
        @description = opts.include?(:description) ? opts[:description] : nil

        if opts.include?(:intermediary)
          @intermediary = opts[:intermediary]
          devices = @client.devices(@intermediary)
        else
          @intermediary = nil
          devices = @client.devices(selfid)
        end
        @to_device = devices.first
      end

      def parse(input)
        @input = input
        @typ = MSG_TYPE
        @payload = get_payload input
        @id = @payload[:cid]
        @from = @payload[:iss]
        @to = @payload[:sub]
        @expires = @payload[:exp]
        @description = @payload.include?(:description) ? @payload[:description] : nil
        @facts = @payload[:facts]
      end

      def build_response
        m = Selfid::Messages::IdentityInfoResp.new(@messaging)
        m.id = @id
        m.from = @to
        m.to = @from
        m.to_device = @messaging.device_id
        m.facts = @facts
        m
      end

      def share_facts(facts)
        m = build_response
        m.facts = facts
        m.send_message
      end

      def body
        b = {
          typ: MSG_TYPE,
          iss: @jwt.id,
          sub: @to,
          iat: Selfid::Time.now.strftime('%FT%TZ'),
          exp: (Selfid::Time.now + 3600).strftime('%FT%TZ'),
          cid: @id,
          jti: SecureRandom.uuid,
          facts: @facts,
        }

        b[:description] = @description unless (@description.nil? || @description.empty?)
        b
      end

      protected

      def proto
        recipient = if @intermediary.nil?
                      "#{@to}:#{@to_device}"
                    else
                      "#{@intermediary}:#{@to_device}"
                    end

        Msgproto::Message.new(
          type: Msgproto::MsgType::MSG,
          id: @id,
          sender: "#{@jwt.id}:#{@messaging.device_id}",
          recipient: recipient,
          ciphertext: @jwt.prepare(body),
        )
      end
    end
  end
end
