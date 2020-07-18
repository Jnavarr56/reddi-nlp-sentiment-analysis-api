# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  # GET /posts
  def index
    in_cache = true
    @posts = Rails.cache.fetch('/index', expires_in: 30.minutes) do
      in_cache = false
      Post.all
    end

    puts "FROM CACHE: #{in_cache}"
    render json: @posts
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # DISABLING ALL ROUTES THAT AREN'T READ.

  # POST /posts
  # def create
  #   @post = Post.new(post_params)

  #   if @post.save
  #     render json: @post, status: :created, location: @post
  #   else
  #     render json: @post.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /posts/1
  # def update
  #   if @post.update(post_params)
  #     render json: @post
  #   else
  #     render json: @post.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /posts/1
  # def destroy
  #   @post.destroy
  # end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Rails.cache.fetch(params[:id], expires_in: 30.minutes) do
      Post.find(params[:id])
    end
  end

  # Only allow a trusted parameter "white list" through.
  def post_params
    params.require(:post).permit(:url, :title, :text, :html, :num_comments, :upvotes, :downvotes, :reddit_id, :posted_at_utc, :author_id, :author_username, :author_icon_img, :sentiment_score, :sentiment_magnitude, :sentence_sentiment_analysis)
  end
end
