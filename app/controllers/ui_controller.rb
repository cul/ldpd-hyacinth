# frozen_string_literal: true

class UiController < ApplicationController
  def v1
    render layout: 'hyacinth_v1'
  end
end
