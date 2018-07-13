require 'test_helper'

class UriMatcherTest < Minitest::Test
  def setup
    prefixes = ['/hearbeat', '/admin']
    @matcher = HeimdallApm::UriMatcher.new(prefixes)
  end

  def test_perfect_match
    assert_equal true, @matcher.match?('/hearbeat')
  end

  def test_partial_match
    assert_equal true, @matcher.match?('/admin/users')
  end

  def test_wrong_positive
    assert_equal false, @matcher.match?('/monitor/admin')
  end

  def test_no_match
    assert_equal false, @matcher.match?('/users')
  end
end
