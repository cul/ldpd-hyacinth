import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import DynamicFieldGroupForm from './DynamicFieldGroupForm';

class DynamicFieldGroupNew extends React.Component {
  createDynamicFieldGroup = (data) => {
    hyacinthApi.post('/dynamic_field_groups', data)
      .then((res) => {
        const { dynamicFieldGroup: { id } } = res.data

        this.props.history.push(`/dynamic_field_groups/${id}/edit`);
      });
  }

  render() {
    return (
      <>
        <ContextualNavbar
          title="Create Dynamic Field Group"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldGroupForm submitFormAction={this.createDynamicFieldGroup} submitButtonName="Create" />
      </>
    );
  }
}

export default withErrorHandler(DynamicFieldGroupNew, hyacinthApi);
