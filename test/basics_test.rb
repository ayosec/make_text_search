require 'test_helper'

class BasicsTest < ActiveSupport::TestCase

  def query(words, expected_ids)
    assert_equal Post.search_text(words).map {|post| post.id }.sort, expected_ids.sort, "The query #{words.inspect} expects #{expected_ids.inspect}"
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
    query "ran", []
  end

  test "search_text can be re-scoped" do
    20.times { Post.create!(:title => "The same post", :content => "somethingwithoutsense") }
    assert_equal Post.search_text("somethingwithoutsense").count, 20
    assert_equal Post.search_text("somethingwithoutsense").limit(2).count, 2
    assert_equal Post.search_text("somethingwithoutsense").last.title, "The same post"
  end
end
