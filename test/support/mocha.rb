# Mocha provides mocking and stubbing helpers
require "mocha/minitest"
Mocha.configure { |c| c.stubbing_non_existent_method = :warn }
Mocha.configure { |c| c.stubbing_non_public_method = :warn }
