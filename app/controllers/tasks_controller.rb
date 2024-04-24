class TasksController < ApplicationController
    def index
        @places = Place.all
    end
end
