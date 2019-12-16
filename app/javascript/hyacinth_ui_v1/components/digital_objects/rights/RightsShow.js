import React from 'react';

import digitalObjectInterface from '../digitalObjectInterface';
import EditButton from '../../ui/buttons/EditButton';
import TabHeading from '../../ui/tabs/TabHeading';

class RightsShow extends React.PureComponent {
  render() {
    const {
      match: { params: { id } },
      data: { rights }
    } = this.props;
    return (
      <>
        <TabHeading>
          Rights
          <EditButton
            className="float-right"
            size="lg"
            link={`/digital_objects/${id}/rights/edit`}
          />
          <div className="card">
            <div className="card-body">
              <code>{ JSON.stringify(rights) }</code>
            </div>
          </div>
        </TabHeading>
      </>
    );
  }
}

export default digitalObjectInterface(RightsShow);
