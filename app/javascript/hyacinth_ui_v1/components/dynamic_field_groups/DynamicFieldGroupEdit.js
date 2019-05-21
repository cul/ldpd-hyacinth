import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';

class DynamicFieldGroupEdit extends React.Component {
  updateDynamicFieldGroup = (data) => {
    const { params: { id } } = this.props.match;

    hyacinthApi.patch(`/dynamic_field_groups/${id}`, data)
      .then((res) => {
        this.props.history.push(`/dynamic_field_groups/${id}/edit`);
      });
  }

  render() {
    console.log("in dynamic field group edit")
    return (
      <>
        <ContextualNavbar
          title="Update Dynamic Field Group"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldGroupForm
          key={this.props.match.params.id}
          submitFormAction={this.updateDynamicFieldGroup}
          submitButtonName="Update"
        />
      </>
    );
  }
}

export default withErrorHandler(DynamicFieldGroupEdit, hyacinthApi);
