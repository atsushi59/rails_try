# frozen_string_literal: true

# dividing the tasks
class TasksController < ApplicationController
  def index
    @places = Place.all
  end
end
