require "test_helper"

class PurchaseOrderControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get purchase_order_index_url
    assert_response :success
  end
end
