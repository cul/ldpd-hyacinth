import React from 'react';

import ContextualNavbar from '../../layout/ContextualNavbar';

export default class RightsShow extends React.Component {

  render(){
    return(
      <ContextualNavbar
        title="Item Rights"
        rightHandLinks={[
          { link: '/digital-objects/1/rights/edit', label: 'Edit' },
        ]}
      />
    )
  }
}
