import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import DynamicFieldCategoryForm from './DynamicFieldCategoryForm';

class DynamicFieldCategoryNew extends React.Component {
  createDynamicFieldGroup = (data) => {
    hyacinthApi.post('/dynamic_field_categories', data)
      .then((res) => {
        const { dynamicFieldCategory: { id } } = res.data
        
        this.props.history.push(`/dynamic_field_categories/${id}/edit`);
      });
  }

  render() {
    return (
      <>
        <ContextualNavbar
          title="Create Dynamic Field Category"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldCategoryForm submitFormAction={this.createDynamicFieldGroup} submitButtonName="Create" />
      </>
    );
  }
}

export default withErrorHandler(DynamicFieldCategoryNew, hyacinthApi);
