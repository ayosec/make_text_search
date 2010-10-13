# coding: utf-8

require 'test_helper'

class BasicsTest < ActiveSupport::TestCase

  def query(words, expected_ids)
    assert_equal expected_ids.sort, Post.search_text(words).map {|post| post.id }.sort, "The query #{words.inspect} expects #{expected_ids.inspect}"
  end

  test "the filter can be used after create some records" do
    first = Post.create!(:title => "First post", :content => "111 222").id
    second = Post.create!(:title => "Second post", :content => "random text").id

    query "post", [first, second]
    query "First", [first]
    query "first", [first]
    query "random", [second]
    query "0", []
    query "11", []

    # With substrings. Filter has be to activated in the model (see test/app_template.rb)
    query "econ", [second]
    query "andom", [second]
  end

  test "search_text can be re-scoped" do
    20.times { Post.create!(:title => "The same post", :content => "somethingwithoutsense") }

    assert_equal 20, Post.search_text("somethingwithoutsense").count
    assert_equal 2, Post.search_text("somethingwithoutsense").limit(2).count
    assert_equal "The same post", Post.search_text("somethingwithoutsense").last.title
  end

  test "the index is updated after change the posts" do
    colors = {}
    %w(red green blue black white orange).each {|color| colors[color] = Post.create!(:title => "Post #{color}") }

    query "red", [colors["red"].id]
    assert_equal Post.search_text("post").count, colors.size

    colors["red"].destroy

    query "red", []
    assert_equal Post.search_text("post").count, colors.size - 1

    colors["black"].update_attribute :content, "Old red"
    query "red", [colors["black"].id]
  end

  test "html entities are translated with filters" do

    begin
      old_default_language = Rails.application.config.make_text_search.default_language
      Rails.application.config.make_text_search.default_language = "spanish"

      spain = Post.create!(:content => "Pa&iacute;s Espa&ntilde;a")
      query "país", [spain.id]
      query "españa", [spain.id]
    ensure
      Rails.application.config.make_text_search.default_language = old_default_language
    end
  end

end
