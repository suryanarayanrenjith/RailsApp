class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :require_author, only: %i[ edit update destroy ]

  # GET /posts or /posts.json
  def index
    @query = params[:query].to_s.strip
    @pagination = Pagination.new(Post.search(@query).newest_first.includes(:user), page: params[:page])
    @posts = @pagination.records
  end

  # GET /posts/1 or /posts/1.json
  def show
    @comments = @post.comments.chronological.includes(:user)
    @comment = Comment.new(post: @post)
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts or /posts.json
  def create
    @post = Current.user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    def set_post
      @post = Post.find(params.expect(:id))
    end

    def require_author
      return if @post.authored_by?(Current.user)

      respond_to do |format|
        format.html { redirect_to @post, alert: "You can only change posts that you wrote." }
        format.json { head :forbidden }
      end
    end

    def post_params
      params.expect(post: [ :title, :body ])
    end
end
