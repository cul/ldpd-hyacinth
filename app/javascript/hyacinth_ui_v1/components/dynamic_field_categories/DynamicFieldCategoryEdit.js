import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import hyacinthApi from '../../util/hyacinth_api';
import withErrorHandler from '../../hoc/withErrorHandler/withErrorHandler';
import DynamicFieldCategoryForm from './DynamicFieldCategoryForm';

class DynamicFieldCategoryEdit extends React.Component {
  updateDynamicFieldCategory = (data) => {
    const { match: { params: { id } }, history: { push } } = this.props;

    hyacinthApi.patch(`/dynamic_field_categories/${id}`, data)
      .then(() => {
        push('/dynamic_fields');
      });
  }

  render() {
    return (
      <>
        <ContextualNavbar
          title="Edit Dynamic Field Category"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldCategoryForm submitFormAction={this.updateDynamicFieldCategory} submitButtonName="Update" />
      </>
    );
  }
}

export default withErrorHandler(DynamicFieldCategoryEdit, hyacinthApi);
