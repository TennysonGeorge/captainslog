require "test_helper"

class EntryControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in user }

  test "it can destroy an entry owned" do
    entry = create(:entry, :user => user)
    delete "/book/#{entry.book.slug}/entry/#{entry.id}"
    assert_response :redirect
  end

  test "it fails to delete an entry not owned by the active user" do
    entry = create(:entry, :user => create(:user))
    assert_raises(ActiveRecord::RecordNotFound) { delete "/book/#{entry.book.slug}/entry/#{entry.id}" }
  end

  test "it redirects to the home page by default" do
    entry = create(:entry, :user => user)
    redirect = entry.collection_path
    delete "/book/#{entry.book.slug}/entry/#{entry.id}"
    assert_redirected_to redirect
  end
end
