require "test_helper"

class Field::ImagePresenterTest < ActionView::TestCase
  test "#value with legend" do
    author = items(:one_author_with_images)
    picture_field = Field.find ActiveRecord::FixtureSet.identify('one_author_picture')
    presenter = Field::ImagePresenter.new(self, author, picture_field)
    assert_match("One author picture", presenter.value)
  end

  test "#value without legend" do
    author = items(:one_author_with_images)
    picture_field = Field.find ActiveRecord::FixtureSet.identify('one_author_picture_inactive_legend')
    presenter = Field::ImagePresenter.new(self, author, picture_field)
    refute_match("One author new picture", presenter.value)
  end
end
