import React from 'react';

import ContextualNavbar from '../layout/ContextualNavbar';
import DynamicFieldCategoryForm from './DynamicFieldCategoryForm';

class DynamicFieldCategoryNew extends React.Component {
  render() {
    return (
      <>
        <ContextualNavbar
          title="Create Dynamic Field Category"
          rightHandLinks={[{ link: '/dynamic_fields', label: 'Back to Dynamic Fields' }]}
        />

        <DynamicFieldCategoryForm formType="new" />
      </>
    );
  }
}

export default DynamicFieldCategoryNew;
