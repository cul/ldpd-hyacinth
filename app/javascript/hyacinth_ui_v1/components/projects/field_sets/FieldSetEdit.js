import React from 'react';

import TabHeading from '../../ui/tabs/TabHeading';
import FieldSetForm from './FieldSetForm';

class FieldSetEdit extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, id } } } = this.props;

    return (
      <>
        <TabHeading>Edit Field Set</TabHeading>
        <FieldSetForm formType="edit" projectStringKey={projectStringKey} id={id} key={id} />
      </>
    );
  }
}

export default FieldSetEdit;
