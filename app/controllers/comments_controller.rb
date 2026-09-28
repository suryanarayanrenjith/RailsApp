class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: :destroy
  rate_limit to: 10, within: 1.minute, only: :create, with: -> { redirect_to @post, alert: "You're commenting too quickly. Try again in a minute." }

  # POST /posts/1/comments
  def create
    @comment = @post.comments.build(comment_params.merge(user: Current.user))

    respond_to do |format|
      if @comment.save
        format.turbo_stream
        format.html { redirect_to post_path(@post, anchor: helpers.dom_id(@comment)), notice: "Comment added." }
      else
        format.turbo_stream { render :form_with_errors, status: :unprocessable_entity }
        format.html { redirect_to post_path(@post, anchor: "new_comment"), alert: @comment.errors.full_messages.to_sentence }
      end
    end
  end

  # DELETE /posts/1/comments/1
  def destroy
    if @comment.deletable_by?(Current.user)
      @comment.destroy!

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post, notice: "Comment deleted.", status: :see_other }
      end
    else
      redirect_to @post, alert: "You can only delete your own comments.", status: :see_other
    end
  end

  private
    def set_post
      @post = Post.find(params.expect(:post_id))
    end

    def set_comment
      @comment = @post.comments.find(params.expect(:id))
    end

    def comment_params
      params.expect(comment: [ :body ])
    end
end
