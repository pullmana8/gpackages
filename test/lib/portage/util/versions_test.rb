require 'test_helper'

class VersionsTest < ActiveSupport::TestCase
  def compare(a, b)
    Portage::Util::Versions.compare(a, b)
  end

  test 'parsing versions' do
    ver1 = '1.2.3z_p2-r0'
    res1 = {
        num: [1, 2, 3],
        num_count: 3,
        alph: 'z',
        suffixes: [['p', 2]],
        suffix_count: 1,
        revision: 0
    }

    assert_equal(res1, Portage::Util::Versions.parse(ver1))
  end

  test 'parsing malformed versions' do
    assert_raises Portage::Ebuild::InvalidVersionError do
      Portage::Util::Versions.parse('1.2-ra')
    end
  end

  test 'comparing numeric components' do
    assert_equal -1, compare('1.0', '2.0')
    assert_equal 1, compare('2', '1')
    assert_equal 0, compare('2.2', '2.2')

    assert_equal 0, compare('2.2.2', '2.2.2')
    assert_equal 1, compare('2.2.3', '2.2.2')
    assert_equal -1, compare('2.2', '2.2.2')
  end

  test 'comparing letter suffixes' do
    assert_equal -1, compare('1.0a', '2.0b')
    assert_equal 1, compare('2a', '1b')
    assert_equal 0, compare('2.2a', '2.2a')

    assert_equal -1, compare('2.2a', '2.2b')
    assert_equal 1, compare('2.2e', '2.2b')
  end

  test 'comparing suffixes' do
    assert_equal 0, compare('1_alpha', '1_alpha')
    assert_equal -1, compare('1_alpha', '1_alpha1')
    assert_equal 1, compare('1_alpha2', '1_alpha1')

    assert_equal 0, compare('1_beta12', '1_beta12')
    assert_equal -1, compare('1_alpha34', '1_p')

    assert_equal -1, compare('1_alpha', '1')
    assert_equal 1, compare('1', '1_beta')
    assert_equal 1, compare('1', '1_pre')
    assert_equal -1, compare('1', '1_p42')

    assert_equal 0, compare('1_alpha_alpha', '1_alpha_alpha')
    assert_equal -1, compare('1_alpha_alpha', '1_alpha_beta')
    assert_equal 1, compare('1_p12_alpha', '1_alpha_beta')
    assert_equal 1, compare('1_alpha_beta1', '1_alpha_beta')
  end

  test 'comparing revisions' do
    assert_equal 0, compare('1-r1', '1-r1')
    assert_equal 0, compare('1', '1-r0')
    assert_equal 1, compare('1-r2', '1-r1')
    assert_equal -1, compare('1', '1-r1')
  end
end
