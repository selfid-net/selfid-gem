# frozen_string_literal: true

require_relative '../test_helper'
require 'rspec/mocks/minitest_integration'
require 'selfid'

require 'webmock/minitest'

class SelfidTest < Minitest::Test
  describe "authentication service" do
    let(:cid) {'cid'}
    let(:app_device_id) {'1'}
    let(:selfid) {'user_self_id'}
    let(:appid) { 'app_self_id' }
    let(:url) { 'https://my.app.com' }
    let(:json_body) { '{}' }
    let(:jwt) do
      j = double("jwt")
      expect(j).to receive(:id).and_return(appid)
      expect(j).to receive(:prepare) do |arg|
        assert_equal arg[:device_id], app_device_id
        assert_equal arg[:typ], "authentication_req"
        assert_equal arg[:aud], url
        assert_equal arg[:iss], appid
        assert_equal arg[:sub], selfid
        assert_equal arg[:cid], cid
      end.and_return(json_body)
      j
    end
    let(:client) do
      mm = double("client")
      expect(mm).to receive(:self_url).and_return(url)
      expect(mm).to receive(:jwt).and_return(jwt).at_least(:once)
      mm
    end
    let(:messaging) do
      mm = double("messaging")
      expect(mm).to receive(:device_id).and_return(app_device_id)
      mm
    end
    let(:service) { Selfid::Services::Authentication.new(messaging, client) }
    let(:response_input) { 'input' }
    let(:response) { double("response", input: response_input) }
    let(:identity) { { public_keys: [ { key: "pk1"} ] } }

    def test_get_request_body
      req = service.request(selfid, uuid: cid, request: false)
      assert_equal json_body, req
    end

    def test_non_blocking_request
      expect(client).to receive(:auth).with(json_body).once
      expect(messaging).to receive(:set_observer).with(cid).once
      res = service.request selfid, uuid: cid do
        assert_true true
      end
      assert_equal cid, res
    end

    def test_blocking_request
      payload = {cid: "cid", sub: "sub", status: "accepted"}
      expect(client).to receive(:entity).with("sub").once.and_return(identity)
      expect(messaging).to receive(:wait_for).with(cid).once.and_return(response)
      expect(jwt).to receive(:parse).with(response_input).once.and_return({payload: "xx"})
      expect(jwt).to receive(:decode).with("xx").once.and_return(payload.to_json)
      expect(jwt).to receive(:verify).with({payload: "xx"}, "pk1").once.and_return(true)

      res = service.request selfid, uuid: cid
      assert_equal "cid", res.uuid
      assert_equal "sub", res.selfid
      assert_equal true, res.accepted?
      assert_equal payload, res.payload
    end

    def test_generate_qr
      res = service.generate_qr(selfid: selfid, uuid: cid)
      assert_equal RQRCode::QRCode, res.class
    end

  end
end