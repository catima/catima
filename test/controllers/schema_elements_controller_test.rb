require 'test_helper'

class SchemaElementsControllerTest < ActionController::TestCase
  setup do
    @schema_element = schema_elements(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:schema_elements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create schema_element" do
    assert_difference('SchemaElement.count') do
      post :create, schema_element: { description: @schema_element.description, instance_id: @schema_element.instance_id, name: @schema_element.name }
    end

    assert_redirected_to schema_element_path(assigns(:schema_element))
  end

  test "should show schema_element" do
    get :show, id: @schema_element
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @schema_element
    assert_response :success
  end

  test "should update schema_element" do
    patch :update, id: @schema_element, schema_element: { description: @schema_element.description, instance_id: @schema_element.instance_id, name: @schema_element.name }
    assert_redirected_to schema_element_path(assigns(:schema_element))
  end

  test "should destroy schema_element" do
    assert_difference('SchemaElement.count', -1) do
      delete :destroy, id: @schema_element
    end

    assert_redirected_to schema_elements_path
  end
end
