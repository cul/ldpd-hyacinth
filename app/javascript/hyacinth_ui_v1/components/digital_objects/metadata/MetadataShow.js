import React from 'react';

import digitalObjectInterface from '../digitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';

class MetadataShow extends React.PureComponent {
  render() {
    const { match: { params: { id } } } = this.props;

    return (
      <>
        <TabHeading>
          Metadata
          <EditButton
            className="float-right"
            size="lg"
            link={`/digital_objects/${id}/metadata/edit`}
          />
        </TabHeading>
      </>
    );
  }
}


export default digitalObjectInterface(MetadataShow);
