import React from 'react';
import MetadataForm from './MetadataForm';
import digitalObjectInterface from '../digitalObjectInterface';

class MetadataEdit extends React.PureComponent {
  render() {
    return (
      <MetadataForm formType="edit" />
    );
  }
}


export default digitalObjectInterface(MetadataEdit);
