# frozen_string_literal: true

require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
  end

  test 'should get index' do
    get posts_url, as: :json
    assert_response :success
  end

  test 'should create post' do
    assert_difference('Post.count') do
      post posts_url, params: { post: { author_icon_img: @post.author_icon_img, author_id: @post.author_id, author_username: @post.author_username, downvotes: @post.downvotes, html: @post.html, num_comments: @post.num_comments, posted_at_utc: @post.posted_at_utc, reddit_id: @post.reddit_id, sentence_sentiment_analysis: @post.sentence_sentiment_analysis, sentiment_score: @post.sentiment_score, sentiment_magnitude: @post.sentiment_magnitude, text: @post.text, title: @post.title, upvotes: @post.upvotes, url: @post.url } }, as: :json
    end

    assert_response 201
  end

  test 'should show post' do
    get post_url(@post), as: :json
    assert_response :success
  end

  test 'should update post' do
    patch post_url(@post), params: { post: { author_icon_img: @post.author_icon_img, author_id: @post.author_id, author_username: @post.author_username, downvotes: @post.downvotes, html: @post.html, num_comments: @post.num_comments, posted_at_utc: @post.posted_at_utc, reddit_id: @post.reddit_id, sentence_sentiment_analysis: @post.sentence_sentiment_analysis, sentiment_score: @post.sentiment_score, sentiment_magnitude: @post.sentiment_magnitude, text: @post.text, title: @post.title, upvotes: @post.upvotes, url: @post.url } }, as: :json
    assert_response 200
  end

  test 'should destroy post' do
    assert_difference('Post.count', -1) do
      delete post_url(@post), as: :json
    end

    assert_response 204
  end
end
