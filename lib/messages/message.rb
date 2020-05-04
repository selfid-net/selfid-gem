# frozen_string_literal: true

require_relative "fact_request"
require_relative "fact_response"
require_relative "authentication_resp"
require_relative "authentication_req"

module Selfid
  module Messages
    def self.parse(input, messaging, original=nil)
      body = if input.is_a? String
               input
             else
               input.ciphertext
             end

      jwt = JSON.parse(body, symbolize_names: true)
      payload = JSON.parse(messaging.jwt.decode(jwt[:payload]), symbolize_names: true)

      case payload[:typ]
      when "identity_info_req"
        m = FactRequest.new(messaging)
        m.parse(body)
      when "identity_info_resp"
        m = FactResponse.new(messaging)
        m.parse(body)
      when "authentication_resp"
        m = AuthenticationResp.new(messaging)
        m.parse(body)
      when "authentication_req"
        m = AuthenticationReq.new(messaging)
        m.parse(body)
      else
        raise StandardError.new("Invalid message type.")
      end
      return m
    end
  end
end
