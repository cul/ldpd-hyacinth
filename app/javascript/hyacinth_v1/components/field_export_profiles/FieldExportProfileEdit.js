import React from 'react';

import ContextualNavbar from '../shared/ContextualNavbar';
import FieldExportProfileForm from './FieldExportProfileForm';

class FieldExportProfileEdit extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <ContextualNavbar
          title="Update Field Export Profile"
          rightHandLinks={[{ link: '/field_export_profiles', label: 'Back to All Field Export Profiles' }]}
        />

        <FieldExportProfileForm formType="edit" id={id} key={id} />
      </>
    );
  }
}

export default FieldExportProfileEdit;
