require "test_helper"

class User::InvitationFormTest < ActiveSupport::TestCase
  should validate_presence_of(:catalog)
  should validate_presence_of(:invited_by)

  test "assigns password" do
    user = create_form!
    assert_predicate(user.encrypted_password, :present?)
  end

  test "assigns permissions" do
    user = create_form!
    assert_equal([catalogs(:one).id], user.editor_catalog_ids)
  end

  test "generates token" do
    user = create_form!
    assert_predicate(user.reset_password_token, :present?)
    assert_predicate(user.reset_password_sent_at, :present?)
  end

  test "delivers invitation" do
    mock = InvitationsMailer.expects(:user).with do |user, catalog, token|
      user.is_a?(User) &&
      user.email == "invited@example.com" &&
      token.is_a?(String) &&
      token.strip.present? &&
      catalog == catalogs(:one)
    end
    mock.returns(stub('delivers_invitation', :deliver_later))

    create_form!
  end

  private

  def create_form!(attrs={})
    form = User::InvitationForm.create!(
      attrs.reverse_merge(
        :catalog => catalogs(:one),
        :email => "invited@example.com",
        :primary_language => "en",
        :invited_by => users(:one_admin),
        :catalog_permissions_attributes => {
          "0" => {
            :catalog_id => catalogs(:one).id.to_s,
            :role => "editor"
          }
        }
      ))
    User.find(form.id)
  end
end
