import React from 'react';

import TabHeading from '../../ui/tabs/TabHeading';
import EditButton from '../../ui/buttons/EditButton';

export default class RightsShow extends React.PureComponent {

  render() {
    return (
      <TabHeading>
        Rights
        <EditButton
          className="float-right"
          size="lg"
          link={`/digital_objects/${this.props.match.params.id}/rights/edit`}
        />
      </TabHeading>
    );
  }
}
