# frozen_string_literal: true

# All models inherit from a common base class
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
