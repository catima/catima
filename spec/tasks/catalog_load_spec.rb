require 'spec_helper'
require 'rake'

RSpec.describe 'catalog rake task' do
  before :all do
    Rake.application.rake_require 'tasks/catalog/load'
    Rake::Task.define_task(:environment)
  end

  describe 'catalog:load' do
    let :run_rake_task do
      Rake::Task['catalog:load'].reenable
      Rake.application.invoke_task 'catalog:load'
    end

    it 'should print usage information' do
      expect(CatalogLoadOutput).to receive(:msg)
      expect(CatalogLoadOutput).to receive(:print_usage)
      run_rake_task
    end
  end
end
