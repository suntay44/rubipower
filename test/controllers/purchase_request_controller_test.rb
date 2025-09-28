require "test_helper"

class PurchaseRequestControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get purchase_request_url
    assert_response :success
  end
end
