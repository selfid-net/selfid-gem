# frozen_string_literal: true

require_relative 'test_helper'
require 'selfid'

require 'webmock/minitest'
require 'timecop'

class SelfidTest < Minitest::Test
  describe "selfid" do
    let(:seed)    { "JDAiDNIZ0b7QOK3JNFp6ZDFbkhDk+N3NJh6rQ2YvVFI" }
    let(:app_id)  { "o9mpng9m2jv" }
    let(:app)     do
      a = Selfid::App.new(app_id, seed, messaging_url: nil)
      mm = Minitest::Mock.new
      def mm.device_id; "1"; end
      a.messaging_client = mm
      a
    end
    let(:atoken)    { app.jwt.auth_token }
    let(:headers) {
      {
        'Content-Type' => 'application/json',
      }
    }

    def setup
      ENV["RAKE_ENV"] = "test"
      t = ::Time.local(2019, 9, 1, 10, 5, 0).utc
      Timecop.travel(t)
    end

    def teardown
      Timecop.return
    end

    def test_init_with_defaults
      assert_equal "https://api.selfid.net", app.client.self_url
      assert_equal app_id, app.app_id
      assert_equal seed, app.app_key
    end

    def test_init_with_custom_parameters
      custom_app = Selfid::App.new(app_id, seed, base_url: "http://custom.self.net", messaging_url: nil)
      assert_equal "http://custom.self.net", custom_app.client.self_url
      assert_equal app_id, custom_app.app_id
      assert_equal seed, custom_app.app_key
    end

    def test_authenticate
      body = "{\"payload\":\"eyJkZXZpY2VfaWQiOiIxIiwidHlwIjoiYXV0aGVudGljYXRpb25fcmVxIiwiYXVkIjoiaHR0cHM6Ly9hcGkuc2VsZmlkLm5ldCIsImlzcyI6Im85bXBuZzltMmp2Iiwic3ViIjoieHh4eHh4eHgiLCJpYXQiOiIyMDE5LTA5LTAxVDEwOjA1OjAwWiIsImV4cCI6IjIwMTktMDktMDFUMTE6MDU6MDBaIiwiY2lkIjoidXVpZCIsImp0aSI6InV1aWQifQ\",\"protected\":\"eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9\",\"signature\":\"9IrKkOUxUsEpQeR-7QR1wYzmgglkrl8XX_sqixZMONOSqXw0QCKr7zy_YyOpob-Lq5rHsYbIE7j1tz-w1ee2Ag\"}"
      stub_request(:post, "https://api.selfid.net/v1/auth").
        with(body: body, headers: headers).
        to_return(status: 200, body: "", headers: {})

      app.authentication.request("xxxxxxxx", uuid: "uuid", jti: "uuid", request: false)
    end

    def test_identity
      pk = "pk_111222333"
      id = "11122233344"

      stub_request(:get, "https://api.selfid.net/v1/identities/#{id}").
        with(headers: headers).
        to_return(status: 200, body: '{"public_keys":[{"id":"1","key":"' + pk + '"}]}', headers: {})

      identity = app.identity.get(id)
      assert_equal pk, identity[:public_keys].first[:key]
    end

    def test_app
      pk = "pk_111222333"
      id = "111222333"

      stub_request(:get, "https://api.selfid.net/v1/apps/#{id}").
        with(headers: headers).
        to_return(status: 200, body: '{"public_keys":[{"id":"1","key":"' + pk + '"}]}', headers: {})

      a = app.identity.app(id)
      assert_equal pk, a[:public_keys].first[:key]
    end

  end
end