import React from 'react';

import ProjectSubHeading from '../../../hoc/ProjectLayout/ProjectSubHeading/ProjectSubHeading';
import FieldSetForm from './FieldSetForm';

class FieldSetEdit extends React.PureComponent {
  render() {
    const { match: { params: { projectStringKey, id } } }= this.props;

    return (
      <>
        <ProjectSubHeading>Edit Field Set</ProjectSubHeading>
        <FieldSetForm formType="edit" projectStringKey={projectStringKey} id={id} key={id} />
      </>
    );
  }
}

export default FieldSetEdit;
