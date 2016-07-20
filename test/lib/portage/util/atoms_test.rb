require 'test_helper'

class AtomsTest < ActiveSupport::TestCase
  def matches?(atom, version, slot = '0')
    Portage::Util::Atoms.matches?(atom, version, slot)
  end

  def parse(atom)
    Portage::Util::Atoms.parse(atom)
  end

  test 'parsing' do
    assert_equal({
                     prefix: nil,
                     cmp: '>=',
                     category: 'games-emulation',
                     package: 'mupen64plus',
                     version: '2-r2',
                     postfix: nil,
                     slot: nil,
                     subslot: nil
                 },
                 parse('>=games-emulation/mupen64plus-2-r2'))
  end

  test 'matching plain versions' do
    assert matches?('dev-lang/ruby', '0.0.9')
    assert matches?('dev-lang/ruby', '1.2.3')
    assert matches?('dev-lang/ruby', '0.0.9', 'slotfoo')
  end

  test 'version wildcards' do
    assert matches?('=dev-lang/ruby-2*', '2.1.2')
    assert_not matches?('=dev-lang/ruby-2*', '3.3')

    # Known as not working. But do we need this?
    # assert matches?('>=dev-lang/ruby-2*', '3.3')
  end

  test 'revision wildcards' do
    assert matches?('~dev-lang/ruby-2.0.4', '2.0.4-r0')
    assert matches?('~dev-lang/ruby-2.0.4', '2.0.4-r12')
    assert matches?('~dev-lang/ruby-2.0.4', '2.0.4')
    assert_not matches?('~dev-lang/ruby-2.0.4', '2.0.5')
    assert_not matches?('~dev-lang/ruby-2.0.4', '2.0')
  end

  test 'plain slots' do
    assert matches?('dev-lang/ruby:3', '1.2.3', '3')
    assert_not matches?('dev-lang/ruby:3', '1.2.3')
    assert_not matches?('dev-lang/ruby:3', '1.2.3', '4')

    assert matches?('dev-lang/ruby', '1.2.3', '4')
  end

  test 'slots and other stuff' do

  end

  test 'good ol comparing' do
    assert matches?('=dev-lang/ruby-2.0.4', '2.0.4')
    assert matches?('>=dev-lang/ruby-2.0.4', '2.0.4')
    assert matches?('<=dev-lang/ruby-2.0.4', '2.0.4')

    assert_not matches?('=dev-lang/ruby-2.0.4', '2')
    assert_not matches?('<=dev-lang/ruby-2.0.4', '3')
    assert_not matches?('>=dev-lang/ruby-2.0.4', '1')
  end

end