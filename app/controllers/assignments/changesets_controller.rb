class Assignments::ChangesetsController < ApplicationController
  def assignment
    @assignment ||= Assignment.find(params[:id])
  end

  def create
    create_sample_changeset
  end

  # TODO: This is just a sample action for demo-ing changesets
  def create_sample_changeset
    sample_data = {
      "dynamic_field_data" => {
        "title" => [
          {
            "title_sort_portion" => "175 Great Neck Rd."
          }
        ],
        "note" => [
          {
            "note_type" => "Date note",
            "note_value" => "Date range inferred from dates in the New York Real Estate Brochure Collection."
          },
          {
            "note_type" => "provenance",
            "note_value" => "Donated by Yale Robbins, Henry Robbins, & David Magier."
          }
        ]
      }
    }
    assignment.original = JSON.pretty_generate(sample_data)
    sample_data['dynamic_field_data']['title'][0]['title_sort_portion'] = "175 Giraffe Neck Rd."
    sample_data['dynamic_field_data']['note'][0]['note_value'] = "Date range inferred from dates in the Bronx Zoo Brochure Collection."
    assignment.proposed = JSON.pretty_generate(sample_data)
    assignment.save
    redirect_to assignment && return
  end

  def show
  end

  def update
  end

  def destroy
  end
end
