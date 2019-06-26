import React from 'react';

import ContextualNavbar from '../../layout/ContextualNavbar';

export default class RightsShow extends React.Component {

  render(){
    return(
      <ContextualNavbar
        title="Item Rights"
        rightHandLinks={[
          { link: `/digital_objects/${this.props.match.params.id}/rights/edit`, label: 'Edit' },
        ]}
      />
    )
  }
}
