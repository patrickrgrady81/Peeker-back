require 'test_helper'

class ComputeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get compute_index_url
    assert_response :success
  end

end
