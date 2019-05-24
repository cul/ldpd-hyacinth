import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import DynamicFieldCategoryForm from './DynamicFieldCategoryForm';

class DynamicFieldCategoryEdit extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Edit Dynamic Field Category"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldCategoryForm key={id} id={id} formType="edit" />
      </>
    );
  }
}

export default DynamicFieldCategoryEdit;
