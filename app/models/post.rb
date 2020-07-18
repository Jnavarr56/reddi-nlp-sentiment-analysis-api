# frozen_string_literal: true

require 'net/http'
require 'date'
require 'uri'
require 'json'

require 'redd'
require 'google/cloud/language'

class Post
  include Mongoid::Document
  field :url, type: String
  field :title, type: String
  field :text, type: String
  field :html, type: String
  field :num_comments, type: Integer
  field :upvotes, type: Integer
  field :downvotes, type: Integer
  field :reddit_id, type: String
  field :posted_at_utc, type: DateTime
  field :author_id, type: String
  field :author_username, type: String
  field :author_icon_img, type: String
  field :sentiment_score, type: Float
  field :sentiment_magnitude, type: Float
  field :sentence_sentiment_analysis, type: Array

  def self.from_query_results(reddit, google)
    new_post_fields = {}
    new_post_fields[:url] = reddit.url
    new_post_fields[:title] = reddit.title
    new_post_fields[:text] = reddit.selftext
    new_post_fields[:html] = reddit.selftext_html
    new_post_fields[:num_comments] = reddit.num_comments
    new_post_fields[:upvotes] = reddit.ups
    new_post_fields[:downvotes] = reddit.downs
    new_post_fields[:reddit_id] = reddit.id
    new_post_fields[:posted_at_utc] = DateTime.strptime(reddit.created_utc.to_i.to_s, '%s')
    new_post_fields[:author_id] = reddit.author.id
    new_post_fields[:author_username] = reddit.author.name
    new_post_fields[:author_icon_img] = reddit.author.icon_img

    new_post_fields[:sentiment_score] = google.document_sentiment.score.to_f
    new_post_fields[:sentiment_magnitude] = google.document_sentiment.magnitude.to_f
    new_post_fields[:sentence_sentiment_analysis] = google.to_h[:sentences]

    Post.new(new_post_fields)
  end

  def self.run_reddit_query(query_filters)
    Rails.cache.clear
    puts "============== RUNNING AT #{DateTime.now} =============="

    Google::Cloud::Language.configure do |config|
      config.credentials = "#{__dir__}/google-language-credentials.json"
    end
    google_language_client = Google::Cloud::Language.language_service
    reddit_client = Redd.it(
      user_agent: 'Jorge\'s Ruby Bot',
      client_id: ENV['REDDIT_CLIENT_ID'],
      secret: ENV['REDDIT_SECRET'],
      auto_refresh: true
    )

    subreddit = reddit_client.subreddit(ENV['SUBREDDIT'])
    subreddit_listing = subreddit.search(ENV['SUBREDDIT_QUERY'], query_filters)
    subreddit_posts = subreddit_listing.to_ary
    subreddit_posts.sort_by!(&:created_utc)

    subreddit_posts.each_with_index do |reddit_post, index|
      saved_post = Post.where(reddit_id: reddit_post.id)

      if saved_post.exists?
        puts "#{index + 1}: Already Analyzed Post: \"#{reddit_post.title}\""
        next
      end

      analyzable_language_document = { content: reddit_post.selftext, type: :PLAIN_TEXT }
      sentiment_analysis_response = google_language_client.analyze_sentiment(document: analyzable_language_document)
      post_sentiment = sentiment_analysis_response.document_sentiment

      begin
        new_post_record = Post.from_query_results(reddit_post, sentiment_analysis_response)
        new_post_record.save!
      rescue StandardError => e
        puts e
      end

      puts '======================================'
      puts "##{index + 1}: \nTITLE: #{reddit_post.title}\nSentiment Score: #{post_sentiment.score}\nMagnitude: #{post_sentiment.magnitude}"
      puts '======================================'
    end

    puts '==============            DONE            =============='
  end

  def self.run_update_query
    Post.run_reddit_query({ time: :hour })
  end

  def self.run_seed_query
    Post.run_reddit_query({ time: :year })
  end
end
