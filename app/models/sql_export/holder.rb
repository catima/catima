# Model to help with SQL exports and duplicates
class SQLExport::Holder
  # tables = { :table_name => id + class + item_type_slug|id + class + category_name|id + class + choiceset_name... }
  attr_accessor :tables

  TABLE_PREFIXES = {
    "ItemType" => "it_type_",
    "Category" => "cat_",
    "ChoiceSet" => "choice_set_",
    "Field::Reference" => "ref_"
  }.freeze

  def initialize
    self.tables = {}
  end

  def guess_table_name(model, method)
    table_name = build_table_name(model, method)
    while tables.key?(table_name)
      model.id += 1
      table_name = build_table_name(model, method, model.id)
    end

    tables[table_name] = "#{model.id}_#{model.class.name}_#{model.public_send(method)}"

    table_name
  end

  def table_name(model, method)
    tables.key("#{model.id}_#{model.class.name}_#{model.public_send(method)}")
  end

  private

  def build_table_name(model, method, index=nil)
    name = TABLE_PREFIXES[model.class.name]
    name += "#{index}_" unless index.nil?
    name += model.public_send(method)

    name.truncate(CatalogAdmin::SqlDumpHelper::MAX_SQL_NAME_LENGTH).downcase
  end
end
