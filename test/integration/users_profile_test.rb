require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest

  def setup
    @user = users :michael
  end

  test "profile display" do
    log_in_as @user
    get user_path @user
    assert_template "users/show"
    assert_select "title", @user.name + " | Ruby on Rails Tutorial Sample App"
    assert_select "h1", text: @user.name
    assert_select "h1>img.gravatar"
    assert_match @user.microposts.count.to_s, response.body
    assert_select "div.pagination"
    @user.microposts.order_desc.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
