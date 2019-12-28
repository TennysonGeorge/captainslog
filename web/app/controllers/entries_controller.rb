class EntriesController < ApplicationController
  around_action :user_timezone
  before_action :require_login

  # === URL
  #   POST /book/:book_id/entry
  #
  # === Request fields
  #   [Integer] book_id - the book id for the book to add the entry to
  #   [String] text - entry's original text
  #
  # === Sample request
  #   /book/1/entry?text=abc123
  #
  # === Sample response (HTML)
  #   Redirect to /book/1
  #
  def create
    current_book.add_entry(params[:text], requested_time)
    redirect_to book_at_path(current_book, requested_time.to_i)
  end
end
