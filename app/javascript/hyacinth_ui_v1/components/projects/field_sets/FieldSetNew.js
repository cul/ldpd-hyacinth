import React from 'react';

import TabHeading from '../../ui/tabs/TabHeading';
import FieldSetForm from './FieldSetForm';

class FieldSetNew extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey } } } = this.props;

    return (
      <>
        <TabHeading>Create New Field Set</TabHeading>
        <FieldSetForm formType="new" projectStringKey={projectStringKey} />
      </>
    );
  }
}

export default FieldSetNew;
