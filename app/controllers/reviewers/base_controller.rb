class Reviewers::BaseController < ApplicationController
  before_action :authenticate_reviewer!
end
