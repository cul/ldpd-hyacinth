import React from 'react';
import produce from 'immer';

import ProjectSubHeading from 'hyacinth_ui_v1/hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import hyacinthApi from 'hyacinth_ui_v1/util/hyacinth_api';
import FieldSetForm from './FieldSetForm';
import withErrorHandler from 'hyacinth_ui_v1/hoc/withErrorHandler/withErrorHandler';

class FieldSetNew extends React.Component {
  createFieldSet = (data) => {
    hyacinthApi.post('/projects/'+ this.props.match.params.string_key + '/field_sets', data)
      .then(res => {
        console.log('Field Set created')
        // redirect to edit screen for that user
        console.log(res)
        this.props.history.push('/projects/'+ this.props.match.params.string_key + '/field_sets/' + res.data.field_set.id + '/edit');
      })
      .catch(error => {
        console.log(error)
      });
  }

  render() {
    return(
      <>
        <ProjectSubHeading>Create New Field Set</ProjectSubHeading>
        <FieldSetForm submitFormAction={this.createFieldSet} submitButtonName="Create" />
      </>
    )
  }
}

export default withErrorHandler(FieldSetNew, hyacinthApi)
