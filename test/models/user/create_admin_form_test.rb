require "test_helper"

class User::CreateAdminFormTest < ActiveSupport::TestCase
  should validate_presence_of(:invited_by)

  test "system_admin defaults to false" do
    refute(User::CreateAdminForm.new.system_admin?)
  end

  test "system_admin defaults to true if there are no catalogs" do
    User::CreateAdminForm.any_instance.stubs(:catalog_choices => [])
    assert(User::CreateAdminForm.new.system_admin?)
  end

  test "#catalog_choices" do
    assert_equal(
      Catalog.active.sorted,
      User::CreateAdminForm.new.catalog_choices
    )
  end

  test "assigns password" do
    user = create_form!
    assert_predicate(user.encrypted_password, :present?)
  end

  test "assigns permissions" do
    catalog_ids = [catalogs(:one).id]
    user = create_form!(:catalog_ids => catalog_ids)
    assert_equal(catalog_ids, user.admin_catalog_ids)
  end

  test "generates token" do
    user = create_form!
    assert_predicate(user.reset_password_token, :present?)
    assert_predicate(user.reset_password_sent_at, :present?)
  end

  test "delivers invitation" do
    mock = InvitationsMailer.expects(:admin).with do |user, token|
      user.is_a?(User) &&
      user.email == "create-form@example.com" &&
      token.is_a?(String) &&
      token.strip.present?
    end
    mock.returns(stub(:deliver_later))

    create_form!
  end

  test "requires a catalog_id be provided if not system admin" do
    assert_raises(ActiveRecord::RecordInvalid) do
      create_form!(:catalog_ids => [], :system_admin => false)
    end
  end

  test "doesn't require a catalog_id be provided if system admin" do
    create_form!(:catalog_ids => [""], :system_admin => true)
  end

  private

  def create_form!(attrs={})
    form = User::CreateAdminForm.create!(
      attrs.reverse_merge(
        :email => "create-form@example.com",
        :primary_language => "en",
        :invited_by => users(:system_admin),
        :catalog_ids => [catalogs(:one).id]
      ))
    User.find(form.id)
  end
end
