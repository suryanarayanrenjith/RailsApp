class UsersController < ApplicationController
  allow_unauthenticated_access only: :show

  # GET /users/1
  def show
    @user = User.find(params.expect(:id))
    @pagination = Pagination.new(@user.posts.newest_first, page: params[:page])
    @posts = @pagination.records
  end
end
