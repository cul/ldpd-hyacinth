import React from 'react';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import FieldSetForm from './FieldSetForm';

class FieldSetNew extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey } } } = this.props;

    return (
      <>
        <ProjectSubHeading>Create New Field Set</ProjectSubHeading>
        <FieldSetForm formType="new" projectStringKey={projectStringKey} />
      </>
    );
  }
}

export default FieldSetNew;
